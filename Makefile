REPO     := stevendaniels/tachikoma-workspace
BROKER   := http://token-broker:9999/token
TOKEN_CACHE := /tmp/tachikoma-gh-token

.PHONY: help
help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*##"}; {printf "  %-18s %s\n", $$1, $$2}'

.PHONY: get-token
get-token: ## Get or refresh GitHub token (cached up to 1 hour)
	@if [ -f "$(TOKEN_CACHE)" ]; then \
		age=$$(( $$(date +%s) - $$(stat -f %m "$(TOKEN_CACHE)" 2>/dev/null || stat -c %Y "$(TOKEN_CACHE)") )); \
		if [ $$age -lt 3600 ]; then \
			cat "$(TOKEN_CACHE)"; \
			exit 0; \
		fi; \
	fi; \
	curl -sf -H "Authorization: Bearer $${GITHUB_TOKEN_BROKER_KEY}" \
		"$(BROKER)" | jq -r .token | tee "$(TOKEN_CACHE)"

.PHONY: set-token
set-token: ## Export GH_TOKEN and GITHUB_TOKEN from cache (source this: eval $(make set-token))
	@TOKEN=$$(make -s get-token); \
	echo "export GH_TOKEN=$$TOKEN"; \
	echo "export GITHUB_TOKEN=$$TOKEN"

.PHONY: check-backlog
check-backlog: ## List open proposals and current JJ stack above main
	@eval $$(make -s set-token) && \
		gh pr list --repo $(REPO) && \
		jj log -r 'remote_bookmarks(exact:"origin/main")..heads()'

.PHONY: fetch
fetch: ## Fetch from origin
	jj git fetch --remote origin

.PHONY: status
status: ## Show JJ status and commits above main
	@jj status
	@echo ""
	@jj log -r 'main@origin..@'

.PHONY: rebase-main
rebase-main: ## Rebase current change onto latest main
	jj rebase -d main@origin

.PHONY: rebase-stack
rebase-stack: ## Rebase entire stack above main onto latest main
	jj rebase -d main@origin -r 'main@origin..@'

.PHONY: push-change
push-change: ## Push current change and set bookmark
	@eval $$(make -s set-token) && \
		jj git push --change @
