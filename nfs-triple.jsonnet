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
  noop: {
    meta: "noop"
  },
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
  dir(path, user = 'root', state = 'directory'): {
    file: {
      path: path,
      mode: "755",
      state: state,
      owner: user,
      group: user
    },
  },
  // brain dammage module has no way to remove empty dir only
  // undir(path, user): self.dir(path, user, 'absent'),
  undir(path): [
    {
      stat: {
        path: path,
      },
      register: "path"
    },
    {
      find: {
        paths: path,
        recurse: false
      },
      register: "find",
    },
    // still not safe enuf for me
    // { file: { path: path, state: 'absent' }, when: "find.mathed|int == 0" },
    {
      command: {
        argv: [
          "rmdir",
          path
        ],
        warn: false // yet file mod insists we take a dangereous path
      },
      when: "path.stat.exists == True and find.matched|int == 0",
    }
  ],
  lineinfile(path, line): {
    lineinfile: {
      path: path,
      line: line
    }
  },
  comment(path, line): {
    local quote(s) = std.foldl(function(s, c) std.strReplace(s, c, "\\" + c), std.stringChars("()"), s),
    replace: {
      path: path,
      regexp: "^" + quote(line),
      replace: "#" + line
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
  umount(url, mountpoint): self.mount(url, mountpoint) + { mount +: { state: "umounted" }},
  nomount(url, mountpoint): self.mount(url, mountpoint) + { mount +: { state: "absent" }},
  unlink(link): [
    {
      stat: {
        path: link.name
      },
      register: "link_name"
    },
    {
      file: {
        path: link.name,
        state: "absent"
      },
      when: "link_name.stat.islnk is defined and link_name.stat.islnk"
    }
  ],
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
  collections:: [
    'ansible.builtin',
    'ansible.posix',
    'community.general'
  ],
  parts:: {
    tags: [ triple.id, triple.uid ],
    common(play): plays.become(play) + plays.tags(play, self.tags),
    plays: [
      {
        hosts: triple.server.name,
        collections: $.collections,
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
    ],
    untags: std.map(function(s) "undo-" + s, self.tags),
    uncommon(play): plays.become(play) + plays.tags(play, self.untags),
    unplays: [
      {
        hosts: triple.client.name,
        collections: $.collections,
        tasks: [
          tasks.nomount($.urls.mount, triple.client.path),
          tasks.noop
        ]
        + std.flatMap(tasks.unlink, triple.client.links)
      },
      {
        hosts: triple.server.name,
        tasks: [
          tasks.comment("/etc/exports", $.lines.export),
        ]
        + tasks.undir(triple.server.path),
      }
    ]
  },
  plays: std.map(self.parts.common, self.parts.plays) + std.map(self.parts.uncommon, self.parts.unplays)
};

std.flattenArrays(std.map(function(t) nfs(triples.by_triple[t]).plays, triples.triples))

# Local Variables:
# indent-tabs-mode: nil
# End:
