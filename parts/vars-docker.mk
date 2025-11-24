IMAGE_NAME := "dummy"
REGISTRY   ?= docker.io
REPOSITORY := stonesoupkitchen/$(IMAGE_NAME)

TAGS := $(GIT_TAG)
TAGS += sha-$(GIT_SHA)

ARGS := --build-arg BUILD_DATE="$(DATE)"
ARGS += --build-arg GIT_COMMIT="$(GIT_COMMIT)"

PLATFORMS := "linux/amd64"

# Helper variable to identify all images built by our container builder.
# Used in the `clean` target to remove all build artifacts.
#
CACHE = $(shell docker images --format '{{.Repository}}:{{.Tag}}' | \
        grep "$(REGISTRY)/$(REPOSITORY)")

