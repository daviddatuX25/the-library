#!/bin/bash
# on-stop-sync-honcho.sh
# Fires on every Claude Code Stop event.
# Reads the session-debrief prompt from prompts/ and injects it
# as additionalContext so Claude summarizes the session to Honcho.
#
# The hook does NOT call Honcho directly — it injects context that
# instructs Claude to make the MCP call before closing.

LIBRARY_DIR="$HOME/.claude/skills/library"
DEBRIEF_PROMPT_FILE="$LIBRARY_DIR/prompts/session-debrief.md"

# Read the debrief prompt if it exists
if [ -f "$DEBRIEF_PROMPT_FILE" ]; then
    # Escape the prompt content for JSON embedding
    DEBRIEF_CONTENT=$(python3 -c "
import json, sys
with open('$DEBRIEF_PROMPT_FILE', 'r') as f:
    print(json.dumps(f.read()))
" 2>/dev/null)

    # If python isn't available, use a simpler approach
    if [ $? -ne 0 ]; then
        DEBRIEF_CONTENT=$(cat "$DEBRIEF_PROMPT_FILE" | sed 's/"/\\"/g' | tr '\n' ' ')
        DEBRIEF_CONTENT="\"$DEBRIEF_CONTENT\""
    fi

    echo "{\"additionalContext\": $DEBRIEF_CONTENT}"
else
    # Fallback: basic instruction if prompt file is missing
    echo '{"additionalContext": "Before closing: briefly summarize what concepts were used this session and log them to Honcho. Note any new concepts as learning debt."}'
fi
