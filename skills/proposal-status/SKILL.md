# Skill: proposal-status

## Purpose
Provide visibility into workspace proposal states, merge readiness, and tracking across the proposal workflow.

## When to Use
- Check current proposal backlog before adding new proposals
- Verify merge readiness of specific proposals  
- List all proposals with their current state
- Filter proposals by status (open, ready, blocked)
- Show proposal metadata and creation dates

## Instructions

### Check Proposal Backlog
```bash
proposal-status backlog
```
Shows count of open proposals and lists each with title and PR URL.
Stops at 3+ unreviewed proposals per workspace constraints.

### List All Proposals
```bash
proposal-status list
```
Scans `/workspace/proposals/` and shows:
- Proposal name and path
- Current state (draft/open/ready/blocked)
- Creation date and author
- Required files present/missing
- Merge readiness indicators

### Check Specific Proposal
```bash
proposal-status check <proposal-name>
```
Detailed status for one proposal including:
- Full file listing
- Merge readiness checklist
- Blocking issues if any
- Required next steps

### Filter by Status  
```bash
proposal-status filter <status>
```
Show only proposals matching status:
- `draft` - Incomplete proposals
- `open` - Active but not ready
- `ready` - Mergeable pending review
- `blocked` - Has blocking issues

## Implementation
Scan `/workspace/proposals/` directory structure, validate presence of required files (`SKILL.md` for skills), check merge readiness criteria, provide human-readable output with status indicators.

## Constraints
- Only shows workspace proposals in `/workspace/proposals/`
- Status determination based on file presence/structure
- Merge readiness follows workspace guidelines
- Respects 3-proposal review limit for backlog check