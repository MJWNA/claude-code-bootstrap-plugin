#!/usr/bin/env bash
# 2c. cognitive-loop-filter.sh — Stop
# Smart-filtered learning nudge. Rate-limited to 3 nudges per session.

set -euo pipefail

command -v jq >/dev/null 2>&1 || { echo "Bootstrap plugin requires jq" >&2; exit 1; }

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // ""')

_SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$_SCRIPT_DIR")}"

# Rate limit: max 3 nudges per session
COUNTER_FILE="/tmp/bootstrap-nudge-count-${SESSION_ID}"
CURRENT_COUNT=0
if [ -f "$COUNTER_FILE" ]; then
  CURRENT_COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
fi

if [ "$CURRENT_COUNT" -ge 3 ]; then
  exit 0
fi

# Check transcript for tool use indicators
if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
  exit 0
fi

# Read last 20 lines of transcript
LAST_LINES=$(tail -20 "$TRANSCRIPT_PATH" 2>/dev/null || echo "")

if [ -z "$LAST_LINES" ]; then
  exit 0
fi

# Check for tool use indicators (Edit, Write, Bash tool calls)
TOOL_USE_DETECTED=false
if echo "$LAST_LINES" | grep -qi '"tool_use"\|"name": *"Edit"\|"name": *"Write"\|"name": *"Bash"\|"name": *"Read"'; then
  TOOL_USE_DETECTED=true
fi

# Also check for plain text indicators of tool use in assistant turns
if [ "$TOOL_USE_DETECTED" = false ]; then
  if echo "$LAST_LINES" | grep -qi 'I will edit\|I will write\|running bash\|executing\|creating file\|updating file'; then
    TOOL_USE_DETECTED=true
  fi
fi

if [ "$TOOL_USE_DETECTED" = false ]; then
  # Pure Q&A — exit silently
  exit 0
fi

# Increment counter
NEW_COUNT=$((CURRENT_COUNT + 1))
echo "$NEW_COUNT" > "$COUNTER_FILE"

# Output nudge
echo "🧠 Tool use detected. Patterns and conventions from this turn will be captured at session end."

exit 0
