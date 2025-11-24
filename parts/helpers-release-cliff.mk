.PHONY: require-git-cliff
require-git-cliff:
	@if ! command -v git-cliff >/dev/null 2>&1; then \
    echo "git-cliff not found. Install from:"; \
    echo "  Cargo: cargo install git-cliff"; \
    echo "  Homebrew: brew install git-cliff"; \
    echo "  GitHub: https://github.com/orhun/git-cliff/releases"; \
    exit 1; \
  fi

