---
name: create-proposal
description: Use when adding or improving a workspace skill, modifying AGENT.md, SOUL.md, or USER.md, or archiving an applied proposal. Do not use for direct edits to /workspace/skills/ outside this workflow, HEARTBEAT.md, or .github/workflows/.
---

# Create Proposal

All changes to workspace skills and identity files flow through JJ stacks and
GitHub pull requests. Human approval via GitHub PR is a hard architectural constraint.

## When to Use

- Adding a new `/workspace/skills/` SKILL.md
- Improving an existing workspace skill
- Modifying AGENT.md, USER.md, or SOUL.md
- Running the weekly kaizen heartbeat (when explicitly instructed)
- Steven explicitly asks for a proposal

**Do NOT use for:**
- HEARTBEAT.md (requires explicit out-of-band instruction)
- This file itself
- `.github/workflows/`
- `/notes/skills/` — Steven manages those directly

## Getting a GitHub Token

You do not hold GitHub credentials. Get a fresh token from the broker at the
start of each proposal session. Do not cache or store it anywhere.

```bash
GITHUB_TOKEN=$(curl -sf \
  -H "Authorization: Bearer ${GITHUB_TOKEN_BROKER_KEY}" \
  http://token-broker:9999/token | jq -r .token)
export GITHUB_TOKEN
export GH_TOKEN=$GITHUB_TOKEN
```

Tokens expire in one hour. Get a fresh one per session.

## Environment

- Workspace at `/workspace` is a JJ repo colocated with git
- Remote `origin` → `github.com/stevendaniels/tachikoma-workspace`
- `main` is branch-protected — you cannot push to it directly
- `jj`, `git`, `gh`, and `curl` are in your shell allowlist

## Proposal Workflow

### Step 1: Check the Backlog

```bash
export GH_TOKEN=$(curl -sf \
  -H "Authorization: Bearer ${GITHUB_TOKEN_BROKER_KEY}" \
  http://token-broker:9999/token | jq -r .token)

gh pr list --repo stevendaniels/tachikoma-workspace
jj log -r 'remote_bookmarks(exact:"origin/main")..heads()'
```

If 3 or more proposals are open and unreviewed, stop. Message Steven:
> I have [N] proposals waiting for review before I can add more: [list each with title and PR URL]

### Step 2: Fetch and Confirm Clean State

```bash
cd /workspace
jj git fetch --remote origin
jj status
```

If the working copy has unexpected changes, investigate before continuing.

### Step 3: Create the Change

```bash
# Standalone proposal
jj new main@origin -m "proposal: <short imperative description>"

# Proposal dependent on a prior pending change
jj new <parent-change-id> -m "proposal: <description>"
```

Use imperative mood. All proposal commits must have the `proposal:` prefix.

### Step 4: Make the Change

Edit only the target file.

```bash
# Improve an existing skill
nano /workspace/skills/some-skill/SKILL.md

# Create a new skill
mkdir -p /workspace/skills/new-skill
nano /workspace/skills/new-skill/SKILL.md
```

New SKILL.md files require at minimum: `# Skill: <name>`, `## Purpose`, `## When to Use`, `## Instructions`, `## Constraints`.

### Step 5: Save the Diff

```bash
PROPOSAL_DATE=$(date +%Y-%m-%d)
PROPOSAL_DESC="<hyphenated-description>"

mkdir -p /workspace/proposals
jj diff > /workspace/proposals/${PROPOSAL_DATE}-${PROPOSAL_DESC}.diff
cat /workspace/proposals/${PROPOSAL_DATE}-${PROPOSAL_DESC}.diff
```

The diff file is committed with the change. It is the permanent audit record.

### Step 6: Push and Open the PR

```bash
export GH_TOKEN=$(curl -sf \
  -H "Authorization: Bearer ${GITHUB_TOKEN_BROKER_KEY}" \
  http://token-broker:9999/token | jq -r .token)

jj git push --change @

gh pr create \
  --title "proposal: ${PROPOSAL_DESC}" \
  --body "## What changed
$(jj diff --summary)

## Why
[1–2 sentences on motivation]

## Diff preview
\`\`\`diff
$(head -60 /workspace/proposals/${PROPOSAL_DATE}-${PROPOSAL_DESC}.diff)
\`\`\`

Full diff: \`proposals/${PROPOSAL_DATE}-${PROPOSAL_DESC}.diff\`

---
- [ ] Scoped to one file
- [ ] No new permissions requested
- [ ] Constraints section present (for new skills)
- [ ] Diff applies cleanly to current main" \
  --base main
```

### Step 7: Message Steven

> **Proposal ready for review**
>
> **What:** [one sentence]
> **Why:** [one to two sentences]
> **File:** `skills/<name>/SKILL.md`
> **PR:** [URL]
>
> Merge to approve. Comment to request changes. Close to reject.

## Stacked Proposals

When B cannot work without A being approved first:

```bash
jj new <change-id-of-A> -m "proposal: <description (requires A)>"
# ... edit, save diff, push ...
gh pr create \
  --title "proposal: <description>" \
  --body "**Depends on:** #<A's PR number> — merge that first." \
  --base main
```

State the dependency clearly in the Telegram message.

### Rebasing After Parent Was Revised

```bash
jj rebase -d <revised-parent-id> -r <child-id>
export GH_TOKEN=$(curl -sf \
  -H "Authorization: Bearer ${GITHUB_TOKEN_BROKER_KEY}" \
  http://token-broker:9999/token | jq -r .token)
jj git push --change <child-id>
```

## After a Proposal Is Merged

On the next interaction after Steven merges a PR:

```bash
cd /workspace
export GH_TOKEN=$(curl -sf \
  -H "Authorization: Bearer ${GITHUB_TOKEN_BROKER_KEY}" \
  http://token-broker:9999/token | jq -r .token)

jj git fetch --remote origin
mkdir -p /workspace/applied-proposals
mv /workspace/proposals/<date>-<desc>.diff /workspace/applied-proposals/

jj new main@origin -m "chore: archive applied proposal — <desc>"
jj git push --change @
gh pr create \
  --title "chore: archive applied proposal — <desc>" \
  --body "Moves applied diff to applied-proposals/ for audit trail." \
  --base main
```

## Constraints

1. Never push to `main` directly
2. Never propose changes to this file or HEARTBEAT.md
3. Never propose changes to `.github/workflows/`
4. Maximum 3 open proposals at once
5. One logical change per PR
6. Never request new GitHub permissions in a proposal
7. Diff file is mandatory before any `gh pr create`
8. Never self-merge
9. Never store or log GitHub tokens — get a fresh one each session

## Quick Reference

| Action | Command |
|--------|---------|
| Get token | `export GH_TOKEN=$(curl -sf -H "Authorization: Bearer ${GITHUB_TOKEN_BROKER_KEY}" http://token-broker:9999/token \| jq -r .token)` |
| New standalone proposal | `jj new main@origin -m "proposal: <desc>"` |
| New dependent proposal | `jj new <parent-id> -m "proposal: <desc>"` |
| Inspect change | `jj diff && jj status` |
| Push and open PR | `jj git push --change @ && gh pr create --title "proposal: <desc>" --base main` |
| List open proposals | `gh pr list --repo stevendaniels/tachikoma-workspace` |
| Rebase dependent | `jj rebase -d <new-parent-id> -r <child-id>` |

## Failure Modes

**Broker returns 403:** API key mismatch. Do not retry. Report to Steven.

**Broker unreachable:**
```bash
curl -s http://token-broker:9999/token | head -3
```
If connection refused, the broker container is down. Report to Steven.

**GitHub push rejected:** Token may have expired. Get a fresh one and retry once. If it fails again, report to Steven — do not attempt credential debugging.

**Diff does not apply after main moved:**
```bash
jj rebase -d main@origin -r @
jj diff   # verify the rebased diff still makes sense
jj git push --change @
```

**Merge conflict after rebase:**
```bash
jj status   # shows conflict markers
# Resolve manually, then:
jj describe
jj git push --change @
```
If you cannot resolve cleanly, abandon and report:
```bash
jj abandon @
```
