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

