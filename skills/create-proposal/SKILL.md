---
name: create-proposal
description: Use when adding or improving a workspace skill, modifying AGENT.md, SOUL.md, or USER.md, or archiving an applied proposal. Do not use for direct edits to /proposals/skills/ outside this workflow, HEARTBEAT.md, or .github/workflows/.
---

# Create Proposal

All changes to workspace skills and identity files flow through JJ stacks and
GitHub pull requests. Human approval via GitHub PR is a hard architectural constraint.

## When to Use

- Adding a new `/proposals/skills/` SKILL.md
- Improving an existing workspace skill
- Modifying AGENT.md, USER.md, or SOUL.md
- Steven explicitly asks for a proposal

**Do NOT use for:**
- HEARTBEAT.md (requires explicit out-of-band instruction)
- This file itself
- `.github/workflows/`
- `/notes/skills/` — Steven manages those directly

## GitHub Token

Get a token from the broker via the Makefile. Tokens are cached at
`/tmp/tachikoma-gh-token` for up to one hour.

```bash
eval $(make set-token)
```

If a GitHub operation returns 401/403, force-refresh and retry:
```bash
rm /tmp/tachikoma-gh-token
eval $(make set-token)
```

## Environment

- Workspace at `/proposals` is a JJ repo colocated with git
- Remote `origin` → `github.com/stevendaniels/tachikoma-workspace`
- `main` is branch-protected — you cannot push to it directly
- `jj`, `git`, `gh`, `curl`, and `make` are in your shell allowlist

See [references/jj-stacked-diffs.md](references/jj-stacked-diffs.md) for full JJ stacked-diff reference.

## Proposal Workflow

### Step 0: Navigate to the Proposals Repository

All commands in this skill must run from `/proposals`. Do this first:

```bash
cd /proposals
```

Do not proceed until your working directory is `/proposals`.

### Step 1: Check the Backlog

```bash
eval $(make set-token)
make check-backlog
```

If 3 or more proposals are open and unreviewed, stop. Message Steven:
> I have [N] proposals waiting for review before I can add more: [list each with title and PR URL]

### Step 2: Fetch and Confirm Clean State

```bash
make fetch
jj rebase -d main@origin    # bring work current with main
jj log -r 'main@origin..@'  # confirm stack position
jj status
```

If the working copy has unexpected changes, investigate before continuing.

### Step 3: Create the Change

```bash
# Standalone proposal
jj new main@origin -m "proposal: <short imperative description>

Co-authored-by: Claude Sonnet 4.6 <noreply@anthropic.com>"

# Dependent on a prior pending change
jj new <parent-change-id> -m "proposal: <description>

Co-authored-by: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

Use imperative mood. All proposal commits must have the `proposal:` prefix.
Use your actual model name in the co-author trailer (e.g., Sonnet 4.6, Opus 4.6).

### Step 4: Make the Change

Edit the target file using the **Edit tool** for existing files or **Write tool** for new files.
Use Bash only to create new directories (`mkdir -p`).

```bash
# New skill directory
mkdir -p /proposals/skills/new-skill
# Then use Write tool to create /proposals/skills/new-skill/SKILL.md
```

New SKILL.md files require at minimum: `# Skill: <name>`, `## Purpose`, `## When to Use`, `## Instructions`, `## Constraints`.

### Step 5: Push and Open the PR

```bash
make push-change

gh pr create \
  --title "proposal: <desc>" \
  --body "## What changed
$(jj diff --summary)

## Why
[1–2 sentences on motivation]

---
- [ ] Scoped to one file
- [ ] No new permissions requested
- [ ] Constraints section present (for new skills)" \
  --base main
```

For a stacked proposal dependent on another PR:
```bash
gh pr create \
  --title "proposal: <desc>" \
  --body "**Depends on:** #<parent-PR-number> — merge that first." \
  --base <parent-bookmark-name>
```

### Step 6: Message Steven

> **Proposal ready for review**
>
> **What:** [one sentence]
> **Why:** [one to two sentences]
> **File:** `skills/<name>/SKILL.md`
> **PR:** [URL]
>
> Merge to approve. Comment to request changes. Close to reject.

## After a Proposal Is Merged

```bash
eval $(make set-token)
make fetch

jj new main@origin -m "chore: post-merge sync

Co-authored-by: Claude Sonnet 4.6 <noreply@anthropic.com>"
make push-change
gh pr create --title "chore: post-merge sync" --body "Syncs stack after merged proposal." --base main
```

## Constraints

1. Never push to `main` directly
2. Never propose changes to this file or HEARTBEAT.md
3. Never propose changes to `.github/workflows/`
4. Maximum 3 open proposals at once
5. One logical change per PR
6. Never request new GitHub permissions in a proposal
7. Never self-merge
8. Never store or log GitHub tokens beyond the `/tmp/tachikoma-gh-token` cache

## Quick Reference

| Action | Command |
|--------|---------|
| Get/refresh token | `eval $(make set-token)` |
| Check backlog | `make check-backlog` |
| Fetch + rebase | `make fetch && jj rebase -d main@origin` |
| New standalone proposal | `jj new main@origin -m "proposal: <desc>\n\nCo-authored-by: ..."` |
| New dependent proposal | `jj new <parent-id> -m "proposal: <desc>\n\nCo-authored-by: ..."` |
| Push and open PR | `make push-change && gh pr create ...` |
| List open proposals | `gh pr list --repo stevendaniels/tachikoma-workspace` |
| Rebase stack | `jj rebase -d main@origin -r 'main@origin..@'` |

## Failure Modes

**Broker returns 403:** API key mismatch. Do not retry. Report to Steven.

**Broker unreachable:**
```bash
curl -sf -H "Authorization: Bearer ${GITHUB_TOKEN_BROKER_KEY}" \
  http://token-broker:9999/token | head -3
```
If connection refused, the broker container is down. Report to Steven.

**GitHub push rejected:** Token may have expired. Remove the cache file and re-run `set-token`, then retry once. If it fails again, report to Steven.

**Diff does not apply after main moved:**
```bash
make fetch
jj rebase -d main@origin -r 'main@origin..@'
jj diff   # verify rebased diff still makes sense
make push-change
```

**Merge conflict after rebase:**
```bash
jj status   # shows conflict markers
# Resolve manually, then:
jj describe
make push-change
```
If you cannot resolve cleanly, abandon and report: `jj abandon @`
## Change Log (proposed)

- Max unreviewed PRs: 10 (was 3)
- Use conventional-commit style message in commit title, keep `proposal:` prefix
- Each commit = 1 logical change (was "one logical change per PR")
- Repo = same JJ work-tree, no separate clone needed
- Standard `jj fetch && jj rebase -d main@origin` replaces `make fetch && jj rebase -d main@origin`