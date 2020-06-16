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
ifdef NEVER
Import = $(eval $1: - := $$(eval $(or $3,$1.$2) := $$($2)))
endif
define Import
$(strip
  $(eval ~ := $(strip $1))
  $(eval 3 ?=)
  $(if $3,
    $(eval $~: - := $$(eval $3 := $$($(strip $2)))),
    $(foreach _, $2, $(eval $~: - := $$(eval $~.$_ := $$($_))))))
endef
head: version := 1.0

TOP    := $(firstword $(MAKEFILE_LIST))
$(TOP) := $(basename $(TOP))

Self  =
Self += $(eval SELF    := $(lastword $(MAKEFILE_LIST)))
Self += $(eval $(SELF) := $(basename $(SELF)))
Self += $(eval $(SELF):;)

top: phony; @date

%/.stone:; mkdir -p $(@D); touch $@

# Local Variables:
# indent-tabs-mode: nil
# End:
