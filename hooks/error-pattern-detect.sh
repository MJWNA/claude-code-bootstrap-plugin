#!/usr/bin/env bash
# 3b. error-pattern-detect.sh — PostToolUseFailure
# Track repeated failure patterns and warn when a tool fails 3+ times in one session.

set -euo pipefail

command -v jq >/dev/null 2>&1 || { echo "Bootstrap plugin requires jq" >&2; exit 1; }

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')

_SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$_SCRIPT_DIR")}"

ERROR_LOG="$PLUGIN_ROOT/data/error-log.json"
LOCKDIR="$PLUGIN_ROOT/data/.error-log.lock"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Initialise log file if missing
if [ ! -f "$ERROR_LOG" ]; then
  echo "[]" > "$ERROR_LOG"
fi

# ─── Build new failure entry ──────────────────────────────────────────────────

ENTRY=$(jq -n \
  --arg ts "$TIMESTAMP" \
  --arg tool "$TOOL_NAME" \
  --arg sid "$SESSION_ID" \
  '{
    timestamp: $ts,
    tool: $tool,
    session_id: $sid
  }')

# ─── Acquire mkdir-based lock, append entry, release ─────────────────────────

while ! mkdir "$LOCKDIR" 2>/dev/null; do sleep 0.1; done

CURRENT=$(cat "$ERROR_LOG" 2>/dev/null || echo "[]")
UPDATED=$(echo "$CURRENT" | jq --argjson e "$ENTRY" '. + [$e]')
echo "$UPDATED" > "$ERROR_LOG"

rmdir "$LOCKDIR" 2>/dev/null

# ─── Count failures for this tool + session ───────────────────────────────────

FAIL_COUNT=$(echo "$UPDATED" | jq \
  --arg tool "$TOOL_NAME" \
  --arg sid "$SESSION_ID" \
  '[.[] | select(.tool == $tool and .session_id == $sid)] | length')

# Warn when threshold reached
if [ "$FAIL_COUNT" -ge 3 ]; then
  echo "⚠️ ${TOOL_NAME} has failed ${FAIL_COUNT} times this session. Consider: is there a missing rule or convention for this pattern?"
fi

exit 0
