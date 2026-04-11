# Skill: handle-pr-review

## Purpose
Automatically process GitHub PR review comments from Steven and apply suggested changes to update the pending pull request.

## When to Use
- After Steven provides review comments with specific change requests that can be implemented automatically
- When review feedback includes clear instructions for code/text changes
- To implement routine fixes (typos, formatting, parameter adjustments) without manual intervention
- As an alternative to manual editing when review comments are specific and actionable

## When NOT to Use
- When review comments require discussion or clarification
- When changes require complex refactoring or architectural decisions
- When Steven requests specific manual approaches mentioned in comments
- For PRs that aren't proposals (non-skill changes)

## Implementation Requirements

To properly gather reviews, the skill needs comprehensive review data collection:

### Review Data Collection
```bash
# Get all review comments from reviewer (not just issue comments)
gh pr view <pr-number> --json latestReviews,reviews --jq '
  .latestReviews[] | select(.author.login == "<reviewer>") |
  {"body": .body, "state": .state, "commit": .commit.oid}
'

# Get inline review comments (different endpoint)
gh api repos/<owner>/<repo>/pulls/<pr-number>/comments --paginate --jq '
  .[] | select(.user.login == "<reviewer>") |
  {"body": .body, "path": .path, "line": .line, "position": .position}
'

# Get issue comments (PR timeline comments)
gh pr view <pr-number> --json comments --jq '
  .comments[] | select(.authorAssociation == "OWNER") |
  {"body": .body, "created": .createdAt, "author": .author.login}
'
```

### Review Parsing Requirements
- Parse both formal reviews AND inline comments
- Extract file paths and line numbers for inline comments
- Separate actionable vs discussion comments
- Handle multi-line review comments
- Track review state (APPROVED, CHANGES_REQUESTED, COMMENTED)

### Common Review Patterns
Reviews often mix actionable and discussion items:
- "Change X to Y" (actionable)
- "Line 45: fix typo" (actionable)
- "Consider if this approach is correct" (discussion)
- "Add warning about Y" (actionable)
- "I'm not sure about the constraints" (discussion)

## Instructions

### Step 4: Document Changes and Respond
For each implemented change:
1. Commit with descriptive message linking to review:
   ```bash
   git commit -m "address review: implement <specific change>
   
   Resolves: <review-comment-url or line reference>
   Co-authored-by: Claude Sonnet 4.6 <noreply@anthropic.com>"
   ```
2. Push changes (without force) to preserve review history
3. Respond in PR comment summarizing implemented changes

### Step 5: Handle Limitations Gracefully
When encountering unclear or unactionable comments:
- Add PR reply seeking clarification
- Document in commit message what was attempted
- Preserve review thread discussion context

Never implement:
- Changes referencing files that don't exist
- Text replacements that don't match existing content
- Architectural changes requiring discussion
- Anything modifying repository settings or permissions
Process reviews to separate:
- **Actionable**: "Change X", "Fix typo line 45", "Add constraint about files"
- **Discussion**: "Consider...", "Not sure about...", "Why did you..."

Filter patterns that indicate actionable changes:
- Line references: "line 12", "row 45", "at position"
- Direct commands: "change", "fix", "add", "remove", "update"
- Specific text: "should be", "should read", "needs to be"

Skip discussion patterns:
- Questions: "why", "what", "how", "consider"
- Uncertainty: "not sure", "might be", "possibly"
- Requests for clarification

### Step 3: Execute Verified Changes
For actionable comments only:
1. Extract exact text to replace and replacement text
2. Identify target file (from inline comments) or assume SKILL.md for general comments
3. Use edit_file with precise text matching
4. Make single, focused changes per commit

```python
# Example parsing logic
if "line " in comment and any(word in comment.lower() for word in ["change", "fix", "typo"]):
    # Extract specific replacement instructions
    # Apply targeted change
    edit_file(file_path, old_text, new_text)
```

### Step 4: Document Changes and Respond

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
- Never merge PRs - only update based on clear feedback
- Keep changes minimal and focused on specific requests
- Always verify changes preserve existing functionality
- Create new commits (don't amend) to preserve review history
- Use descriptive commit messages linking to the review discussion
- Don't delete files or make major structural changes without explicit instructions

## Integration with Create-Proposal Workflow
This skill complements `create-proposal`:
- `create-proposal` handles: initial creation, file setup, base workflow
- `handle-pr-review` handles: feedback parsing, targeted changes, review automation
- Both share: `/proposals` workspace, GitHub integration, proposal scope
- Reviews processed here appear as new commits maintaining review history

## Missing Components for Complete Review Processing

To properly implement review automation, additional tools needed:

1. **Review Classification System**: Distinguish actionable vs discussion comments
2. **Text Extraction Engine**: Parse specific replacement patterns from natural language
3. **File Location Resolver**: Map mentions to actual proposal files (/proposals/...)
4. **Change Validation**: Verify replacements match existing content before editing
5. **Review Threading**: Follow reply chains and skip outdated suggestions
6. **State Management**: Track what's been implemented vs. what's discussion

These capabilities bridge the gap between the existing manual review process and the proposed automated handling, extending rather than replacing the `create-proposal` skill.

The skill needs these components to comprehensively gather reviews:

1. **Complete API Coverage**: Separate calls for formal reviews vs inline comments
2. **Reviewer Authority Check**: Verify reviewer is repo owner/committer  
3. **Line Numbers**: Extract and use line references for inline comments
4. **Review State Handling**: Respect APPROVED vs CHANGES_REQUESTED states
5. **Thread Context**: Parse reply discussions to avoid implementing old suggestions
6. **Error Handling**: Gracefully handle missing comments, permission errors
7. **Review Age Checking**: Skip aging review comments already addressed

## Review Pattern Recognition

Common actionable patterns:
- "Line 23: Fix typo <old_text>"
- "In file/path.md, change <old> to <new>"
- "Add constraint about <topic>: <new_text>"
- "Update example to use <pattern> instead"
- "Standardize description format to <format>"

Key phrase indicators:
- Action words: "change", "fix", "update", "add", "remove"
- Location cues: "line N", "file/path.md", "section <name>"
- Specific replacements: "should be", "should read", "needs to be"

These additions provide:
1. **Complete review data collection** covering all comment types
2. **Smart filtering** to separate actionable vs discussion comments  
3. **Robust text parsing** for extracting specific change instructions
4. **Proper handling** of review context and history preservation
5. **Error boundaries** for gracefully handling unclear or problematic instructions
This skill works alongside `create-proposal`:
- `create-proposal` handles the initial creation and workflow
- `handle-pr-review` processes the review feedback automatically
- Both skills share the `/proposals` workspace and GitHub integration
- Reviews processed by this skill appear as new commits in the same PR

## Common Review Patterns
Typical requests this skill handles well:
- Text corrections (typos, grammar)
- Adding specific constraints or warnings
- Updating examples to current patterns
- Standardizing descriptions or formatting
- Adding missing documentation sections

Requests requiring manual intervention:
- "Consider if this is the right approach"
- Requiring architectural decisions
- Needing discussion or clarification
- Changing core principles or workflows

## Example Usage
```python
# Process review comments for PR #5 and apply clear changes
# Filter for Steven's comments with specific instructions
if "line" in review_comment.body and "change" in review_comment.body:
    # Extract file path and correction details
    # Use edit_file with exact text matching
    edit_file("/proposals/skills/example/SKILL.md", old_text="typo", new_text="corrected")

# After processing all clear instructions
if changes_made:
    # Commit with proper message preserving review history
    # Push updates back to the PR branch
    message_steven("Implemented your review changes: [specific-summary]")
```