# Add get-session skill

## Problem
Need to inspect active shell session status to determine if background sessions are running, get output from them, or kill them when needed. Currently no unified way to manage background sessions created with exec background=true.

## Solution  
Create a get-session skill that provides:
- Check session status (running, completed, failed)
- Read current output buffer from sessions
- List all active background sessions
- Kill stuck or unwanted sessions
- Connect to interactive PTY sessions

## Files
1. `/workspace/skills/get-session/SKILL.md` - Skill definition
2. `/workspace/skills/get-session/get-session.sh` - Implementation script

## Implementation Notes
- Wrapper around exec session management
- Session IDs returned from background commands
- Handle 1MB output buffer limit
- Support PTY session attachment
- Auto-cleanup after 30 minutes

## Validation
- Check status of background session
- Read output from long-running command
- List and kill sessions
- Handle session not found errors

## Success Criteria
- Can reliably check session status
- Read partial output without blocking
- Kill sessions and clean up resources
- Clear error handling for missing sessions