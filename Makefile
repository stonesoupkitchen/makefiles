# PREAMBLE
#//////////////////////////////////////////////////////////////////////////////
#
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

# VARIABLES, CONFIG, & SETTINGS
#//////////////////////////////////////////////////////////////////////////////
#
DATE       = $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
GIT_COMMIT = $(shell git rev-parse HEAD || echo "unknown")
GIT_SHA    = $(shell git rev-parse --short HEAD || echo "unknown")
GIT_BRANCH = $(shell git rev-parse --abbrev-ref HEAD || echo "unknown")
GIT_TAG    = $(shell git describe --tags --abbrev=0 --exact-match 2>/dev/null || echo "v0.0.0")

CLIFF_CONFIG ?= cliff.toml

# HELPERS
#//////////////////////////////////////////////////////////////////////////////
#
define increment_version
$(shell echo $(GIT_TAG) | sed 's/^v//' | awk -F. -v part=$(1) '{
	if (part == "major") { print ($$1+1) ".0.0" }
	else if (part == "minor") { print $$1 "." ($$2+1) ".0" }
	else if (part == "patch") { print $$1 "." $$2 "." ($$3+1) }
}')
endef

.PHONY: require-git-cliff
require-git-cliff:
	@if ! command -v git-cliff >/dev/null 2>&1; then \
    echo "git-cliff not found. Install from:"; \
    echo "  Cargo: cargo install git-cliff"; \
    echo "  Homebrew: brew install git-cliff"; \
    echo "  GitHub: https://github.com/orhun/git-cliff/releases"; \
    exit 1; \
  fi

# TASKS
#//////////////////////////////////////////////////////////////////////////////
#
.PHONY: all
all: info

##@ General

.PHONY: help
help: ## Show this help message.
	@echo "Usage: make <TARGET>"
	@awk 'BEGIN {FS = ":.*?##"}; /^[a-zA-Z0-9_/-]+:.*?##/ { printf "    %-16s %s\n", $$1, $$2 } /^##@/ { printf "\n  [%s]\n\n", substr($$0, 5) }' $(MAKEFILE_LIST)

.PHONY: info
info: ## Show build and tool configurations.
	@echo "Date: $(DATE)"
	@echo ""
	@echo "Configuration:"
	@echo "  Version: $(GIT_TAG)"
	@echo "  Git SHA: $(GIT_SHA)"

##@ Development

.PHONY: clean
clean: ## Clean up all build and release artifacts.
	@rm -rf dist

.PHONY: devenv
devenv: ## Initialize a development environment.

.PHONY: build
build: ## Build the project.
build: dist/docker.mk
build: dist/template.mk

dist/docker.mk:
	@mkdir -p dist
	@sed -e 's/^/# /' LICENSE > dist/docker.mk
	@echo "" >> dist/docker.mk
	@cat parts/header-preamble.mk >> dist/docker.mk
	@cat parts/preamble.mk >> dist/docker.mk
	@cat parts/header-vars.mk >> dist/docker.mk
	@cat parts/vars-git.mk >> dist/docker.mk
	@cat parts/vars-cliff.mk >> dist/docker.mk
	@cat parts/vars-docker.mk >> dist/docker.mk
	@cat parts/header-helpers.mk >> dist/docker.mk
	@cat parts/helpers-release-git.mk >> dist/docker.mk
	@cat parts/helpers-release-cliff.mk >> dist/docker.mk
	@cat parts/helpers-docker.mk >> dist/docker.mk
	@cat parts/header-tasks.mk >> dist/docker.mk
	@echo "##@ General" >> dist/docker.mk
	@echo "" >> dist/docker.mk
	@cat parts/help.mk >> dist/docker.mk
	@cat parts/info-dummy.mk >> dist/docker.mk
	@echo "##@ Development" >> dist/docker.mk
	@echo "" >> dist/docker.mk
	@cat parts/development-docker.mk >> dist/docker.mk
	@echo "##@ Quality" >> dist/docker.mk
	@echo "" >> dist/docker.mk
	@cat parts/quality-docker.mk >> dist/docker.mk
	@echo "##@ Packaging" >> dist/docker.mk
	@echo "" >> dist/docker.mk
	@cat parts/package-dummy.mk >> dist/docker.mk
	@echo "##@ Deployment" >> dist/docker.mk
	@echo "" >> dist/docker.mk
	@cat parts/deploy-dummy.mk >> dist/docker.mk
	@echo "##@ Release Management" >> dist/docker.mk
	@echo "" >> dist/docker.mk
	@cat parts/release-git.mk >> dist/docker.mk
	@cat parts/release-cliff.mk >> dist/docker.mk
	@cat parts/release-docker.mk >> dist/docker.mk

