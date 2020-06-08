MAKEFLAGS += -Rr
MAKEFLAGS += --warn-undefined-variables
SHELL := $(shell which bash)
.SHELLFLAGS := -euo pipefail -c

.ONESHELL:
.DELETE_ON_ERROR:
.PHONY: phony

.RECIPEPREFIX :=
.RECIPEPREFIX +=

.DEFAULT_GOAL := main

MIN_VERSION := 4.1
VERSION_ERROR :=  make $(MAKE_VERSION) < $(MIN_VERSION)
$(and $(or $(filter $(MIN_VERSION),$(firstword $(sort $(MAKE_VERSION) $(MIN_VERSION)))),$(error $(VERSION_ERROR))),)

self    := $(lastword $(MAKEFILE_LIST))
$(self) := $(basename $(self))
$(self):;

top: phony; @date

%/.stone:; mkdir -p $(@D); touch $@

# Local Variables:
# indent-tabs-mode: nil
# End:
