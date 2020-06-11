#!/usr/bin/make -f

include head.mk

. := repo/infra-data-nfs-triple

tmp/nfs-triple.json: nfs-triple.jsonnet; $< -J $. > $@

out/playbook.%.json: tmp/nfs-triple.json out/.stone; jq 'map(select(.tags|index("$*")))' $< > $(@)

tags: jq := .triples|map("$(TOP) --no-print-directory out/playbook." + . + ".json")[]
tags:; @jq -r '$(jq)' $./nfs-triple.json | dash

main: phony tags
