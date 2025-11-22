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

