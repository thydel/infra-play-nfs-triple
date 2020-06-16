$(and $(if $(filter $(words $(MAKEFILE_LIST)), 1), $(error $(MAKEFILE_LIST) is meant to be included)),)

ultimo := /proc/self
$(ultimo): tmp/.stone;

adam := tmp/.adam
$(adam):; touch -d @0 $@

old-or-young := && echo $(adam) || echo $(ultimo)

need-adam   = $(eval $1-need-adam :=)
need-adam  += $(if $($(strip $1-need-adam)),, $(eval $(strip $1-need-adam := _))
need-adam  += $(eval $(strip $1:: $(adam))))

lineinfile = $(eval $(strip $2:: $(shell grep -q '^$(strip $1)$$' $2 $(old-or-young)); echo '$(strip $1)' >> $$@))
lineinfile += $(call need-adam, $2)
