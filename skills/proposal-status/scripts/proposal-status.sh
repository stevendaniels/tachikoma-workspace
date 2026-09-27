#!/bin/bash
# proposal-status - Check proposal states and merge readiness

PROPOSALS_DIR="/workspace/proposals"
WORKSPACE_SKILLS_DIR="/workspace/skills"

case "$1" in
    backlog)
        echo "=== Proposal Backlog ==="
        count=0
        for proposal in "$PROPOSALS_DIR"/skills/*; do
            if [ -d "$proposal" ] && [ -f "$proposal/add-skill.md" ]; then
                count=$((count + 1))
                name=$(basename "$proposal")
                echo "$count. skills/$name - PENDING"
            fi
        done
        if [ $count -ge 3 ]; then
            echo "STOP: $count proposals waiting for review (max: 3)"
        fi
        echo
        ;;
    
    list)
        echo "=== All Proposals ==="
        for proposal in "$PROPOSALS_DIR"/skills/*; do
            if [ -d "$proposal" ] && [ -f "$proposal/add-skill.md" ]; then
                name=$(basename "$proposal")
                
                # Check if skill exists in workspace
                if [ -d "$WORKSPACE_SKILLS_DIR/$name" ]; then
                    state="IMPLEMENTED"
                else
                    state="PENDING"
                fi
                
                # Get creation info if available
                if [ -f "$proposal/add-skill.md" ]; then
                    created="$(stat -c %y "$proposal/add-skill.md" 2>/dev/null | cut -d' ' -f1)"
                else
                    created="unknown"
                fi
                
                echo "📋 $name"
                echo "   Status: $state"
                echo "   Created: $created"
                echo "   Files: $(find "$proposal" -name "*.md" | wc -l)"
                echo
            fi
        done
        ;;
    
    check)
        if [ -z "$2" ]; then
            echo "Usage: proposal-status check <proposal-name>"
            exit 1
        fi
        
        proposal="$PROPOSALS_DIR/skills/$2"
        if [ ! -d "$proposal" ]; then
            echo "Proposal '$2' not found"
            exit 1
        fi
        
        echo "=== Proposal: $2 ==="
        echo "Location: $proposal"
        
        # Check required files
        echo -e "\nRequired Files:"
        if [ -f "$proposal/add-skill.md" ]; then
            echo "✅ add-skill.md"
        else
            echo "❌ add-skill.md (missing)"
        fi
        
        if [ -f "$proposal/SKILL.md" ]; then
            echo "✅ SKILL.md"
        else
            echo "❌ SKILL.md (missing)"
        fi
        
        # Show all files
        echo -e "\nAll Files:"
        find "$proposal" -name "*.md" -exec basename {} \; | sort
        
        # Merge readiness
        echo -e "\nMerge Readiness:"
        if [ -f "$proposal/add-skill.md" ] && [ -f "$proposal/SKILL.md" ]; then
            echo "✅ Ready for review"
        else
            echo "❌ Missing required files"
        fi
        ;;
    
    filter)
        if [ -z "$2" ]; then
            echo "Usage: proposal-status filter <status>"
            echo "Status: draft, open, ready, blocked"
            exit 1
        fi
        
        echo "=== Filtering for: $2 ==="
        for proposal in "$PROPOSALS_DIR"/skills/*; do
            if [ -d "$proposal" ] && [ -f "$proposal/add-skill.md" ]; then
                name=$(basename "$proposal")
                
                case "$2" in
                    draft)
                        if [ ! -f "$proposal/SKILL.md" ]; then
                            echo "📋 $name - Draft (missing SKILL.md)"
                        fi
                        ;;
                    ready)
                        if [ -f "$proposal/add-skill.md" ] && [ -f "$proposal/SKILL.md" ]; then
                            echo "✅ $name - Ready for review"
                        fi
                        ;;
                    *)
                        echo "📋 $name - Status check not implemented for '$2'"
                        ;;
                esac
            fi
        done
        ;;
    
    *)
        echo "proposal-status - Check proposal states and merge readiness"
        echo
        echo "Usage:"
        echo "  proposal-status backlog   - Check proposal backlog"
        echo "  proposal-status list      - List all proposals"  
        echo "  proposal-status check <name> - Check specific proposal"
        echo "  proposal-status filter <status> - Filter by status"
        echo
        echo "Status: draft, open, ready, blocked"
        exit 1
        ;;
esac