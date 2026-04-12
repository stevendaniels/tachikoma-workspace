# Add proposal-status skill

## Problem
Need visibility into proposal states, merge readiness, and tracking across the workflow. Currently no way to check status of proposals without manual file inspection.

## Solution  
Create a proposal-status skill that provides:
- List all proposals with current state
- Check merge readiness (files ready, conflicts, etc)
- Show proposal metadata and creation dates
- Filter by status (open, ready, blocked)

## Files
1. `/workspace/skills/proposal-status/SKILL.md` - Skill definition
2. `/workspace/skills/proposal-status/proposal-status.sh` - Implementation script

## Implementation Notes
- Scan `/workspace/proposals/` directory structure
- Check for required files in each proposal
- Validate merge readiness criteria
- Provide human-readable output

## Validation
- List all proposals
- Show status of specific proposal
- Filter by state
- Check merge readiness

## Success Criteria
- Can list proposals with clear status indicators
- Shows what's blocking merge if not ready
- Fast execution for workflow efficiency