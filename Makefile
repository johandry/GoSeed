#===============================================================================
# Author: Johandry Amador <johandry@gmail.com>
# Title:  Makefile to automate all the builds, tests and deployments.
#
# Usage: make [<rule>]
#
# Basic rules:
# 		<none>		If no rule is specified will do the 'default' rule which is 'build'
#			build     Build a container to build and ship the application.
# 		clean 		Remove all the created images.
#     help			Display all the existing rules and description of what they do
#     version   Shows the application version.
# 		all 			Will build the application in every way and run it
#
# Description: This Makefile is to create a container to build this application
# and ship it.
# Use 'make help' to view all the options or go to
# https://github.johandry/__APPNAME__
#
# Report Issues or create Pull Requests in https://github.johandry/__APPNAME__
#===============================================================================

## Variables (Modify their values if needed):
## -----------------------------------------------------------------------------

# SHELL need to be defined at the top of the Makefile. Do not change its value.
SHELL  				:= /bin/bash

## Variables optionally assigned from Environment Variables:
## -----------------------------------------------------------------------------

C_ARCH       ?= 386 amd64
C_OS         ?= linux darwin
# C_ARCH      ?= "386 amd64 arm"
# C_OS        ?= "linux darwin windows freebsd openbsd solaris"
BIN 					= bin
PKG 					= pkg

# Constants (You would not want to modify them):
## -----------------------------------------------------------------------------

# Macros to set the application version, needed for the build:
GIT_COMMIT		=	$(shell git rev-parse --short HEAD  2>/dev/null || echo 'unknown')
GIT_DIRTY			= $(shell test -n "`git status --porcelain`" && echo "+CHANGES" || true)
PKG_NAME   		= $(shell echo $(CURDIR) | rev | cut -f1 -d/ | rev | tr '[A-Z]' '[a-z]')
PKG_BASE 			= $(shell dirname $$(go list .))

VERSION 			= $(shell sed -n 's/^.*Version = "\(.*\)"$$/\1/p' version/latest.go)
PRE_RELEASE 	= $(shell sed -n 's/^.*VersionPrerelease = "\(.*\)"$$/\1/p' version/latest.go)
BINARY 				= $(BIN)/$(PKG_NAME)
LDFLAGS 			= -ldflags "\
	-X $(PKG_BASE)/$(PKG_NAME)/version.GitCommit=$(GIT_COMMIT)$(GIT_DIRTY) \
	-X $(PKG_BASE)/$(PKG_NAME)/version.Version=$(VERSION) \
	-X $(PKG_BASE)/$(PKG_NAME)/version.VersionPrerelease=$(PRE_RELEASE)"

# Docker variables:
DOCKER_IMG  	= $(PKG_NAME)
DOCKER_CON  	= $(PKG_NAME)

# Output:
NO_COLOR 		 ?= false
ifeq ($(NO_COLOR),false)
ECHO 				 := echo -e
C_STD 				= $(shell $(ECHO) -e "\033[0m")
C_RED		 			= $(shell $(ECHO) -e "\033[91m")
C_GREEN 			= $(shell $(ECHO) -e "\033[92m")
C_YELLOW 			= $(shell $(ECHO) -e "\033[93m")
C_BLUE	 			= $(shell $(ECHO) -e "\033[94m")
I_CROSS 			= $(shell $(ECHO) -e "\xe2\x95\xb3")
I_CHECK 			= $(shell $(ECHO) -e "\xe2\x9c\x94")
I_BULLET 			= $(shell $(ECHO) -e "\xe2\x80\xa2")
else
ECHO 				 := echo
C_STD 				=
C_RED		 			=
C_GREEN 			=
C_YELLOW 			=
C_BLUE	 			=
I_CROSS 			= x
I_CHECK 			= .
I_BULLET 			= *
endif

## To find rules not in .PHONY:
# diff <(grep '^.PHONY:' Makefile | sed 's/.PHONY: //' | tr ' ' '\n' | sort) <(grep '^[^# ]*:' Makefile | grep -v '.PHONY:' | sed 's/:.*//' | sort) | grep '[>|<]'

.PHONY: default help all version test
.PHONY: build build-all build4docker
.PHONY: image run sh
.PHONY: vendors vendor-init vendor-update
.PHONY: ls clean clean-all

## Default Rules:
## -----------------------------------------------------------------------------

# default is the rule that is executed when no rule is specified in make. By
# default make will do the rule 'build'
default: build

# all is to execute the entire process to create a Presto AMI and a Presto
# Cluster.
all: clean build build-all image run

