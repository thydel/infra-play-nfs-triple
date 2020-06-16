$(and $(if $(filter $(words $(MAKEFILE_LIST)), 1), $(error $(MAKEFILE_LIST) is meant to be included)),)

$(Self)
~ := $($(SELF))

$~: url != git config --get remote.origin.url
$~: branch :=
$~: branch != git branch --show-current
$~: name := $(basename $(notdir $(url)))
$~: readme := $$($~.README)

define $~.README
# Installed via

export GIT_SSH_COMMAND='$(shell git config core.sshCommand)';
git clone $(name) -b $(branch);
make -C $(name) install;
endef

# Local Variables:
# indent-tabs-mode: nil
# End:
