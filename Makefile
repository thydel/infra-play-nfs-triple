#!/usr/bin/make -f

include head.mk
include conf.mk
include lineinfile.mk

helps :=

links := repo inventory
$(foreach link,$(links),$(call Import,conf,dir.$(link)))
$(links):; ln -s $(conf.dir.$@) $@
links: phony $(links)
links.help := Links "$(links)" to base out dir
helps += links

exclude := *~ tmp out $(links)
exclude.git := .git/info/exclude
$(foreach _,$(exclude),$(call lineinfile, $_, $(exclude.git)))
exclude: phony .git/info/exclude
exclude.help := Adds "$(exclude)" to "$(exclude.git)"
helps += exclude

once := links exclude
once: phony $(once)
once.help := Runs once targets ($(once))
helps += once

ifdef NEVER
migrate = git -C $(src) format-patch --stdout --root $@ | git am -p1

files := nfs-triple.mk nfs-triple.jsonnet
$(files): src := ../plays-19
$(files):; $(migrate)
migrate:: phony $(files)

files := head.mk lineinfile.mk
$(files): src := ../data-nfs-triple
$(files):; $(migrate)
migrate:: phony $(files)
endif

main install: phony; nfs-triple.mk --no-print-directory --warn-undefined-variables $@
main.help := nfs-triple.mk main
install.help := nfs-triple.mk install
helps += main install

help: self := $(strip $(if $(filter Makefile, $(TOP)), make, $(TOP)))
help: help := echo;
help: help += $(foreach _, $(helps), echo '$(self) $_: $($_.help)';)
help: help += echo;
help: help += nfs-triple.mk --no-print-directory help;
help:; @($($@))

# Local Variables:
# indent-tabs-mode: nil
# End:
