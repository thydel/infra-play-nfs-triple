#!/usr/bin/make -f

include head.mk
include lineinfile.mk

links := repo inventory
$(links): local := /usr/local/etc/epi
$(links):; ln -s $(local)/$@
links: phony $(links)

-: exclude := *~ tmp out $(links)
-: - := $(foreach _,$(exclude),$(call lineinfile, $_, .git/info/exclude))

once: phony .git/info/exclude

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