dist/template.mk:
	@mkdir -p dist
	@sed -e 's/^/# /' LICENSE > dist/template.mk
	@echo "" >> dist/template.mk
	@cat parts/header-preamble.mk >> dist/template.mk
	@cat parts/preamble.mk >> dist/template.mk
	@cat parts/header-vars.mk >> dist/template.mk
	@cat parts/vars-git.mk >> dist/template.mk
	@cat parts/vars-cliff.mk >> dist/template.mk
	@cat parts/header-helpers.mk >> dist/template.mk
	@cat parts/helpers-release-git.mk >> dist/template.mk
	@cat parts/helpers-release-cliff.mk >> dist/template.mk
	@cat parts/header-tasks.mk >> dist/template.mk
	@echo "##@ General" >> dist/template.mk
	@echo "" >> dist/template.mk
	@cat parts/help.mk >> dist/template.mk
	@cat parts/info-dummy.mk >> dist/template.mk
	@echo "##@ Development" >> dist/template.mk
	@echo "" >> dist/template.mk
	@cat parts/development-dummy.mk >> dist/template.mk
	@echo "##@ Quality" >> dist/template.mk
	@echo "" >> dist/template.mk
	@cat parts/quality-dummy.mk >> dist/template.mk
	@echo "##@ Packaging" >> dist/template.mk
	@echo "" >> dist/template.mk
	@cat parts/package-dummy.mk >> dist/template.mk
	@echo "##@ Deployment" >> dist/template.mk
	@echo "" >> dist/template.mk
	@cat parts/deploy-dummy.mk >> dist/template.mk
	@echo "##@ Release Management" >> dist/template.mk
	@echo "" >> dist/template.mk
	@cat parts/release-git.mk >> dist/template.mk
	@cat parts/release-cliff.mk >> dist/template.mk

##@ Release Management

.PHONY: changelog
changelog: require-git-cliff ## Generate the changelog.
	@git-cliff \
    --config "$(CLIFF_CONFIG)" \
    --output="CHANGELOG.md" \
    --tag "$(GIT_TAG)"

.PHONY: patch-notes
patch-notes: require-git-cliff ## Generate patch notes from unreleased changes.
	@git-cliff \
    --config "$(CLIFF_CONFIG)" \
    --unreleased \
    --tag "$(GIT_TAG)" \
    | tail -n+6

.PHONY: release-notes
release-notes: require-git-cliff ## Generate release notes from the current tag.
	@git-cliff \
    --config "$(CLIFF_CONFIG)" \
    --current \
    --tag "$(GIT_TAG)" \
    | tail -n+6

.PHONY: tag-major
tag-major: ## Increment major version (X.y.z -> X+1.0.0)
	$(eval NEW_VERSION := $(call increment_version,major))
	@echo "Bumping version from $(GIT_TAG) to $(NEW_VERSION)"
	@$(MAKE) changelog
	@git add CHANGELOG.md
	@git commit -m "chore(release): Release v$(NEW_VERSION)"
	@git tag v$(NEW_VERSION)
	@echo "Version updated to $(NEW_VERSION) and tagged as v$(NEW_VERSION)"

.PHONY: tag-minor
tag-minor: ## Increment minor version (x.Y.z -> x.Y+1.0)
	$(eval NEW_VERSION := $(call increment_version,minor))
	@echo "Bumping version from $(GIT_TAG) to $(NEW_VERSION)"
	@$(MAKE) changelog
	@git add CHANGELOG.md
	@git commit -m "chore(release): Release v$(NEW_VERSION)"
	@git tag v$(NEW_VERSION)
	@echo "Version updated to $(NEW_VERSION) and tagged as v$(NEW_VERSION)"

.PHONY: tag-patch
tag-patch: ## Increment patch version (x.y.Z -> x.y.Z+1)
	$(eval NEW_VERSION := $(call increment_version,patch))
	@echo "Bumping version from $(GIT_TAG) to $(NEW_VERSION)"
	@$(MAKE) changelog
	@git add CHANGELOG.md
	@git commit -m "chore(release): Release v$(NEW_VERSION)"
	@git tag v$(NEW_VERSION)
	@echo "Version updated to $(NEW_VERSION) and tagged as v$(NEW_VERSION)"

