CLIFF_CONFIG ?= cliff.toml

# When generating changelogs with git-cliff,
# we sometimes override this value with the _next_
# tag from the tag-* targets.
#
# However, we still want the tasks to run independently,
# so we default the value to the current tag.
CLIFF_TAG ?= $(GIT_TAG)