# help to print all the commands and what they are for
help:
	@content=""; grep -v '.PHONY:' Makefile | grep -v '^## ' | grep '^[^# ]*:' -B 5 | grep -E '^#|^[^# ]*:' | \
	while read line; do if [[ $${line:0:1} == "#" ]]; \
		then l=$$($(ECHO) $$line | sed 's/^# /  /'); content="$${content}\n$$l"; \
		else header=$$($(ECHO) $$line | sed 's/^\([^ ]*\):.*/\1/'); [[ $${content} == "" ]] && content="\n  $(C_YELLOW)No help information for $${header}$(C_STD)"; $(ECHO) "$(C_BLUE)$${header}:$(C_STD)$$content\n"; content=""; fi; \
	done

# display the version of this project
version:
	@$(ECHO) "$(C_GREEN)Version:$(C_STD) v$(VERSION)-$(PRE_RELEASE) ($(GIT_COMMIT)$(GIT_DIRTY))$(C_STD)"
# DELETE.START
init:
	@if [[ '$(PKG_NAME)' == 'goseed' ]]; then $(ECHO) "$(C_RED)$(I_CROSS) Rename this directory with your application name or use env PKG_NAME different to $(PKG_NAME).\nExample: $(C_YELLOW)make init PKG_NAME=MyApp$(C_STD)" && false; fi
	@$(ECHO) "$(C_GREEN)Initializing the project with name: $(C_YELLOW)$(PKG_NAME)$(C_STD)"
	@grep -r '__APPNAME__' * | cut -f1 -d: | sort | uniq | while read f; do sed -i .bkp 's/__APPNAME__/$(PKG_NAME)/g' $$f; rm -f $$f.bkp; done
	@$(RM) -r .git
	@git init
	@sed -i.org '/^# DELETE.START/,/^# DELETE.END/d' Makefile
	@$(RM) Makefile.org
# DELETE.END

## Main Rules:
## -----------------------------------------------------------------------------

# Application binary for this OS and Architecture
$(BINARY): build

# build the application. The binary is located in $(BIN)/$(APP_NAME)
build: vendors test
	@$(ECHO) "$(C_GREEN)Building $(C_YELLOW)v$(VERSION)-$(PRE_RELEASE) ($(GIT_COMMIT)$(GIT_DIRTY))$(C_GREEN) for $(C_YELLOW)$$(go env GOOS)$(C_STD)"
	@go build $(LDFLAGS) -o $(BINARY) && \
		$(ECHO) "$(C_GREEN)$(I_CHECK) Build completed at $(C_YELLOW)$(BINARY)$(C_STD)" || \
		$(ECHO) "$(C_RED)$(I_CROSS) Build failed$(C_STD)"

# Testing code
test:
	@$(ECHO) "$(C_GREEN)Testing$(C_STD)"
	@go test -v

# build the application for a Docker image
build4docker: vendor-init test
	@[[ -d /go ]] || ( $(ECHO) "$(C_RED)$(I_CROSS) This rule is to be executed only inside the $(APP_NAME) build image$(C_STD)"; false )
	@$(ECHO) "$(C_GREEN)Building $(C_YELLOW)v$(VERSION)-$(PRE_RELEASE) ($(GIT_COMMIT)$(GIT_DIRTY))$(C_GREEN) for Linux $(C_YELLOW)$$(grep '^FROM .* AS application' Dockerfile | cut -f2 -d' ')$(C_STD)"
	@CGO_ENABLED=0 \
		GOOS=linux \
		go build $(LDFLAGS) \
      -a -installsuffix cgo \
      -o /$(PKG_NAME) && \
		$(ECHO) "$(C_GREEN)$(I_CHECK) Build completed at $(BINARY)$(C_STD)" || \
		$(ECHO) "$(C_RED)$(I_CROSS) Build failed$(C_STD)"

# build an image to build application with Go and a second image to ship it. The
# build image (and any other without tag) will be deleted.
image:
	@$(ECHO) "$(C_GREEN)Building $(APP_NAME) and containerize it in image $(C_YELLOW)$(DOCKER_IMG)$(C_STD)"
	@docker build \
		--build-arg PKG_NAME=$(PKG_NAME) \
		--build-arg PKG_BASE=$(PKG_BASE) \
		-t $(DOCKER_IMG) .
	@docker images | grep '<none>' | awk '{print $$3}' | while read i; do docker rmi -f $$i; done

# get Govendor, initialize vendor/vendor.json, get the packages that do not
# exists in the container and get/copy all the packages to vendor/ and update
# vendor/vendor.json
vendor-init:
	@$(ECHO) "$(C_GREEN)Initializing vendors$(C_STD)"
	-@[[ ! -x $${GOPATH}/bin/govendor ]] && go get -u github.com/kardianos/govendor
	@govendor init
	@govendor list -no-status +missing | xargs -n1 go get -u
	@govendor add +external

# get libraries from vendor/vendor.json to /vendor/
vendors:
	@$(ECHO) "$(C_GREEN)Getting vendors$(C_STD)"
	@govendor sync

# Update libraries in $GOPATH and vendor/, then commit changes to git
vendor-update:
	@echo "$(C_GREEN)Updating libraries and committing changes$(C_STD)"
	-@govendor list -no-status +vendor | xargs -n1 go get -u
	@govendor update +vendor
	@git diff vendor/vendor.json | grep '"path": ' | sed 's/.*"path": "\(.*\)",/- \1/'
	@git add vendor/vendor.json && git commit -m "New/Updated vendors"

# executes the application in the container. This executes only one node, to
# have a cluster use `make cluster`
run:
	@$(ECHO) "$(C_GREEN)Running $(APP_NAME) from $(C_YELLOW)$(DOCKER_CON)$(C_STD)"
	docker run --name $(DOCKER_CON) --rm -it $(DOCKER_IMG)

# creates an application container and login into it. This may require to modify
# the Dockerfile to use a different base and maybe the rule to use a different
# shell
sh:
	@$(ECHO) "$(C_GREEN)Login into the $(APP_NAME) container$(C_STD)"
	docker run --name $(DOCKER_CON) --rm -it $(DOCKER_IMG) /bin/bash --login

# remove the application image and every non-tagged image. The build image is a
# non-tagged image but there may be others not related to this project, so use
# this rule with careful. Execute 'make ls' before run it.
clean:
	@$(ECHO) "$(C_GREEN)Removing:$(C_STD)"
	@$(ECHO) "  $(C_YELLOW)$(I_BULLET)$(C_GREEN) $(APP_NAME) image $(C_YELLOW)$(DOCKER_IMG)$(C_STD)"
	-@docker rmi $(DOCKER_IMG) 2>/dev/null
	@$(ECHO) "  $(C_YELLOW)$(I_BULLET)$(C_GREEN) Every non-tagged image$(C_STD)"
	@docker images | grep '<none>' | awk '{print $$3}' | while read i; do docker rmi -f $$i; done
	@$(ECHO) "  $(C_YELLOW)$(I_BULLET)$(C_GREEN) Vendors$(C_STD)"
	@govendor remove +vendor
	@$(ECHO) "  $(C_YELLOW)$(I_BULLET)$(C_GREEN) Binaries$(C_STD)"
	@$(RM) -r $(PKG)
	@$(RM) -r $(BIN)

# remove every Docker container and image, including those not related to this
# project, so use this rule with careful. Execute 'make ls' before run it.
clean-all: clean
	@$(ECHO) "$(C_RED)Deleting every Docker container and image$(C_STD)"
	-@docker rm `docker ps -aq` 2>/dev/null
	-@docker rmi `docker images -q` 2>/dev/null

# list every Docker container and image in your system
ls:
	@$(ECHO) "$(C_GREEN)Containers:$(C_STD)"
	@docker ps -a
	@$(ECHO) "$(C_GREEN)Images:$(C_STD)"
	@docker images

# build the application for every OS and Architecture. The binaries are located
# at $(PKG)/v$(VERSION)
build-all:
	@$(ECHO) "$(C_GREEN)Building $(C_YELLOW)v$(VERSION)-$(PRE_RELEASE) ($(GIT_COMMIT)$(GIT_DIRTY))$(C_GREEN) for:$(C_STD)"
	@for os in $(C_OS); do \
		$(ECHO) " $(C_BLUE)$(I_BULLET)$(C_GREEN)  $${os}$(C_STD)"; \
		for arch in $(C_ARCH); do \
			case  "$${os}/$${arch}" in \
				"windows/arm" | "solaris/386" | "solaris/arm") true;; \
				* ) $(ECHO) "   $(C_BLUE)$(I_BULLET)$(C_YELLOW)  $${arch}$(C_STD)"; \
						GOOS=$${os} GOARCH=$${arch} go build $(LDFLAGS) -o $(PKG)/v$(VERSION)/$${os}/$${arch}/$(PKG_NAME);; \
			esac \
		done \
	done
	@$(ECHO) "$(C_GREEN) All binaries are located at $(C_YELLOW)$(PKG)/v$(VERSION)/$(C_STD)"
