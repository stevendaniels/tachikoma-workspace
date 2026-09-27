---
name: get-session
description: Use when you need to check status, read output, list, or kill background shell sessions created with exec background=true.
---

# Get Session

Inspect and manage active shell sessions: check status, read output, list sessions, kill stuck ones.

## Overview
Wraps shell session management. Session IDs are returned when commands run with `background=true`; this skill inspects and controls those sessions.

## When to Use
- Check if a background command is still running
- Read partial output from a long-running command
- Kill a stuck or unwanted background session
- List all active background sessions
- Debug session management issues

## Usage

| Command | What it does |
|---------|--------------|
| `get-session status <id>` | Returns `running`, `completed`, `failed`, or `not found` |
| `get-session read <id>` | Shows current output buffer (up to 1MB, non-blocking) |
| `get-session list` | All sessions: ID, command, status, start time |
| `get-session kill <id>` | Terminates session and cleans up resources |
| `get-session attach <id>` | Connects to a PTY session created with `pty=true` |

## Implementation
Executable: `scripts/get-session.sh`

Session IDs are returned when commands are run with `background=true`. Sessions auto-cleanup 30 minutes after process exit but can be manually killed.

## Constraints
- Session output buffer limited to 1MB
- Sessions auto-expire after 30 minutes of inactivity
- Interactive sessions require `pty=true` on creation
- Cannot restart killed sessions - create new ones instead
