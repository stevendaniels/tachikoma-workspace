# Skill: handle-pr-review

## Purpose
Process GitHub PR review comments and suggested changes, then update the pending PR accordingly.

## When to Use
- After Steven provides review comments on a proposal PR
- When feedback requires code or content changes to the open PR
- To automatically understand and implement review suggestions

## Instructions

### Step 1: Fetch PR Details
```bash
gh pr view <pr-number> --json comments,reviews,latestReviews --jq '
  .comments[] | select(.authorAssociation == "OWNER") | 
  {"body": .body, "author": .author.login, "created": .createdAt}
' 
```

### Step 2: Analyze Comments
Parse review comments to identify actionable items. Look for:
- Specific change requests
- Bug reports or fixes
- Suggestions for improvement
- Questions requiring clarification

### Step 3: Apply Changes
For each valid comment:
1. Edit the relevant file(s) in the current PR branch
2. Use edit_file or write_file tools as appropriate
3. Make minimal, targeted changes
4. Preserve existing functionality

### Step 4: Test Changes
If applicable, run relevant tests or verify the changes work as intended.

### Step 5: Update PR
```bash
git add .
git commit --amend --no-edit  # or new commit if preferred
gh pr view <pr-number> --json headRefName | jq -r .headRefName | xargs -I{} git push origin {} -f
```

## Constraints
- Only process reviews from repository owners (Steven)
- Never merge PRs - only update based on feedback
- Keep changes minimal and focused on review comments
- Always verify changes don't break existing functionality
- Preserve commit history unless squashing is explicitly requested

## Example Usage
```
# Handle review comments on PR #5
handle_pr_review(pr_number=5)

# Process specific comment about SOUL.md changes
if "SOUL.md" in comment.body:
    edit_file("/proposals/SOUL.md", old_text="...", new_text="...")
```