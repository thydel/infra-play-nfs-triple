$(and $(if $(filter $(words $(MAKEFILE_LIST)), 1), $(error $(MAKEFILE_LIST) is meant to be included)),)

$(Self)
~ := $($(SELF))

$~: dir.root := $(abspath $(or $(LOC_ROOT), $(loc_root), /usr/local))
$~: dir.set := $(or $(LOC_SET), $(loc_set), epi)
$~: - := $(foreach _, etc bin lib, $(eval $~: dir.$_ := $(dir.root)/$_))
$~: dir.base := $(dir.etc)/$(dir.set)
$~: - := $(foreach _, inventory src data doc repo, $(eval $~: dir.$_ := $(dir.base)/$_))
$~: - := $(if $(filter $(dir.base), $(wildcard $(dir.base))),, $(error dubious basedir $(dir.base)))

# Local Variables:
# indent-tabs-mode: nil
# End:
