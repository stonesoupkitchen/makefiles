GIT_COMMIT = $(shell git rev-parse HEAD || echo "unknown")
GIT_SHA    = $(shell git rev-parse --short HEAD || echo "unknown")
GIT_BRANCH = $(shell git rev-parse --abbrev-ref HEAD || echo "unknown")
GIT_TAG    = $(shell git describe --tags --abbrev=0 --exact-match 2>/dev/null || echo "v0.0.0")

