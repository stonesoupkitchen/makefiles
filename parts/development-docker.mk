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

