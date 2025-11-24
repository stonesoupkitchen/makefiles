# MIT License
# 
# Copyright (c) stonesoupkitchen/makefiles Contributors.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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
DATE = $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')

GIT_COMMIT = $(shell git rev-parse HEAD || echo "unknown")
GIT_SHA    = $(shell git rev-parse --short HEAD || echo "unknown")
GIT_BRANCH = $(shell git rev-parse --abbrev-ref HEAD || echo "unknown")
GIT_TAG    = $(shell git describe --tags --abbrev=0 --exact-match 2>/dev/null || echo "v0.0.0")

CLIFF_CONFIG ?= cliff.toml

# When generating changelogs with git-cliff,
# we sometimes override this value with the _next_
# tag from the tag-* targets.
#
# However, we still want the tasks to run independently,
# so we default the value to the current tag.
CLIFF_TAG ?= $(GIT_TAG)

IMAGE_NAME := "dummy"
REGISTRY   ?= docker.io
REPOSITORY := stonesoupkitchen/$(IMAGE_NAME)

TAGS := $(GIT_TAG)
TAGS += sha-$(GIT_SHA)

ARGS := --build-arg BUILD_DATE="$(DATE)"
ARGS += --build-arg GIT_COMMIT="$(GIT_COMMIT)"

PLATFORMS := "linux/amd64"

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

# Helper variable to identify all images built by our container builder.
# Used in the `clean` target to remove all build artifacts.
CACHE = $(shell docker images --format '{{.Repository}}:{{.Tag}}' | \
        grep "$(REGISTRY)/$(REPOSITORY)")

# TASKS
#//////////////////////////////////////////////////////////////////////////////
#
.PHONY: all
all: help

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
	docker rmi $(CACHE)

.PHONY: devenv
devenv: ## Initialize a development environment.

.PHONY: build
build: build-debug ## Build the project.

.PHONY: build-debug
build-debug: ## Create a debug build of the project.
	@docker build $(ARGS) -t $(REGISTRY)/$(REPOSITORY):latest .

.PHONY: build-release
build-release: ## Create a release build of the project.
	@docker build $(ARGS) -t $(REGISTRY)/$(REPOSITORY):latest --platform $(PLATFORMS) .
	@for tag in $(TAGS); do \
		docker tag $(REGISTRY)/$(REPOSITORY):latest $(REGISTRY)/$(REPOSITORY):$$tag ; \
		echo "Successfully tagged $(REGISTRY)/$(REPOSITORY):$$tag"
	done

.PHONY: fmt
fmt: require-dockerfmt ## Format source code.
	@dockerfmt Dockerfile

.PHONY: lint
lint: require-hadolint ## Lint source code for errors and smells.
	@hadolint Dockerfile

##@ Quality

.PHONY: quality
quality: fmt lint test ## Run all quality checks.

.PHONY: test
test: ## Run tests.

##@ Packaging

.PHONY: package
package: ## Create a redistributable package.

##@ Deployment

.PHONY: deploy
deploy: ## Deploy changes to a remote environment.

##@ Release Management

.PHONY: tag-major
tag-major: ## Increment major version (X.y.z -> X+1.0.0)
	$(eval NEW_VERSION := $(call increment_version,major))
	@echo "Bumping version from $(GIT_TAG) to $(NEW_VERSION)"
	@$(MAKE) changelog CLIFF_TAG=$(NEW_VERSION)
	@git add CHANGELOG.md
	@git commit -m "chore(release): Release v$(NEW_VERSION)"
	@git tag v$(NEW_VERSION)
	@echo "Version updated to $(NEW_VERSION) and tagged as v$(NEW_VERSION)"

.PHONY: tag-minor
tag-minor: ## Increment minor version (x.Y.z -> x.Y+1.0)
	$(eval NEW_VERSION := $(call increment_version,minor))
	@echo "Bumping version from $(GIT_TAG) to $(NEW_VERSION)"
	@$(MAKE) changelog CLIFF_TAG=$(NEW_VERSION)
	@git add CHANGELOG.md
	@git commit -m "chore(release): Release v$(NEW_VERSION)"
	@git tag v$(NEW_VERSION)
	@echo "Version updated to $(NEW_VERSION) and tagged as v$(NEW_VERSION)"

.PHONY: tag-patch
tag-patch: ## Increment patch version (x.y.Z -> x.y.Z+1)
	$(eval NEW_VERSION := $(call increment_version,patch))
	@echo "Bumping version from $(GIT_TAG) to $(NEW_VERSION)"
	@$(MAKE) changelog CLIFF_TAG=$(NEW_VERSION)
	@git add CHANGELOG.md
	@git commit -m "chore(release): Release v$(NEW_VERSION)"
	@git tag v$(NEW_VERSION)
	@echo "Version updated to $(NEW_VERSION) and tagged as v$(NEW_VERSION)"

.PHONY: changelog
changelog: require-git-cliff ## Generate the changelog.
	@git-cliff \
    --config "$(CLIFF_CONFIG)" \
    --output="CHANGELOG.md" \
    --tag "$(CLIFF_TAG)"

.PHONY: patch-notes
patch-notes: require-git-cliff ## Generate patch notes from unreleased changes.
	@git-cliff \
    --config "$(CLIFF_CONFIG)" \
    --unreleased \
    --tag "$(CLIFF_TAG)" \
    | tail -n+6

.PHONY: release-notes
release-notes: require-git-cliff ## Generate release notes from the current tag.
	@git-cliff \
    --config "$(CLIFF_CONFIG)" \
    --current \
    --tag "$(CLIFF_TAG)" \
    | tail -n+6

.PHONY: release
release: build-release ## Release container image.
	@for tag in $(TAGS); do \
		docker push $(REGISTRY)/$(REPOSITORY):$$tag ; \
	done

