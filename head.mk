$(and $(if $(filter $(words $(MAKEFILE_LIST)), 1), $(error $(MAKEFILE_LIST) is meant to be included)),)

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

-: min := 4.1
-: msg := make $(MAKE_VERSION) < $(min)
-: - := $(and $(or $(filter $(min),$(firstword $(sort $(MAKE_VERSION) $(min)))),$(error $(msg))),)

# $(call Import,$(rule),$(var)) -> define $(rule).$(var) as $(var) from $(rule)
# $(call Import,$(rule),$(var),$(invar)) -> define $(invar) as $(var) from $(rule)
Import = $(eval $1: - := $$(eval $(or $3,$1.$2) := $$($2)))
head: version := 1.0

self    := $(firstword $(MAKEFILE_LIST))
$(self) := $(basename $(self))
$(self):;

top: phony; @date

%/.stone:; mkdir -p $(@D); touch $@

# Local Variables:
# indent-tabs-mode: nil
# End:
