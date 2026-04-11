# JJ Stacked Diffs Reference

JJ models history as a DAG of changes. A "stack" is a linear chain of changes where each
depends on the one before it. Each change gets its own PR; they merge in order.

## Viewing the Stack

```bash
jj log                                  # full graph
jj log -r 'main@origin..@'             # only your changes above main
jj show                                 # diff for current change (@)
jj show <change-id>                     # diff for a specific change
```

## Adding Changes to the Stack

```bash
# New standalone change on top of main
jj new main@origin -m "proposal: <desc>"

# New change stacked on top of current (@)
jj new @ -m "proposal: <desc>"

# New change stacked on a specific parent
jj new <change-id> -m "proposal: <desc>"
```

Always include the co-author trailer in the message:
```
proposal: <description>

Co-authored-by: Claude Sonnet 4.6 <noreply@anthropic.com>
```

## Editing a Prior Change in the Stack

```bash
jj edit <change-id>     # move working copy to that change
# ... make edits ...
jj next                 # return to the tip of the stack
```

Descendant changes rebase automatically.

## Creating PRs for a Stack

Push each change and open a PR targeting its parent's bookmark:

```bash
# Push the bottom change (A)
jj git push --change <change-id-A>
gh pr create --title "proposal: A" --base main

# Push the next change (B, depends on A)
jj git push --change <change-id-B>
gh pr create --title "proposal: B" --base <A-bookmark-name> \
  --body "**Depends on:** #<A-PR-number> — merge that first."
```

JJ names the bookmark after the change ID by default (e.g., `push-xxxxxxxx`).
Check with `jj bookmark list` if unsure.

## Rebasing the Stack When Main Moves

```bash
jj git fetch --remote origin

# Rebase entire stack
jj rebase -d main@origin -r 'main@origin..@'

# Re-push affected changes (force-push is safe here)
jj git push --change <change-id-A>
jj git push --change <change-id-B>
```

## Rebasing After a Parent Was Revised

```bash
jj rebase -d <revised-parent-id> -r <child-id>
jj git push --change <child-id>
```

## Squashing and Abandoning

```bash
jj squash                  # fold current change into its parent
jj squash -r <change-id>   # fold a specific change into its parent
jj abandon @               # discard current change (descendants rebase up)
jj abandon <change-id>     # discard a specific change
```

## Resolving Conflicts After Rebase

```bash
jj status          # shows files with conflict markers
# Edit conflicted files manually, then:
jj resolve --list  # verify all conflicts resolved
jj describe        # update the commit message if needed
jj git push --change @
```

If you cannot resolve cleanly: `jj abandon @` and report to Steven.

## Quick Reference

| Action | Command |
|--------|---------|
| View stack | `jj log -r 'main@origin..@'` |
| New change on main | `jj new main@origin -m "..."` |
| New change on current | `jj new @ -m "..."` |
| Edit prior change | `jj edit <id>` |
| Return to tip | `jj next` |
| Rebase whole stack | `jj rebase -d main@origin -r 'main@origin..@'` |
| Push change | `jj git push --change <id>` |
| Abandon change | `jj abandon <id>` |
