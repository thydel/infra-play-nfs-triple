#!/usr/bin/make -f

MAKEFLAGS += -Rr
SHELL != which bash

self := $(lastword $(MAKEFILE_LIST))

data := data/oxa/apps/nfs-triple.json

nfs-triple.json: nfs-triple.jsonnet $(data); $< > $@

playbook.%.json: nfs-triple.json; jq 'map(select(.tags|index("$*")))' $< > $(@F)

tags:; @jq -r '.triples|map("$(self) playbook." + . + ".json")[]' $(data)
