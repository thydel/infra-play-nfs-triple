$(and $(if $(filter $(words $(MAKEFILE_LIST)), 1), $(error $(MAKEFILE_LIST) is meant to be included)),)

$(Self)
~ := $($(SELF))

$~: url != git config --get remote.origin.url
$~: branch :=
$~: branch != git branch --show-current
$~: name := $(basename $(notdir $(url)))

# Local Variables:
# indent-tabs-mode: nil
# End:
