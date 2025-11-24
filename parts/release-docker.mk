.PHONY: release
release: build-release ## Release container image.
	@for tag in $(TAGS); do \
		docker push $(REGISTRY)/$(REPOSITORY):$$tag ; \
	done

