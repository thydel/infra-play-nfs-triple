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

submake := --no-print-directory --warn-undefined-variables

main install: phony; nfs-triple.mk $(submake) $@
main.help := nfs-triple.mk main
install.help := nfs-triple.mk install
helps += main install

define tmp/readme.txt
# infra-play-nfs-triple

Generates playbook from nfs-triple data

# Output of "make" (.i.e. "make help")
endef

tmp/readme.txt: $(TOP); @echo '$($@)' > $@
~ += tmp/help.txt
$~: code := echo '```'
$~: help := make $(submake) | sed -e '1d;$$d'
$~: tmp/.stone $(TOP); (echo; $(code); $(help); $(code)) > $@
README.md: tmp/readme.txt tmp/help.txt; cat $^ > $@
readme: phony README.md
readme.help := Generates README.md from "make help"
helps += readme

help: self := $(strip $(if $(filter Makefile, $(TOP)), make, $(TOP)))
help: help := echo;
help: help += $(foreach _, $(helps), echo '$(self) $_: $($_.help)';)
help: help += echo;
help: help += nfs-triple.mk  $(submake) help;
help:; @($($@)) | sed -e 's/  *$$//'

# Local Variables:
# indent-tabs-mode: nil
# End:
