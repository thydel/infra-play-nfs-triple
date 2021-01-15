#!/usr/bin/make -f

include head.mk
include repo.mk
include conf.mk

tmp := tmp
out := out
install :=
helps :=

. := repo/infra-data-nfs-triple

~ := $(tmp)/nfs-triple.mk
$~: jq = .triples | "$* := " + join(" ")
$~: $(tmp)/%.mk : $./%.json; jq -r '$(jq)' $< > $@
$(TOP): $~
-include $~
mk: phony $~
mk.help := Generates "$~" makefile setting the list of triple to include
helps += mk

~ := $(tmp)/nfs-triple.json
$~: $(tmp)/%.json : %.jsonnet $./%.json; $< -J $. > $@
plays: phony $~
plays.help := Generates all playbook in "$~"
helps += plays

~ := $(out)/playbook.%.json
$~: jq = map(select(.tags|index("$*")))
$~: install := install --backup=t /dev/stdin
$~: $(tmp)/nfs-triple.json $(out)/.stone; jq '$(jq)' $< | $(install) $(@)
install += $($($(TOP)):%=$~)
tags: phony $(install)
tags.help := Generates one playbook per triple in "$(out)/playbook.%.json"
helps += tags

~ := $(out)/unplaybook.%.json
$~: jq = map(select(.tags|index("undo-$*")))
$~: install := install --backup=t /dev/stdin
$~: $(tmp)/nfs-triple.json $(out)/.stone; jq '$(jq)' $< | $(install) $(@)
install += $($($(TOP)):%=$~)
untags: phony $(install)
untags.help := Generates one unplaybook per triple in "$(out)/unplaybook.%.json"
helps += tags

playdiff/%: $(out)/playbook.%.json phony; -ls -t $<* | head -2 | tac | xargs diff

~ := $(out)/playbook.%.yml
$~: $(~:%.yml=%.json); yq r -P $< > $@
yml := $($($(TOP)):%=$~)
install += $(yml)
yml: phony yq $(yml)
yml.help := Generates yaml version of all json playbooks
help += yml

~ := $(out)/unplaybook.%.yml
$~: $(~:%.yml=%.json); yq r -P $< > $@
unyml := $($($(TOP)):%=$~)
install += $(unyml)
unyml: phony yq $(unyml)
unyml.help := Generates yaml version of all json unplaybooks
help += unyml

$(call Import, conf, dir.bin)

~ := $(conf.dir.bin)/yq
$~: arch != uname -m
$~: x86_64 := amd64
$~: version := 3.4.0
$~: binary = yq_linux_$($(arch))
$~: url = https://github.com/mikefarah/yq/releases/download/$(version)/$(binary)
$~:; wget $(url) -O - | install /dev/stdin $@
yq: phony $~
yq.help := Download and install yq
help += yq

ifdef NEVER
tags: jq := .triples|map("$(TOP) --no-print-directory $(out)/playbook." + . + ".json")[]
tags: phony; @jq -r '$(jq)' $./nfs-triple.json | dash
endif

main: phony tags untags yml unyml
main.help := $(TOP) tags
helps += main

$(call Import, conf, dir.repo)
$(call Import, repo, name branch readme)

~ := $(out)/README
$~: repo.mk; echo "$(repo.readme)" > $@
install += $~
readme: phony $~
readme.help := Generates README for install dir
helps += readme

~ := install
$~.link := $(conf.dir.repo)/$(repo.name)
$~.dir := $($~.link).$(repo.branch)
$~.files := $(install:$(out)/%=$($~.dir)/%)
$($~.files): $($~.dir)/% : $(out)/%; install -CD -m=0444 --backup=numbered $< $@
$($~.link): $($~.dir)/.stone; ln -snf $(<D) $@
$~: phony $($~.link) $($~.files)
install.help := \n\tinstall "$(out)/playbook.%.json" in "$($~.dir)"
install.help += \n\tsymlink $($~.link) to $($~.dir)
helps += install

help: help := echo;
help: help += $(foreach _, $(helps), echo -e '$(TOP) $_: $($_.help)';)
help: help += echo;
help:; @($($@))
