# infra-play-nfs-triple

Generates playbook from nfs-triple data

# Output of "make" (.i.e. "make help")

```
make links: Links "repo inventory" to base out dir
make exclude: Adds "*~ tmp out repo inventory" to ".git/info/exclude"
make once: Runs once targets (links exclude)
make main: nfs-triple.mk main
make install: nfs-triple.mk install
make readme: Generates README.md from "make help"


nfs-triple.mk mk: Generates "tmp/nfs-triple.mk" makefile setting the list of triple to be include
nfs-triple.mk plays: Generates all playbook in "tmp/nfs-triple.json"
nfs-triple.mk tags: Generates one playbook per triple in "out/playbook.%.json"
nfs-triple.mk main: nfs-triple.mk tags
nfs-triple.mk readme: Generates README for install dir
nfs-triple.mk install:
	install "out/playbook.%.json" in "/usr/local/etc/epi/repo/infra-play-nfs-triple.tde"
	symlink /usr/local/etc/epi/repo/infra-play-nfs-triple to /usr/local/etc/epi/repo/infra-play-nfs-triple.tde
```
