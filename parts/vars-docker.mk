IMAGE_NAME := "dummy"
REGISTRY   ?= docker.io
REPOSITORY := stonesoupkitchen/$(IMAGE_NAME)

TAGS := $(GIT_TAG)
TAGS += sha-$(GIT_SHA)

ARGS := --build-arg BUILD_DATE="$(DATE)"
ARGS += --build-arg GIT_COMMIT="$(GIT_COMMIT)"

PLATFORMS := "linux/amd64"

