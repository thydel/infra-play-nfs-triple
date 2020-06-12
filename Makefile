#!/usr/bin/make -f

include head.mk
include conf.mk
include lineinfile.mk

links := repo inventory
$(foreach link,$(links),$(call Import,conf,dir.$(link)))
$(links):; ln -s $(conf.dir.$@) $@
links: phony $(links)
links.help := Links $(links) to base out dir
help += links

exclude := *~ tmp out $(links)
exclude.git := .git/info/exclude
$(foreach _,$(exclude),$(call lineinfile, $_, $(exclude.git)))
exclude: phony .git/info/exclude
exclude.help := Adds $(exclude) to $(exclude.git)
help += exclude

once := links exclude
once: phony $(once)
help.once := Runs once targets $(once)

migrate = git -C $(src) format-patch --stdout --root $@ | git am -p1

files := nfs-triple.mk nfs-triple.jsonnet
$(files): src := ../plays-19
$(files):; $(migrate)
migrate:: phony $(files)

files := head.mk lineinfile.mk
$(files): src := ../data-nfs-triple
$(files):; $(migrate)
migrate:: phony $(files)

main: phony; nfs-triple.mk --no-print-directory

# Local Variables:
# indent-tabs-mode: nil
# End:
