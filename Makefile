SHELL := /bin/bash
MAKEFILE_NAME := $(firstword $(MAKEFILE_LIST))
SUB-MAKE := $(MAKE) -f $(MAKEFILE_NAME) --no-print-directory
WORKSPACE_DIR := $(shell pwd)
ifeq ($(wildcard $(WORKSPACE_DIR)/components/.),)
	MODULES_FOLDER := modules
else
	MODULES_FOLDER := components
endif
EXTRA_MODULES_FOLDER := $(MODULES_FOLDER)-extra
MODULES_DIR := $(WORKSPACE_DIR)/$(MODULES_FOLDER)
EXTRA_MODULES_DIR := $(WORKSPACE_DIR)/$(EXTRA_MODULES_FOLDER)
TARGET_WARS_DIR := $(WORKSPACE_DIR)/target-wars
TARGET_SERVERS_DIR := $(WORKSPACE_DIR)/target-servers
FILES_DIRNAME := files
FILES_DIR := $(WORKSPACE_DIR)/files

ifeq ($(shell type -p cygpath || echo ""),)
	IS_CYGWIN := 0
else
	IS_CYGWIN := 1
endif

# ====================
# Color constants

cRESET := \x1b[0m
cRED := \x1b[31m
cGREEN := \x1b[32m
cYELLOW := \x1b[33m
cBLUE := \x1b[34m
cMAGENTA := \x1b[35m
cCYAN := \x1b[36m
cWHITE := \x1b[37m

# ====================
# Modules definition

TOOLS := \
minify-maven-plugin

COMPONENTS := \
sonicle-superpom \
sonicle-superpom-senchapkg \
sonicle-commons \
sonicle-commons-web \
sonicle-mail \
sonicle-security \
sonicle-dav \
sonicle-vfs2 \
sonicle-jasperreports-fonts \
sonicle-extjs \
sonicle-extjs-extensions \
webtop-superpom \
webtop-superpom-core \
webtop-superpom-service \
webtop-superpom-service-api \
webtop-core-api \
webtop-calendar-api \
webtop-contacts-api \
webtop-mail-api \
webtop-tasks-api \
webtop-vfs-api \
webtop-drm-api \
webtop-core \
webtop-calendar \
webtop-contacts \
webtop-mail \
webtop-tasks \
webtop-vfs \
webtop-drm
#webtop-mattermost

COMPONENTS_COM :=

COMPONENTS_EXTRA :=

SERVERS := \
webtop-eas-server \
webtop-dav-server

WEBAPPS := \
webtop-webapp

DOCS := \
docs

# ====================
# Defines modules SCM URLs in order to clone projects. (see DEFAULT_CLONE_BASEURL below)
# Every module has the following hidden default: DEFAULT_CLONE_BASEURL
MOD_CLONEBASEURL.minify-maven-plugin := https://github.com/sonicle
MOD_CLONEBASEURL.sonicle-superpom := https://github.com/sonicle

# ====================
# Defines modules flags, characterizing each module in a different manner.
# Avaiable flags are:
#  - git-develop : module has the "develop" branch
#  - git-release : module has the "release" branch
#  - build-development : module allows "development" build-profile, maven profile "profile-development" will be activated at build time if BUILD_TYPE is "development"
#  - build-production : module allows "production" build-profile, maven profile "profile-production" will be activated at build time if BUILD_TYPE is "production"
#  - build-reports : module allows "build-reports" build-profile, maven profile "build-reports" will be activated at build time
#  - tx-push : module allows "transifex-push" build-profile, maven profile "transifex-push" will be activated when using dedicated target
MOD_FLAGS.sonicle-superpom				:= git-develop,git-release
MOD_FLAGS.sonicle-superpom-senchapkg	:= git-develop,git-release
MOD_FLAGS.sonicle-commons				:= git-develop,git-release
MOD_FLAGS.sonicle-commons-web			:= git-develop,git-release
MOD_FLAGS.sonicle-mail					:= git-develop,git-release
MOD_FLAGS.sonicle-security				:= git-develop,git-release
MOD_FLAGS.sonicle-dav					:= git-develop,git-release
MOD_FLAGS.sonicle-vfs2					:= git-develop,git-release
MOD_FLAGS.sonicle-jasperreports-fonts	:= 
MOD_FLAGS.sonicle-extjs					:= git-develop,git-release
MOD_FLAGS.sonicle-extjs-extensions		:= git-develop,git-release,build-development,build-production
MOD_FLAGS.webtop-superpom				:= git-develop,git-release
MOD_FLAGS.webtop-superpom-core			:= git-develop,git-release
MOD_FLAGS.webtop-superpom-service		:= git-develop,git-release
MOD_FLAGS.webtop-superpom-service-api	:= git-develop,git-release
MOD_FLAGS.webtop-core-api				:= git-develop,git-release,build-development,build-production
MOD_FLAGS.webtop-calendar-api			:= git-develop,git-release,build-development,build-production
MOD_FLAGS.webtop-contacts-api			:= git-develop,git-release,build-development,build-production
MOD_FLAGS.webtop-mail-api				:= git-develop,git-release,build-development,build-production
MOD_FLAGS.webtop-tasks-api				:= git-develop,git-release,build-development,build-production
MOD_FLAGS.webtop-vfs-api 				:= git-develop,git-release,build-development,build-production
MOD_FLAGS.webtop-drm-api				:= git-develop,git-release,build-development,build-production
MOD_FLAGS.webtop-core					:= git-develop,git-release,build-development,build-production,tx-push
MOD_FLAGS.webtop-calendar				:= git-develop,git-release,build-development,build-production,build-reports,tx-push
MOD_FLAGS.webtop-contacts				:= git-develop,git-release,build-development,build-production,build-reports,tx-push
MOD_FLAGS.webtop-mail					:= git-develop,git-release,build-development,build-production,tx-push
MOD_FLAGS.webtop-tasks					:= git-develop,git-release,build-development,build-production,build-reports,tx-push
MOD_FLAGS.webtop-vfs					:= git-develop,git-release,build-development,build-production,tx-push
MOD_FLAGS.webtop-drm					:= git-develop,git-release,build-development,build-production,build-reports
MOD_FLAGS.webtop-mattermost				:= git-develop,git-release,build-development,build-production
MOD_FLAGS.webtop-eas-server				:= git-develop,git-release
MOD_FLAGS.webtop-dav-server				:= git-develop,git-release
MOD_FLAGS.webtop-webapp					:= git-develop,git-release,build-development,build-production

# ====================
# MOD_BUILDS.{module_name}
# Defines build names by module: it allows to produce many customized builds for a single module
# Every module has the following hidden default:
#  MOD_BUILDS.{module_name} := default
#
# Example:
#  MOD_BUILDS.mymodule := default mybuild

# ====================
# MOD_BUILDS_ARGS.{module_name}.{build_name}
# Defines build args for a build name: this effectively customizes the args to apply to the build-command
#
# Example:
#  MOD_BUILDS_ARGS.mymodule.default := -P profileA
#  MOD_BUILDS_ARGS.mymodule.mybuild := -P profileB

# ====================
# MOD_BUILDS_TGTFOLDER.{module_name}.{build_name}
# Optionally defines a target folder where to copy, after build process, generated artifact to
#
# Example:
#  MOD_BUILDS_TGTFOLDER.mymodule.mybuild := $(shell pwd)/target-wars
MOD_BUILDS_TGTFOLDER.webtop-webapp.default	:= $(TARGET_WARS_DIR)

# ====================
# Git keeps asking me for my ssh key passphrase?
# https://stackoverflow.com/questions/10032461/git-keeps-asking-me-for-my-ssh-key-passphrase
# https://docs.github.com/en/authentication/connecting-to-github-with-ssh/working-with-ssh-key-passphrases#auto-launching-ssh-agent-on-git-for-windows
# - Start SSH Agent
#   eval $(ssh-agent)
# - Start SSH Agent
#   ssh-add ~/.ssh/id_rsa

ifeq ($(BUILD_TYPE),)
	BUILD_TYPE := production
endif
ifeq ($(DEFAULT_GIT_BRANCH),)
	DEFAULT_GIT_BRANCH := master
endif
ifeq ($(DEFAULT_GIT_BRANCH_EXTRA),)
	DEFAULT_GIT_BRANCH_EXTRA := master
endif
ifeq ($(DEFAULT_CLONE_BASEURL),)
	DEFAULT_CLONE_BASEURL := https://github.com/sonicle-webtop
endif
ifeq ($(DEFAULT_SENCHATOOLS_VERSION),)
	DEFAULT_SENCHATOOLS_VERSION :=
endif

# ====================
# Variables targetting binaries
ifeq ($(AWK),)
	AWK := awk
endif
ifeq ($(TAR),)
	TAR := tar
endif
ifeq ($(GREP),)
	GREP := grep
endif
ifeq ($(SED),)
	SED := sed
endif
ifeq ($(GIT),)
	GIT := git
endif
ifeq ($(MVN),)
	MVN := mvn
endif

ifeq ($(MVN_ARGS),)
	MVN_ARGS := -T 4 -Dmaven.test.skip=true
endif
ifeq ($(MVN_USERHOME),)
	MVN_USERHOME := `$(MVN) $(MVN_ARGS) help:evaluate -Dexpression=user.home -q -DforceStdout`
endif

ifeq ($(OS),Windows_NT)
	detected_OS := Windows
else
	detected_OS := $(shell sh -c 'uname 2>/dev/null || echo Unknown')
endif

# ====================

.DEFAULT_GOAL := help
.DEFAULT: help
.PHONY: help
.HELP: help ## Prints this help message
help:
	@echo -e "$$($(GREP) -hE '^.HELP:.*##' $(MAKEFILE_LIST) | sort | $(SED) -e 's/^\.HELP:\s*//' -e 's/\s*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | $(AWK) -F':' '{$$1 = sprintf("%-40s", $$1)} 1')"
##@echo -e "$$($(GREP) -hE '^.HELP:.*##' $(MAKEFILE_LIST) | sort | $(SED) -e 's/^\.HELP:\s*//' -e 's/\s*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)"

.PHONY: setup
.HELP: setup ## Setup the entire build workspace - clone required modules and prepare SenchaTools
setup: setup-modules setup-senchatools

.PHONY: setup-senchatools
.HELP: setup-senchatools ## Prepare SenchaTools (Cmd and workspace for ExtJS), they will be available into 'sencha-XXX' folder [[SENCHATOOLS_VERSION] = prepare only specific tools version]
setup-senchatools:
	@{ \
	set -e; \
	is_git=0; \
	if [[ -f "$(WORKSPACE_DIR)/.git/config" ]]; then \
		is_git=1; \
	fi; \
	version="$(DEFAULT_SENCHATOOLS_VERSION)"; \
	if [[ "$(TARGET_SENCHATOOLS_VERSION)" != "" ]]; then \
		version="$(TARGET_SENCHATOOLS_VERSION)"; \
	fi; \
	ossuffix=""; \
	if [[ "$(detected_OS)" == "Windows" ]]; then \
		ossuffix="-windows"; \
	elif [[ "$(detected_OS)" != "Unknown" ]]; then \
		ossuffix="-linux"; \
	fi; \
	if [[ "$$version" == "" ]] || [[ "$$version" == "750" ]]; then \
		wksp_filename="senchatools-workspace-750.tar.bz2"; \
		cmd_filename="senchatools-cmd-750$$ossuffix.tar.bz2"; \
		echo -e "$(cCYAN)[senchatools-750]$(cRESET)"; \
		if [[ $$is_git -eq 1 ]]; then \
			$(SUB-MAKE) __TARGET_FILE="$(FILES_DIRNAME)/$$wksp_filename" __gitlfs-pullpointer; \
			$(SUB-MAKE) __TARGET_FILE="$(FILES_DIRNAME)/$$cmd_filename" __gitlfs-pullpointer; \
		fi; \
		$(SUB-MAKE) __SENCHATOOLS_TGTFOLDERNAME="sencha-750" __SENCHATOOLS_WKSP_ARCHIVENAME="$$wksp_filename" __SENCHATOOLS_CMD_ARCHIVENAME="$$cmd_filename" __SENCHATOOLS_TGTPROP="sencha75" __extract-senchatools; \
	fi; \
	if [[ "$$version" == "" ]] || [[ "$$version" == "620" ]]; then \
		wksp_filename="senchatools-workspace-620.tar.bz2"; \
		cmd_filename="senchatools-cmd-750$$ossuffix.tar.bz2"; \
		echo -e "$(cCYAN)[senchatools-620]$(cRESET)"; \
		if [[ $$is_git -eq 1 ]]; then \
			$(SUB-MAKE) __TARGET_FILE="$(FILES_DIRNAME)/$$wksp_filename" __gitlfs-pullpointer; \
			$(SUB-MAKE) __TARGET_FILE="$(FILES_DIRNAME)/$$cmd_filename" __gitlfs-pullpointer; \
		fi; \
		$(SUB-MAKE) __SENCHATOOLS_TGTFOLDERNAME="sencha-620" __SENCHATOOLS_WKSP_ARCHIVENAME="$$wksp_filename" __SENCHATOOLS_CMD_ARCHIVENAME="$$cmd_filename" __SENCHATOOLS_TGTPROP="sencha" __extract-senchatools; \
	fi; \
	}

.PHONY: setup-senchatools-links
.HELP: setup-senchatools-links ## Prepare SenchaTools - (do NOT use) setup symlinks for ExtJS package [[TARGET_SENCHATOOLS_FOLDER] = senchatools folder-name in which create links]
setup-senchatools-links: __check-modules-dir
	@{ \
	set -e; \
	if [[ "$(TARGET_SENCHATOOLS_FOLDER)" == "" ]]; then \
		echo -e "Parameter variable 'TARGET_SENCHATOOLS_FOLDER' NOT defined"; \
		exit 255; \
	fi; \
	if [[ ! -d "$(WORKSPACE_DIR)/$(TARGET_SENCHATOOLS_FOLDER)" ]]; then \
		echo -e "'$(TARGET_SENCHATOOLS_FOLDER)' directory does not exist"; \
		exit 1; \
	fi; \
	if [[ ! -d "$(WORKSPACE_DIR)/$(MODULES_FOLDER)/sonicle-extjs-extensions" ]]; then \
		echo -e "'$(MODULES_FOLDER)/sonicle-extjs-extensions' directory does not exist"; \
		exit 1; \
	fi; \
	sources_dir="$(WORKSPACE_DIR)/$(MODULES_FOLDER)/sonicle-extjs-extensions/src/sencha/sonicle-extensions"; \
	localpkgs_dir="$(WORKSPACE_DIR)/$(TARGET_SENCHATOOLS_FOLDER)/workspace/packages/local"; \
	local_dir="$$localpkgs_dir/sonicle-extensions"; \
	echo -e "Creating dir 'sonicle-extensions' into '$$localpkgs_dir'..."; \
	rm -rf "$$local_dir"; \
	mkdir -p "$$local_dir"; \
	echo -e "Linking each files and folders under '$$sources_dir'..."; \
	cd $$sources_dir; \
	for file in `ls -d */ .[^.]*/`; do \
		bfile=`basename $$file`; \
		ln -s "$$sources_dir/$$bfile" "$$local_dir/$$bfile"; \
	done; \
	for file in `ls -pA | grep -v /`; do \
		ln -s "$$sources_dir/$$file" "$$local_dir/$$file"; \
	done; \
	cd $(WORKSPACE_DIR); \
	}

.PHONY: setup-modules
.HELP: setup-modules ## Setup modules cloning them into this workspace
setup-modules: __setup-git __setup-folders
	@{ \
	set -e; \
	for comp in $(TOOLS) $(COMPONENTS) $(COMPONENTS_COM) $(SERVERS) $(WEBAPPS) $(DOCS); do \
		if [ ! -d "$(MODULES_FOLDER)/$$comp" ]; then \
			echo -e "$(cCYAN)[$$comp]$(cRESET)"; \
			$(SUB-MAKE) __MODULE="$$comp" __MODULE_BASEURL="MOD_CLONEBASEURL.$$comp" __MODULE_FLAGS="MOD_FLAGS.$$comp" __TARGET_BRANCH="$(DEFAULT_GIT_BRANCH)" __module-clone; \
		fi; \
	done; \
	for comp in $(COMPONENTS_EXTRA); do \
		if [ ! -d "$(EXTRA_MODULES_DIR)/$$comp" ]; then \
			echo -e "$(cCYAN)[$$comp]$(cRESET)"; \
			$(SUB-MAKE) __MODULE="$$comp" __MODULE_BASEURL="MOD_CLONEBASEURL.$$comp" __MODULE_FLAGS="MOD_FLAGS.$$comp" __TARGET_BRANCH="$(DEFAULT_GIT_BRANCH_EXTRA)" __module-clone; \
		fi; \
	done; \
	}

.PHONY: checkout
.HELP: checkout ## Updates each local module (except docs), keeping branch and pulling changes from respective remotes
checkout: __check-modules-dir
	@{ \
	set -e; \
	cd $(MODULES_FOLDER); \
	for comp in $(TOOLS) $(COMPONENTS) $(COMPONENTS_COM) $(SERVERS) $(WEBAPPS); do \
		echo -e "$(cCYAN)[$$comp]$(cRESET)"; \
		cd "$$comp"; \
		$(GIT) pull; \
		if [[ "$$?" -ne 0 ]]; then \
			exit $$?; \
		fi; \
		cd ..; \
	done; \
	cd ..; \
	}

.PHONY: checkout-branch
.HELP: checkout-branch ## Updates each local module (except docs and tools), switching to specified branch, if present, and pulling changes [TARGET_BRANCH = branch to checkout]
checkout-branch: __check-modules-dir
	@{ \
	set -e; \
	if [[ "$(TARGET_BRANCH)" == "" ]]; then \
		echo -e "Parameter variable 'TARGET_BRANCH' NOT defined"; \
		exit 255; \
	fi; \
	for comp in $(COMPONENTS) $(COMPONENTS_COM) $(SERVERS) $(WEBAPPS); do \
		echo -e "$(cCYAN)[$$comp]$(cRESET)"; \
		$(SUB-MAKE) __MODULE="$$comp" __MODULE_FLAGS="MOD_FLAGS.$$comp" __TARGET_BRANCH="$(TARGET_BRANCH)" __DEFAULT_BRANCH="$(TARGET_BRANCH)" __module-pull; \
	done; \
	}

.PHONY: checkout-tag
.HELP: checkout-tag ## Updates each local module (except docs and tools), switching to specified tag, if present [TARGET_TAG = tag to checkout]
checkout-tag: __check-modules-dir
	@{ \
	set -e; \
	if [[ "$(TARGET_TAG)" == "" ]]; then \
		echo -e "Parameter variable 'TARGET_TAG' NOT defined"; \
		exit 255; \
	fi; \
	for comp in $(COMPONENTS) $(COMPONENTS_COM) $(SERVERS) $(WEBAPPS); do \
		echo -e "$(cCYAN)[$$comp]$(cRESET)"; \
		$(SUB-MAKE) __MODULE="$$comp" __MODULE_FLAGS="MOD_FLAGS.$$comp" __TARGET_TAG="$(TARGET_TAG)" __DEFAULT_BRANCH="master" __module-pull; \
	done; \
	}

.PHONY: checkout-master
.HELP: checkout-master ## Updates each local module (except docs and tools), switching to 'master' and pulling changes from respective remotes
checkout-master: __check-modules-dir
	@{ \
	set -e; \
	for comp in $(COMPONENTS) $(COMPONENTS_COM) $(SERVERS) $(WEBAPPS); do \
		echo -e "$(cCYAN)[$$comp]$(cRESET)"; \
		$(SUB-MAKE) __MODULE="$$comp" __MODULE_FLAGS="MOD_FLAGS.$$comp" __TARGET_BRANCH="master" __DEFAULT_BRANCH="master" __module-pull; \
	done; \
	}

.PHONY: checkout-develop
.HELP: checkout-develop ## Updates each local module (except docs and tools), switching to 'develop' (if present) and pulling changes from respective remotes
checkout-develop: __check-modules-dir
	@{ \
	set -e; \
	for comp in $(COMPONENTS) $(COMPONENTS_COM) $(SERVERS) $(WEBAPPS); do \
		echo -e "$(cCYAN)[$$comp]$(cRESET)"; \
		$(SUB-MAKE) __MODULE="$$comp" __MODULE_FLAGS="MOD_FLAGS.$$comp" __TARGET_BRANCH="develop" __DEFAULT_BRANCH="master" __module-pull; \
	done; \
	}

.PHONY: checkout-release
.HELP: checkout-release ## Updates each local module (except docs and tools), switching to 'release' (if present) and pulling changes from respective remotes
checkout-release: __check-modules-dir
	@{ \
	set -e; \
	for comp in $(COMPONENTS) $(COMPONENTS_COM) $(SERVERS) $(WEBAPPS); do \
		echo -e "$(cCYAN)[$$comp]$(cRESET)"; \
		$(SUB-MAKE) __MODULE="$$comp" __MODULE_FLAGS="MOD_FLAGS.$$comp" __TARGET_BRANCH="release" __DEFAULT_BRANCH="master" __module-pull; \
	done; \
	}

.PHONY: modules-listbranch
.HELP: modules-listbranch ## List branches for each local module (except docs and tools)
modules-listbranch: __check-modules-dir
	@{ \
	set -e; \
	for comp in $(COMPONENTS) $(COMPONENTS_COM) $(SERVERS) $(WEBAPPS); do \
		echo -e "$(cCYAN)[$$comp]$(cRESET)"; \
		cd "$(MODULES_FOLDER)/$$comp"; \
		$(GIT) branch; \
		cd ../..; \
	done; \
	}

.PHONY: build
.HELP: build ## Build tools, components, webapps and servers modules
build: tools-build components-build webapps-build servers-build

.PHONY: tools-build
.HELP: tools-build ## Build tools modules only
tools-build: __check-modules-dir
	@{ \
	set -e; \
	$(call msgts,"[$@] Started at"); \
	set -e; \
	for comp in $(TOOLS); do \
		echo -e "$(cCYAN)[$$comp]$(cRESET)"; \
		$(SUB-MAKE) __MODULE="$$comp" __module-build; \
	done; \
	$(call msgts,"[$@] Ended at"); \
	}

.PHONY: components-build
.HELP: components-build ## Build components modules only [[TARGET_COMPONENT] = component to build, [START_COMPONENT] = start build from component]
components-build: __check-modules-dir
	@{ \
	set -e; \
	$(call msgts,"[$@] Started at"); \
	set -e; \
	comps="$(COMPONENTS) $(COMPONENTS_COM)"; \
	if [[ "$(TARGET_COMPONENT)" != "" ]] || [[ "$(START_COMPONENT)" != "" ]]; then \
		comps=""; \
		append=false; \
		for comp in $(COMPONENTS) $(COMPONENTS_COM); do \
			if [[ $$comp == "$(TARGET_COMPONENT)" ]]; then \
				comps=$$comp; \
				break; \
			elif [[ $$comp == "$(START_COMPONENT)" ]]; then \
				comps+="$$comp "; \
				append=true; \
			elif [[ $$append == "true" ]]; then \
				comps+="$$comp "; \
			fi; \
		done; \
	fi; \
	for comp in $$comps; do \
		echo -e "$(cCYAN)[$$comp]$(cRESET)"; \
		$(SUB-MAKE) __MODULE="$$comp" __MODULE_FLAGS="MOD_FLAGS.$$comp" __MODULE_BUILDS="MOD_BUILDS.$$comp" __BUILD_TYPE="$(BUILD_TYPE)" __module-build-foreach; \
		#$(SUB-MAKE) __MODULE="$$comp" __MODULE_FLAGS="MOD_FLAGS.$$comp" __MODULE_BUILDARGS="MOD_BUILDARGS.$$comp" __BUILD_TYPE="$(BUILD_TYPE)" __module-build; \
	done; \
	$(call msgts,"[$@] Ended at"); \
	}

.PHONY: components-revertchanges
.HELP: components-revertchanges ## Revert modifications in each component module
components-revertchanges: __check-modules-dir
	@{ \
	set -e; \
	for comp in $(COMPONENTS) $(COMPONENTS_COM); do \
		echo -e "$(cCYAN)[$$comp]$(cRESET)"; \
		$(SUB-MAKE) __MODULE="$$comp" __module-revertchanges; \
	done; \
	}

.PHONY: webapps-build
.HELP: webapps-build ## Build webapps modules only
webapps-build: __check-modules-dir __ensure-targetwars-dir
	@{ \
	set -e; \
	$(call msgts,"[$@] Started at"); \
	rm -f "$(TARGET_WARS_DIR)/*.*"; \
	for comp in $(WEBAPPS); do \
		echo -e "$(cCYAN)[$$comp]$(cRESET)"; \
		$(SUB-MAKE) __MODULE="$$comp" __MODULE_FLAGS="MOD_FLAGS.$$comp" __MODULE_BUILDS="MOD_BUILDS.$$comp" __BUILD_TYPE="$(BUILD_TYPE)" __module-build-foreach; \
		#$(SUB-MAKE) __MODULE="$$comp" __MODULE_FLAGS="MOD_FLAGS.$$comp" __MODULE_BUILDARGS="MOD_BUILDARGS.$$comp" __BUILD_TYPE="$(BUILD_TYPE)" __module-build; \
	done; \
	$(call msgts,"[$@] Ended at"); \
	}

.PHONY: webapps-revertchanges
.HELP: webapps-revertchanges ## Revert modifications in each webapp modules (typical after setting versions)
webapps-revertchanges: __check-modules-dir
	@{ \
	set -e; \
	for comp in $(WEBAPPS); do \
		echo -e "$(cCYAN)[$$comp]$(cRESET)"; \
		$(SUB-MAKE) __MODULE="$$comp" __module-revertchanges; \
	done; \
	}

.PHONY: servers-build
.HELP: servers-build ## Build servers modules only packaging them into suitable archive
servers-build: __check-modules-dir __ensure-targetservers-dir
	@{ \
	set -e; \
	$(call msgts,"[$@] Started at"); \
	rm -f "$(TARGET_SERVERS_DIR)/*.*"; \
	cd $(MODULES_FOLDER); \
	for comp in $(SERVERS); do \
		echo -e "$(cCYAN)[$$comp]$(cRESET)"; \
		comp_version=`cat $$comp/src/VERSION`; \
		arcname="$$comp-$$comp_version.tgz"; \
		echo -e "Compressing as [$$arcname] on target folder [$(TARGET_SERVERS_DIR)]"; \
		cd "$$comp/src"; \
		rm -f "$(TARGET_SERVERS_DIR)/$$arcname"; \
		$(TAR) zcf "$(TARGET_SERVERS_DIR)/$$arcname" .; \
		cd ../..; \
	done; \
	cd ..; \
	$(call msgts,"[$@] Ended at"); \
	}

.PHONY: clean-localartifacts
.HELP: clean-localartifacts ## Cleans local Maven artifacts involved in this build (you MUST run a full-build after executing this)
clean-localartifacts:
	@{ \
	set -e; \
	$(call msgts,"[$@] Started at"); \
	repodir=`$(MVN) $(MVN_ARGS) help:evaluate -Dexpression=settings.localRepository -q -DforceStdout`; \
	echo -e "Local repository is located at '$$repodir'"; \
	if [[ -d "$$repodir" ]]; then \
		echo -e "Cleaning 'com.sonicle.extjs:*' artifacts..."; \
		rm -rf "$$repodir/com/sonicle/extjs"; \
		echo -e "Cleaning 'com.sonicle.webtop:*' artifacts..."; \
		rm -rf "$$repodir/com/sonicle/webtop"; \
	fi; \
	$(call msgts,"[$@] Ended at"); \
	}
#com.sonicle.maven:sonicle-superpom

# Call me as sub-make
.PHONY: __tomcat-deploy
__tomcat-deploy:
	@{ \
	echo -e "Uploading $(__CONTEXT_NAME) on Tomcat [$(__TOMCAT_HOSTPORT)]"; \
	pathparam=`echo $(__CONTEXT_NAME) | $(SED) 's/#/%23/g'`; \
	curl --anyauth -u "$(__TOMCAT_USERPASS)" --upload-file "$(__WAR_FILE)" http://$(__TOMCAT_HOSTPORT)/manager/text/deploy?path=/$$pathparam; \
	if [[ "$$?" -ne 0 ]]; then \
		exit $$?; \
	fi; \
	}

# Call me as sub-make
.PHONY: __module-build-foreach
__module-build-foreach:
	@{ \
	set -e; \
	if [[ "$(__MODULE)" == "" ]]; then \
		echo -e "'__MODULE' is empty"; \
		exit 255; \
	fi; \
	builds="default"; \
	if [[ ! -z "$($(__MODULE_BUILDS))" ]]; then \
		builds="$($(__MODULE_BUILDS))"; \
	fi; \
	for build in $$builds ; do \
		echo -e "$(cCYAN)[$(__MODULE)::$$build]$(cRESET)"; \
		$(SUB-MAKE) __BUILD_NAME="$$build" __BUILD_TYPE="$(__BUILD_TYPE)" __BUILD_ARGS="$(__BUILD_ARGS)" __MODULE="$(__MODULE)" __MODULE_FLAGS="$(__MODULE_FLAGS)" __MODULE_BUILDARGS="MOD_BUILDS_ARGS.$(__MODULE).$$build" __MODULE_BUILDTGTFOLDER="MOD_BUILDS_TGTFOLDER.$(__MODULE).$$build" __module-build; \
		if [[ "$$?" -ne 0 ]]; then \
			exit $$?; \
		fi; \
	done; \
	}

# Call me as sub-make
.PHONY: __module-build
__module-build:
	@{ \
	set -e; \
	if [[ "$(__MODULE)" == "" ]]; then \
		echo -e "'__MODULE' is empty"; \
		exit 255; \
	fi; \
	cmd="$(MVN) $(MVN_ARGS) clean install"; \
	if [[ "$(__BUILD_TYPE)" == "production" ]] && [[ "$($(__MODULE_FLAGS))" == *"build-production"* ]]; then \
		cmd+=" -P profile-production"; \
	elif [[ "$(__BUILD_TYPE)" == "development" ]] && [[ "$($(__MODULE_FLAGS))" == *"build-development"* ]]; then \
		cmd+=" -P profile-development"; \
	fi; \
	if [[ "$($(__MODULE_FLAGS))" == *"build-reports"* ]]; then \
		cmd+=" -P build-reports"; \
	fi; \
	if [[ ! -z "$($(__MODULE_BUILDARGS))" ]]; then \
		cmd+=" $(strip $($(__MODULE_BUILDARGS)))"; \
	fi; \
	if [[ ! -z "$(__BUILD_ARGS)" ]]; then \
		cmd+=" $(strip $($(__BUILD_ARGS)))"; \
	fi; \
	cd "$(MODULES_FOLDER)/$(__MODULE)"; \
	#echo "$$cmd"; \
	echo "$$cmd" && $$cmd; \
	if [[ "$$?" -ne 0 ]]; then \
		exit $$?; \
	fi; \
	if [[ ! -z "$($(__MODULE_BUILDTGTFOLDER))" ]]; then \
		if [[ ! -d "$($(__MODULE_BUILDTGTFOLDER))" ]]; then \
			echo "'$($(__MODULE_BUILDTGTFOLDER))' directory does not exist"; \
			exit 1; \
		fi; \
		suffix="_$(__BUILD_NAME)"; \
		for filename in `ls -p target | $(GREP) -v /` ; do \
			file="target/$$filename"; \
			ext=`echo $$filename | $(AWK) -F . '{print $$NF}'`; \
			bname=`basename $$filename .$$ext`; \
			newname=`echo $$bname$$suffix.$$ext`; \
			newfile="$($(__MODULE_BUILDTGTFOLDER))/$$newname"; \
			if [[ -f "$$newfile" ]]; then \
				rm "$$newfile"; \
			fi; \
			echo -e "Copying '$$file' to '$$newfile'..."; \
			cp "$$file" "$$newfile"; \
			if [[ "$$?" -ne 0 ]]; then \
				exit $$?; \
			fi; \
		done; \
	fi; \
	cd ../..; \
	}

# Call me as sub-make
.PHONY: __module-merge
__module-merge:
	@{ \
	set -e; \
	if [[ "$(__MODULE)" == "" ]]; then \
		echo -e "'__MODULE' is empty"; \
		exit 255; \
	fi; \
	if [[ -z "$(__BASE_BRANCH)" ]]; then \
		echo -e "Variable '__BASE_BRANCH' is not defined"; \
		exit 255; \
	fi; \
	if [[ -z "$(__SOURCE_BRANCH)" ]]; then \
		echo -e "Variable '__SOURCE_BRANCH' is not defined"; \
		exit 255; \
	fi; \
	src_branch=""; \
	if [[ "$(__SOURCE_BRANCH)" == "release" ]] && [[ "$($(__MODULE_FLAGS))" == *"git-release"* ]]; then \
		src_branch="release"; \
	elif [[ "$(__SOURCE_BRANCH)" == "develop" ]] && [[ "$($(__MODULE_FLAGS))" == *"git-develop"* ]]; then \
		src_branch="develop"; \
	elif [[ "$(__SOURCE_BRANCH)" == "master" ]]; then \
		src_branch="master"; \
	fi; \
	dst_branch=""; \
	if [[ "$(__BASE_BRANCH)" == "release" ]] && [[ "$($(__MODULE_FLAGS))" == *"git-release"* ]]; then \
		dst_branch="release"; \
	elif [[ "$(__BASE_BRANCH)" == "develop" ]] && [[ "$($(__MODULE_FLAGS))" == *"git-develop"* ]]; then \
		dst_branch="develop"; \
	elif [[ "$(__BASE_BRANCH)" == "master" ]]; then \
		dst_branch="master"; \
	fi; \
	if [[ src_branch != "" ]] && [[ dst_branch != "" ]]; then \
		cd "$(MODULES_FOLDER)/$(__MODULE)"; \
		$(GIT) checkout $$src_branch && $(GIT) pull; \
		if [[ "$$?" -ne 0 ]]; then \
			exit $$?; \
		fi; \
		$(GIT) checkout $$dst_branch && $(GIT) pull; \
		if [[ "$$?" -ne 0 ]]; then \
			exit $$?; \
		fi; \
		$(GIT) merge $$src_branch; \
		if [[ "$$?" -ne 0 ]]; then \
			exit $$?; \
		fi; \
		cd ../..; \
	fi; \
	}

# Call me as sub-make
.PHONY: __module-revertchanges
__module-revertchanges:
	@{ \
	set -e; \
	if [[ "$(__MODULE)" == "" ]]; then \
		echo -e "'__MODULE' is empty"; \
		exit 255; \
	fi; \
	cd "$(MODULES_FOLDER)/$(__MODULE)"; \
	$(GIT) clean -fd . && $(GIT) checkout -- .; \
	if [[ "$$?" -ne 0 ]]; then \
		exit $$?; \
	fi; \
	cd ../..; \
	}

# Call me as sub-make
.PHONY: __module-commit
__module-commit:
	@{ \
	set -e; \
	if [[ "$(__MODULE)" == "" ]]; then \
		echo -e "'__MODULE' is empty"; \
		exit 255; \
	fi; \
	if [[ "$(__COMMIT_MESSAGE)" == "" ]]; then \
		echo -e "'__COMMIT_MESSAGE' is empty"; \
		exit 255; \
	fi; \
	cd "$(MODULES_FOLDER)/$(__MODULE)"; \
	$(GIT) add --all && $(GIT) commit -m "$(__COMMIT_MESSAGE)"; \
	if [[ "$$?" -ne 0 ]]; then \
		exit $$?; \
	fi; \
	cd ../..; \
	}

# Call me as sub-make
.PHONY: __module-tag
__module-tag:
	@{ \
	set -e; \
	if [[ "$(__MODULE)" == "" ]]; then \
		echo -e "'__MODULE' is empty"; \
		exit 255; \
	fi; \
	if [[ "$(__TAG_NAME)" == "" ]]; then \
		echo -e "'__TAG_NAME' is empty"; \
		exit 255; \
	fi; \
	if [[ "$(__TAG_MESSAGE)" == "" ]]; then \
		echo -e "'__TAG_MESSAGE' is empty"; \
		exit 255; \
	fi; \
	cd "$(MODULES_FOLDER)/$(__MODULE)"; \
	$(GIT) tag -a "$(__TAG_NAME)" -m "$(__TAG_MESSAGE)"; \
	if [[ "$$?" -ne 0 ]]; then \
		exit $$?; \
	fi; \
	cd ../..; \
	}

# Call me as sub-make
.PHONY: __module-pull
__module-pull:
	@{ \
	if [[ "$(__MODULE)" == "" ]]; then \
		echo -e "'__MODULE' is empty"; \
		exit 255; \
	fi; \
	branch=""; \
	if [[ "$(__TARGET_BRANCH)" == "release" ]] && [[ "$($(__MODULE_FLAGS))" == *"git-release"* ]]; then \
		branch="release"; \
	elif [[ "$(__TARGET_BRANCH)" == "develop" ]] && [[ "$($(__MODULE_FLAGS))" == *"git-develop"* ]]; then \
		branch="develop"; \
	elif [[ "$(__TARGET_BRANCH)" == "master" ]]; then \
		branch="master"; \
	else \
		branch="$(__DEFAULT_BRANCH)"; \
	fi; \
	tag="$(__TARGET_TAG)"; \
	if [[ "$$branch" != "" ]]; then \
		cd "$(MODULES_FOLDER)/$(__MODULE)"; \
		$(GIT) checkout $$branch && $(GIT) pull; \
		if [[ "$$?" -ne 0 ]]; then \
			exit $$?; \
		fi; \
		if [[ "$$tag" != "" ]]; then \
			set +e; \
			$(GIT) checkout tags/$$tag; \
			set -e; \
		fi; \
		cd ../..; \
	fi; \
	}

# Call me as sub-make
.PHONY: __module-push
__module-push:
	@{ \
	set -e; \
	if [[ "$(__MODULE)" == "" ]]; then \
		echo -e "'__MODULE' is empty"; \
		exit 255; \
	fi; \
	remote="origin"; \
	if [[ "$(__TARGET_REMOTE)" != "" ]]; then \
		remote="$(__TARGET_REMOTE)"; \
	fi; \
	branch=""; \
	if [[ "$(__TARGET_BRANCH)" == "release" ]] && [[ "$($(__MODULE_FLAGS))" == *"git-release"* ]]; then \
		branch="release"; \
	elif [[ "$(__TARGET_BRANCH)" == "develop" ]] && [[ "$($(__MODULE_FLAGS))" == *"git-develop"* ]]; then \
		branch="develop"; \
	elif [[ "$(__TARGET_BRANCH)" == "master" ]]; then \
		branch="master"; \
	else \
		branch="$(__DEFAULT_BRANCH)"; \
	fi; \
	cd "$(MODULES_FOLDER)/$(__MODULE)"; \
	if [[ "$$branch" != "" ]]; then \
		if [[ "$(__PUSH_TAGS)" == "true" ]]; then \
			$(GIT) checkout $$branch && $(GIT) push $$remote $$branch && $(GIT) push $$remote --tags -f; \
			if [[ "$$?" -ne 0 ]]; then \
				exit $$?; \
			fi; \
		else \
			$(GIT) checkout $$branch && $(GIT) push $$remote $$branch; \
			if [[ "$$?" -ne 0 ]]; then \
				exit $$?; \
			fi; \
		fi; \
	fi; \
	tag="$(__TARGET_TAG)"; \
	if [[ "$$tag" != "" ]]; then \
		$(GIT) push $$remote tag $$tag; \
		if [[ "$$?" -ne 0 ]]; then \
			exit $$?; \
		fi; \
	fi; \
	cd ../..; \
	}

# Call me as sub-make
.PHONY: __module-clone
__module-clone:
	@{ \
	set -e; \
	if [[ "$(__MODULE)" == "" ]]; then \
		echo -e "'__MODULE' is empty"; \
		exit 255; \
	fi; \
	branch="master"; \
	if [[ "$(__TARGET_BRANCH)" == "release" ]] && [[ "$($(__MODULE_FLAGS))" == *"git-release"* ]]; then \
		branch="release"; \
	elif [[ "$(__TARGET_BRANCH)" == "develop" ]] && [[ "$($(__MODULE_FLAGS))" == *"git-develop"* ]]; then \
		branch="develop"; \
	fi; \
	baseurl=$(DEFAULT_CLONE_BASEURL); \
	if [[ "$($(__MODULE_BASEURL))" != "" ]]; then \
		baseurl=$($(__MODULE_BASEURL)); \
	fi; \
	echo "$$baseurl/$(__MODULE).git"; \
	$(GIT) clone -b $$branch $$baseurl/$(__MODULE).git "./$(MODULES_FOLDER)/$(__MODULE)"; \
	if [[ "$$?" -ne 0 ]]; then \
		exit $$?; \
	fi; \
	}

# Call me as sub-make
.PHONY: __module-checkonbranch
__module-checkonbranch:
	@{ \
	set -e; \
	if [[ "$(__MODULE)" == "" ]]; then \
		echo -e "'__MODULE' is empty"; \
		exit 255; \
	fi; \
	if [[ "$(__TARGET_BRANCH)" == "" ]]; then \
		echo -e "'__TARGET_BRANCH' is empty"; \
		exit 255; \
	fi; \
	cd "$(MODULES_FOLDER)/$(__MODULE)"; \
	branch=`$(GIT) rev-parse --abbrev-ref HEAD`; \
	if [ "$$branch" != "$(__TARGET_BRANCH)" ]; then \
		echo -e "Current branch MUST be '$(__TARGET_BRANCH)'"; \
		exit 1; \
	fi; \
	cd ../..; \
	}

# Call me as sub-make
.PHONY: __gitlfs-pullpointer
__gitlfs-pullpointer:
	@{ \
	if [[ "$(__TARGET_FILE)" == "" ]]; then \
		echo -e "Parameter variable '__TARGET_FILE' NOT defined"; \
		exit 255; \
	fi; \
	if [[ ! -f "$(__TARGET_FILE)" ]]; then \
		echo -e "File '$(__TARGET_FILE)' not exists"; \
		exit 1; \
	fi; \
	$(GIT) lfs pointer --check --file "$(__TARGET_FILE)"; \
	if [[ "$$?" -eq 0 ]]; then \
		bfile=`basename $(__TARGET_FILE)`; \
		echo -e "Pulling file '$$bfile'..."; \
		$(GIT) lfs pull --include="$(__TARGET_FILE)"; \
		if [[ "$$?" -ne 0 ]]; then \
			exit $$?; \
		fi; \
	fi; \
	}

# Call me as sub-make
.PHONY: __transifex-do
__transifex-do:
	@{ \
	set -e; \
	if [[ "$(TARGET_OP)" == "push" ]] && [[ "$($(__MODULE_FLAGS))" == *"tx-push"* ]]; then \
		$(MVN) $(MVN_ARGS) -Ptransifex-push install; \
	elif [[ "$(TARGET_OP)" == "pull" ]] && [[ "$($(__MODULE_FLAGS))" == *"tx-pull"* ]]; then \
		$(MVN) $(MVN_ARGS) -Ptransifex-pull install; \
	fi; \
	if [[ "$$?" -ne 0 ]]; then \
		exit $$?; \
	fi; \
	}

# Call me as sub-make
.PHONY: __extract-senchatools
__extract-senchatools:
	@{ \
	set -e; \
	if [[ "$(__SENCHATOOLS_TGTFOLDERNAME)" == "" ]]; then \
		echo -e "'__SENCHATOOLS_TGTFOLDERNAME' is empty"; \
		exit 255; \
	fi; \
	if [[ "$(__SENCHATOOLS_WKSP_ARCHIVENAME)" == "" ]]; then \
		echo -e "'__SENCHATOOLS_WKSP_ARCHIVENAME' is empty"; \
		exit 255; \
	fi; \
	if [[ "$(__SENCHATOOLS_CMD_ARCHIVENAME)" == "" ]]; then \
		echo -e "'__SENCHATOOLS_CMD_ARCHIVENAME' is empty"; \
		exit 255; \
	fi; \
	if [[ "$(__SENCHATOOLS_TGTPROP)" == "" ]]; then \
		echo -e "'__SENCHATOOLS_TGTPROP' is empty"; \
		exit 255; \
	fi; \
	wksp_archivename="$(__SENCHATOOLS_WKSP_ARCHIVENAME)"; \
	if [[ ! -f "$(FILES_DIR)/$$wksp_archivename" ]]; then \
		echo -e "'$$wksp_archivename' archive file is missing"; \
		exit 1; \
	fi; \
	cmd_archivename="$(__SENCHATOOLS_CMD_ARCHIVENAME)"; \
	if [[ -f "$(FILES_DIR)/$(__SENCHATOOLS_CMD_OSARCHIVENAME)" ]]; then \
		cmd_archivename="$(__SENCHATOOLS_CMD_OSARCHIVENAME)"; \
	fi; \
	if [[ ! -f "$(FILES_DIR)/$$cmd_archivename" ]]; then \
		echo -e "'$$cmd_archivename' archive file is missing"; \
		exit 1; \
	fi; \
	if [[ ! -d "$(__SENCHATOOLS_TGTFOLDERNAME)" ]]; then \
		mkdir "$(__SENCHATOOLS_TGTFOLDERNAME)"; \
		toolsfolder="$(WORKSPACE_DIR)/$(__SENCHATOOLS_TGTFOLDERNAME)"; \
		echo -e "[workspace] Extracting $$wksp_archivename..."; \
		$(TAR) jxf "$(FILES_DIR)/$$wksp_archivename" -C "$$toolsfolder"; \
		if [[ "$$?" -ne 0 ]]; then \
			exit $$?; \
		fi; \
		echo -e "[cmd] Extracting $$cmd_archivename..."; \
		$(TAR) jxf "$(FILES_DIR)/$$cmd_archivename" -C "$$toolsfolder"; \
		if [[ "$$?" -ne 0 ]]; then \
			exit $$?; \
		fi; \
		echo -e "SenchaTools successfully extracted to '$$toolsfolder' folder."; \
		mvn_m2="$(MVN_USERHOME)/.m2"; \
		echo -e "Maven .m2 located at: '$$mvn_m2'"; \
		mkdir -p "$$mvn_m2"; \
		propfile="$$mvn_m2/$(__SENCHATOOLS_TGTPROP).properties"; \
		toolsfolder_real=$$toolsfolder; \
		if [[ $(IS_CYGWIN) -eq 1 ]]; then \
			toolsfolder_real=`cygpath -w "$$toolsfolder"`; \
			toolsfolder_real=$${toolsfolder_real//\\//};
		fi; \
		if [[ ! -f "$$propfile" ]]; then \
			echo "sencha.cmd=$$toolsfolder_real/cmd" > $$propfile; \
			echo "sencha.workspace=$$toolsfolder_real/workspace" >> $$propfile; \
			echo -e "Properties 'sencha.cmd' and 'sencha.workspace' written to '$$propfile' file."; \
		else \
			echo -e "File '$$propfile' already exists."; \
			echo -e "You can use the following properties for configure your '.properties' file:"; \
			echo -e "$(cGREEN)sencha.cmd=$$toolsfolder_real/cmd$(cRESET)"; \
			#echo -e "$(cGREEN)sencha.cmd=$$toolsfolder_real/cmd/$$cmdversion$(cRESET)"; \
			echo -e "$(cGREEN)sencha.workspace=$$toolsfolder_real/workspace$(cRESET)"; \
		fi; \
	else \
		echo -e "Folder '$(__SENCHATOOLS_TGTFOLDERNAME)' already exists."; \
	fi; \
	}

.PHONY: __check-modules-dir
__check-modules-dir:
	@{ \
	cd $(WORKSPACE_DIR); \
	if [ ! -d "$(MODULES_FOLDER)" ]; then \
		echo -e "'$(MODULES_FOLDER)' directory does not exist"; \
		echo -e "Run 'make setup' first"; \
		exit 1; \
	fi; \
	}

.PHONY: __ensure-targetservers-dir
__ensure-targetservers-dir:
	@{ \
	if [ ! -d "$(TARGET_SERVERS_DIR)" ]; then \
		mkdir $(TARGET_SERVERS_DIR); \
		if [[ "$$?" -ne 0 ]]; then \
			exit $$?; \
		fi; \
	fi; \
	}

.PHONY: __ensure-targetwars-dir
__ensure-targetwars-dir:
	@{ \
	if [ ! -d $(TARGET_WARS_DIR) ]; then \
		mkdir $(TARGET_WARS_DIR); \
		if [[ "$$?" -ne 0 ]]; then \
			exit $$?; \
		fi; \
	fi; \
	}

.PHONY: __check-prerequisites
__check-prerequisites:
	ifeq ($(GIT),)
	ifndef ($(shell command -v git 2> /dev/null))
	$(error "No 'git' command in PATH, please install it")
	endif
	endif
	ifneq ($(MVN),)
	ifndef ($(shell command -v mvn 2> /dev/null))
	$(error "No 'mvn' command in PATH, please install it")
	endif
	endif
	ifndef ($(shell command -v gawk 2> /dev/null))
	$(error "No 'gawk' command in PATH, please install it")
	endif
	ifndef ($(shell command -v sed 2> /dev/null))
	$(error "No 'sed' command in PATH, please install it")
	endif
	ifndef ($(shell command -v curl 2> /dev/null))
	$(error "No 'curl' command in PATH, please install it")
	endif

.PHONY: __setup-folders
__setup-folders:
	@{ \
	cd $(WORKSPACE_DIR); \
	if [[ ! -d "$(MODULES_FOLDER)" ]]; then \
		mkdir $(MODULES_FOLDER); \
	fi \
	if [[ ! -d "$(EXTRA_MODULES_FOLDER)" ]]; then \
		mkdir $(EXTRA_MODULES_FOLDER); \
	fi \
	}

.PHONY: __setup-git
__setup-git:
	@{ \
	value=`$(GIT) config --get core.autocrlf`; \
	if [[ $$value != "input" ]]; then \
		echo -e "$(cYELLOW)Git 'core.autocrlf' config will be set to 'input'\nCurrent value: $$value$(cRESET)"; \
		$(GIT) config --global core.autocrlf input; \
		#echo -e "$(cRED)UNCOMMENT ME: git config --global core.autocrlf input;$(cRESET)"; \
	fi; \
	value=`$(GIT) config --get core.filemode`; \
	if [[ $$value != "false" ]]; then \
		echo -e "$(cYELLOW)Git 'core.filemode' config will be set to 'false'\nCurrent value: $$value$(cRESET)"; \
		$(GIT) config --global core.filemode false; \
		#echo -e "$(cRED)UNCOMMENT ME: git config --global core.filemode false;$(cRESET)"; \
	fi; \
	}

define msgts
	echo -en "\x1b[36m$1\x1b[0m $(shell /bin/date "+%Y-%m-%d %H:%M:%S")";echo -e "\x1b[0m"
endef
