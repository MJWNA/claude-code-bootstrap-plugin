#!/usr/bin/env bash
# 2e. correction-detect.sh — UserPromptSubmit
# Real-time correction/confirmation detection via regex on user's prompt.

set -euo pipefail

command -v jq >/dev/null 2>&1 || { echo "Bootstrap plugin requires jq" >&2; exit 1; }

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')
USER_PROMPT=$(echo "$INPUT" | jq -r '.user_prompt // ""')

_SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$_SCRIPT_DIR")}"
QUEUE_FILE="$PLUGIN_ROOT/data/learnings-queue.json"
LOCKDIR="$PLUGIN_ROOT/data/.queue.lock"

WORKSPACE_NAME=$(basename "$CWD")
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Skip empty or short prompts
PROMPT_LEN=${#USER_PROMPT}
if [ "$PROMPT_LEN" -lt 10 ]; then
  exit 0
fi

# Initialise queue if missing
if [ ! -f "$QUEUE_FILE" ]; then
  echo "[]" > "$QUEUE_FILE"
fi

# ─── Pattern detection (macOS-compatible ERE via grep -E) ────────────────────

CONFIDENCE=""

# HIGH confidence correction patterns
# Using grep -Ei (extended, case-insensitive) — no -P on macOS
if echo "$USER_PROMPT" | grep -Ei \
  "^no,|^no |actually|wrong|instead of|use .+ not|don't use|stop doing|remember:" \
  >/dev/null 2>&1; then
  CONFIDENCE="HIGH"
fi

# MEDIUM confidence confirmation patterns (only check if not already HIGH)
if [ -z "$CONFIDENCE" ]; then
  if echo "$USER_PROMPT" | grep -Ei \
    "perfect|yes exactly|that's right|keep doing that|good call|^nice$|^nice[.!]|exactly right" \
    >/dev/null 2>&1; then
    CONFIDENCE="MEDIUM"
  fi
fi

# No match — exit silently
if [ -z "$CONFIDENCE" ]; then
  exit 0
fi

# ─── Build and queue learning entry ──────────────────────────────────────────

ENTRY_ID="learn-$(date +%s)-$$"
ENTRY=$(jq -n \
  --arg id "$ENTRY_ID" \
  --arg ts "$TIMESTAMP" \
  --arg ctx "$USER_PROMPT" \
  --arg raw "$USER_PROMPT" \
  --arg sid "$SESSION_ID" \
  --arg ws "$WORKSPACE_NAME" \
  --arg conf "$CONFIDENCE" \
  '{
    id: $id,
    timestamp: $ts,
    source: "correction-detect",
    confidence: $conf,
    context: $ctx,
    raw_text: $raw,
    session_id: $sid,
    workspace: $ws,
    occurrences: 1,
    status: "pending"
  }')

# Acquire lock
while ! mkdir "$LOCKDIR" 2>/dev/null; do sleep 0.1; done

# Read → append → write
CURRENT_QUEUE=$(cat "$QUEUE_FILE" 2>/dev/null || echo "[]")
UPDATED_QUEUE=$(echo "$CURRENT_QUEUE" | jq --argjson e "$ENTRY" '. + [$e]')
echo "$UPDATED_QUEUE" > "$QUEUE_FILE"

# Release lock
rmdir "$LOCKDIR" 2>/dev/null

exit 0
