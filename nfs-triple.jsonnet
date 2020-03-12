#!/usr/bin/env jsonnet

local triples = import 'data/oxa/apps/nfs-triple.json';

local defaults = {
  options: {
    export: "(rw,sync,no_subtree_check)",
    mount: "rw,hard,intr,noatime,nodiratime,noauto"
  }
};

local tasks = {
  apt(names): {
    apt: {
      name: if std.isString(names) then [names] else names
    }
  },
  dir(path, user): {
    file: {
      path: path,
      mode: "755",
      state: "directory",
      owner: user,
      group: user
    },
  },
  lineinfile(path, line): {
    lineinfile: {
      path: path,
      line: line
    }
  },
  restart(name): {
    service: {
      name: name,
      state: "restarted"
    }
  },
  mount(url, mountpoint): {
    mount: {
      path: mountpoint,
      src: url,
      fstype: "nfs",
      opts: defaults.options.mount,
      state: "mounted"
    }
  },
  link(link): {
    file: {
      src: link.target,
      dest: link.name,
      state: "link"
    },
  },
};

local plays = {
  become(play): {
    become: true
  } + play,
  tags(play, tags): {
    tags: tags
  } + play
};

local nfs(triple) = {
  lines:: {
    export: triple.server.path + " " + triple.client.node + defaults.options.export
  },
  urls:: {
    mount: triple.server.path + ":" + triple.client.node
  },
  parts:: {
    tags: [ triple.id, triple.uid ],
    common(play): plays.become(play) + plays.tags(play, self.tags),
    plays: [
      {
        hosts: triple.server.name,
        tasks: [
          tasks.apt("nfs-kernel-server"),
          tasks.dir(triple.server.path, triple.user.name),
          tasks.lineinfile("/etc/exports", $.lines.export),
          tasks.restart("nfs-kernel-server")
        ]
      },
      {
        hosts: triple.client.name,
        tasks: [
          tasks.apt("nfs-common"),
          tasks.dir(triple.client.path, triple.user.name),
          tasks.mount($.urls.mount, triple.client.path),
        ] + std.map(tasks.link, triple.client.links)
      }
    ]
  },
  plays: std.map(self.parts.common, self.parts.plays)
};

std.flattenArrays(std.map(function(t) nfs(triples.by_triple[t]).plays, triples.triples))

# Local Variables:
# indent-tabs-mode: nil
# End:
