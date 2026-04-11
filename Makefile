REPO := stevendaniels/tachikoma-workspace

.PHONY: help
help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*##"}; {printf "  %-18s %s\n", $$1, $$2}'

.PHONY: check-backlog
check-backlog: ## List open proposals and current JJ stack above main
	@gh pr list --repo $(REPO)
	@jj log -r 'remote_bookmarks(exact:"origin/main")..heads()'

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
	jj git push --change @
