# Add archive-session skill

## Problem
Need to archive completed shell sessions by saving their output to files and removing them from active session list. Currently no way to persist session logs or prevent session accumulation over time.

## Solution  
Create an archive-session skill that provides:
- Archive individual completed sessions to timestamped log files
- Batch archive old or all completed sessions  
- Save to default or custom archive directories
- Preview archiving with dry-run mode
- Clean up sessions after archiving

## Files
1. `/workspace/skills/archive-session/SKILL.md` - Skill definition
2. `/workspace/skills/archive-session/archive-session.sh` - Implementation script

## Implementation Notes
- Wrapper around exec session management
- Read session output buffer (1MB limit)
- Write timestamped archive files to `~/.session-archive/` 
- Support custom archive paths
- Handle sessions in completed/failed status only
- Remove sessions from active list after archiving

## Validation
- Archive completed session to default location
- Archive with custom path and dry-run
- Batch archive completed sessions
- Handle running sessions (should refuse)
- Handle missing/non-existent sessions

## Success Criteria
- Can reliably archive session output to files
- Creates proper archive directory structure
- Handles 1MB buffer limit gracefully  
- Refuses to archive running sessions
- Cleans up archived sessions from active list