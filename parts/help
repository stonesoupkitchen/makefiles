.PHONY: help
help: ## Show this help message.
	@echo "Usage: make <TARGET>"
	@awk 'BEGIN {FS = ":.*?##"}; /^[a-zA-Z0-9_/-]+:.*?##/ { printf "    %-16s %s\n", $$1, $$2 } /^##@/ { printf "\n  [%s]\n\n", substr($$0, 5) }' $(MAKEFILE_LIST)

