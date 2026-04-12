#!/bin/bash
# get-session - Inspect and manage active shell sessions

case "$1" in
    status)
        if [ -z "$2" ]; then
            echo "Usage: get-session status <sessionId>"
            exit 1
        fi
        exec poll "$2"
        ;;
    
    read|output)
        if [ -z "$2" ]; then
            echo "Usage: get-session read <sessionId>"
            exit 1
        fi
        exec read "$2" || echo "Session $2: read failed or session not found"
        ;;
    
    list)
        exec list
        ;;
    
    kill)
        if [ -z "$2" ]; then
            echo "Usage: get-session kill <sessionId>"
            exit 1
        fi
        exec kill "$2" || echo "Session $2: kill failed or session not found"
        ;;
    
    attach|connect)
        if [ -z "$2" ]; then
            echo "Usage: get-session attach <sessionId>"
            exit 1
        fi
        echo "Attempting to attach to session $2..."
        echo "Note: Session must have been created with pty=true"
        exec write "$2" "echo 'Connected to session $2. Type exit to detach.'" || echo "Session $2: attach failed"
        ;;
    
    help|--help|-h|*)
        echo "get-session - Inspect and manage active shell sessions"
        echo
        echo "Usage:"
        echo "  get-session status <id>   - Check if session is running/completed"
        echo "  get-session read <id>     - Get current output buffer"
        echo "  get-session list          - Show all active sessions"   
        echo "  get-session kill <id>     - Terminate a session"
        echo "  get-session attach <id>   - Connect to PTY session (experimental)"
        echo
        echo "Session IDs are returned when running commands with background=true"
        echo "Sessions auto-expire 30min after process exit"
        exit 0
        ;;
esac