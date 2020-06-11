#!/usr/bin/make -f

include head.mk
include repo.mk
include conf.mk

$(call Import,head,version)
$(call Import,conf,dir.repo)
$(call Import,repo,name)
$(call Import,repo,branch)

$(warning $(head.version))
$(warning $(conf.dir.repo))
$(warning $(repo.name) $(repo.branch))

main: phony; @date

origins.all := undefined default environment file override automatic
origins.see := file

printvars: phony
 @$(foreach V,$(sort $(.VARIABLES)),
    $(if $(filter $(origins.see),
    $(origin $V)),$(warning $V=$($V) ($(value $V)))))

printvarsorigin: phony
 @$(foreach V,$(sort $(.VARIABLES)),$(warning $V $(origin $V)))
