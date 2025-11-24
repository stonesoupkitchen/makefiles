# Helper variable to identify all images built by our container builder.
# Used in the `clean` target to remove all build artifacts.
CACHE = $(shell docker images --format '{{.Repository}}:{{.Tag}}' | \
        grep "$(REGISTRY)/$(REPOSITORY)")

