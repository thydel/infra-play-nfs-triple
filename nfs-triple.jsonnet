#!/usr/bin/env jsonnet

local triples = import 'nfs-triple.json';

local defaults = {
  options: {
    export: "(rw,sync,no_subtree_check)",
    // mount: "rw,hard,intr,noatime,nodiratime,noauto"
    mount: "noauto,rw,hard,intr,noatime,nodiratime"
  }
};

local tasks = {
  command(cmd): {
    name: cmd,
    command: {
      cmd: cmd
    }
  },
  apt(names): {
    apt: {
      name: if std.isString(names) then [names] else names
    }
  },
  dir(path, user = 'root'): {
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
  start(name): {
    service: {
      name: name,
      state: "started"
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
  link(link): [
    {
      stat: {
        path: link.target
      },
      register: "target"
    },
    {
      file: {
        src: link.target,
        dest: link.name,
        state: "link"
      },
      when: "target.stat.exists == True"
    },
    {
      debug: {
        msg: "symlink " + link.target + " " + link.name,
      },
      when: "target.stat.exists == False"
    }
  ]
};

local plays = {
  become(play): {
    become: true
  } + play,
  tags(play, tags): {
    tags: tags
  } + play
};

local lib = {
  local sep = '/',
  butLast(a, n = 1): std.reverse(std.reverse(a)[n:]),
  dirname(path): std.join(sep, lib.butLast(std.split(path, sep)))
};

local nfs(triple) = {
  lines:: {
    export: triple.server.path + " " + triple.client.node + defaults.options.export
  },
  urls:: {
    mount: triple.server.node + ":" + triple.server.path
  },
  cmds:: {
    exportfs: 'exportfs -ar'
  },
  notifies: {
    exportfs: {
      notify: [ $.cmds.exportfs ]
    }
  },
  parts:: {
    tags: [ triple.id, triple.uid ],
    common(play): plays.become(play) + plays.tags(play, self.tags),
    plays: [
      {
        hosts: triple.server.name,
        collections: [
          'ansible.builtin',
          'ansible.posix',
          'community.general'
        ],
        tasks: [
          tasks.apt("nfs-kernel-server"),
          tasks.dir(triple.server.path, triple.user.name),
          tasks.lineinfile("/etc/exports", $.lines.export) + $.notifies.exportfs,
          // tasks.restart("nfs-kernel-server")
          tasks.start("nfs-kernel-server")
        ],
        handlers: [
          tasks.command($.cmds.exportfs)
        ],
      },
      {
        hosts: triple.client.name,
        tasks: [
          tasks.apt("nfs-common"),
          tasks.dir(triple.client.path, triple.user.name),
          tasks.mount($.urls.mount, triple.client.path),
        ]
        + std.map(tasks.dir, std.map(lib.dirname, [l.name for l in triple.client.links]))
        + std.flatMap(tasks.link, triple.client.links)
      }
    ]
  },
  plays: std.map(self.parts.common, self.parts.plays)
};

std.flattenArrays(std.map(function(t) nfs(triples.by_triple[t]).plays, triples.triples))

# Local Variables:
# indent-tabs-mode: nil
# End:
