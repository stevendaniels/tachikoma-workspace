# Skill: archive-session

## Purpose  
Archive and clean up completed shell sessions by saving their output to files and removing them from the active session list. Prevents session accumulation and provides persistent logs.

## When to Use
- Save output from completed background sessions for later review
- Clean up old sessions to prevent accumulation
- Create persistent logs of command execution
- Archive failed sessions for debugging
- Prepare sessions for documentation or sharing

## Instructions

### Archive Completed Session
```bash
archive-session <sessionId>
```
Saves session output to `~/.session-archive/<sessionId>-<timestamp>.log` and removes from active list.

### Archive with Custom Path
```bash
archive-session <sessionId> --path ~/my-logs/
```
Saves to specified directory instead of default archive location.

### Batch Archive Old Sessions
```bash
archive-session --older-than 1h
```
Archives all completed sessions older than specified duration (s/m/h/d format).

### Preview Before Archiving
```bash
archive-session <sessionId> --dry-run
```
Shows what would be archived without making changes.

### Archive All Completed
```bash
archive-session --all-completed
```
Archives all finished sessions, leaving only running ones active.

## Implementation
Wraps shell session management to:
- Read session output buffer
- Write to timestamped log file  
- Remove session from active list
- Handle 1MB buffer limit gracefully
- Create archive directory if missing

## Output Format
Archive files named: `<sessionId>-YYYYMMDD-HHMMSS.log`
Contain:
- Session metadata (command, start time, exit status)
- Full output buffer (up to 1MB limit)
- Exit code and duration

## Constraints
- Only archives completed/failed sessions (not running ones)
- Output limited to 1MB buffer from sessions
- Default archive location: `~/.session-archive/`
- Cannot archive sessions that no longer exist
- Sessions removed from active list after archiving