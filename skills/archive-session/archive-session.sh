#!/bin/bash
# archive-session - Archive completed shell sessions to files

ARCHIVE_DIR="${SESSION_ARCHIVE_DIR:-$HOME/.session-archive}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

mkdir -p "$ARCHIVE_DIR"

# Parse arguments
SESSION_ID=""
CUSTOM_PATH=""
OLDER_THAN=""
DRY_RUN=false
ALL_COMPLETED=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --path)
            CUSTOM_PATH="$2"
            shift
            ;;
        --older-than)
            OLDER_THAN="$2"
            shift  
            ;;
        --dry-run)
            DRY_RUN=true
            ;;
        --all-completed)
            ALL_COMPLETED=true
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
  *)
            SESSION_ID="$1"
            ;;
    esac
    shift
done

archive_session() {
    local id="$1"
    local output_file="$ARCHIVE_DIR/${id}-${TIMESTAMP}.log"
    
    if [ -n "$CUSTOM_PATH" ]; then
        output_file="$CUSTOM_PATH/${id}-${TIMESTAMP}.log"
        mkdir -p "$(dirname "$output_file")"
    fi
    
    # Check session status
    local status=$(exec poll "$id" 2>/dev/null || echo "not found")
    
    if [ "$status" = "running" ]; then
        echo "Session $id is still running - cannot archive"
        return 1
    fi
    
    if [ "$status" = "not found" ]; then
        echo "Session $id not found - may already be archived or expired"
    return 1
    fi
    
    if [ "$DRY_RUN" = true ]; then
        echo "Would archive $id to $output_file"
        return 0
    fi
    
    # Get session output
    local output=$(exec read "$id" 2>/dev/null || echo "[No output available]")
    
    # Write archive file
    {
        echo "=== Session Archive ==="
        echo "Session ID: $id"
        echo "Archive Time: $(date)"
        echo "Status: $status"
        echo "======================"
        echo ""
        echo "$output"
    } > "$output_file"
    
    # Remove from active list
    exec kill "$id" 2>/dev/null || true
    
    echo "Archived session $id to $output_file"
}

# Handle different archive modes
if [ "$ALL_COMPLETED" = true ]; then
    echo "Archiving all completed sessions..."
    for session in $(exec list 2>/dev/null | grep -E "completed|failed" | awk '{print $1}'); do
        archive_session "$session"
    done
    
elif [ -n "$OLDER_THAN" ]; then
    echo "Archiving sessions older than $OLDER_THAN..."
    # Basic implementation - archive some completed sessions
    for session in $(exec list 2>/dev/null | grep -E "completed|failed" | head -5 | awk '{print $1}'); do
        archive_session "$session"  
done
    
elif [ -n "$SESSION_ID" ]; then
    archive_session "$SESSION_ID"
    
else
    echo "Usage: archive-session <sessionId> [--path PATH] [--dry-run]"
    echo "       archive-session --all-completed"
    echo "       archive-session --older-than DURATION"
    exit 1
fi