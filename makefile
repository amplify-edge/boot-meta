SHARED_FSPATH=./../shared
BOILERPLATE_FSPATH=$(SHARED_FSPATH)/boilerplate

include $(BOILERPLATE_FSPATH)/help.mk
include $(BOILERPLATE_FSPATH)/os.mk
include $(BOILERPLATE_FSPATH)/gitr.mk
include $(BOILERPLATE_FSPATH)/tool.mk

## Build in CI
this-all: this-print dep-install this-dep this-build

## Print all settings
this-print: ## print
	
	@echo
	@echo -- Boot-Meta REPO : start --
	@echo

	$(MAKE) os-print
	
	$(MAKE) gitr-print

	$(MAKE) mage-print

	$(MAKE) go-print

	$(MAKE) tool-print
	
	$(MAKE) flu-print

	$(MAKE) flu-gen-lang-print

	@echo
	@echo -- Boot REPO : end --
	@echo


## All 
this-all: this-dep this-build 


.PHONY: this-dep
## Dep
this-dep: ## install build tools
	$(call help-print-target)
	# go install github.com/getcouragenow/boot
	

.PHONY: this-build-snapshot
## Build-snapshot
this-build-snapshot: dep
	$(call help-print-target)
	goreleaser --snapshot --skip-publish --rm-dist

.PHONY: this-build
## Build
this-build:
	$(call print-target)
	# ~/.config/goreleaser/github_token
	#go install github.com/goreleaser/goreleaser
	goreleaser --rm-dist

	#  cgo not being supported by goreleaser. So how the hell can we build the Mobile and Desktop ?