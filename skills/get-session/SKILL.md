# Skill: get-session

## Purpose  
Inspect active shell session status to determine if background sessions are running, get output from them, or kill them when needed.

## When to Use
- Check if a background command is still running
- Read partial output from a long-running command
- Kill a stuck or unwanted background session
- List all active background sessions
- Debug session management issues

## Instructions

### Check Session Status
```bash
get-session status <sessionId>
```
Returns: `running`, `completed`, `failed`, or `not found`

### Read Session Output
```bash
get-session read <sessionId>
```
Shows current output buffer (up to 1MB limit). Non-blocking read.

### List Active Sessions
```bash
get-session list
```
Shows all background sessions with:
- Session ID
- Command that was run  
- Current status
- Start time

### Kill a Session
```bash
get-session kill <sessionId>
```
Terminates the session and cleans up resources.

### Interactive Sessions
```bash
get-session attach <sessionId>
```
For sessions started with `pty=true`. Connects to existing PTY session.

## Implementation
Wraps shell session management tools. Session IDs are returned when commands are run with `background=true`. Sessions auto-cleanup 30 minutes after process exit but can be manually killed.

## Constraints
- Session output buffer limited to 1MB
- Sessions auto-expire after 30 minutes of inactivity  
- Interactive sessions require `pty=true` on creation
- Cannot restart killed sessions - create new ones instead