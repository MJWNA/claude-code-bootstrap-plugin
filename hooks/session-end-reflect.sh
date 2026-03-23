#!/usr/bin/env bash
# 2d. session-end-reflect.sh — SessionEnd
# Comprehensive session reflection: extract corrections, queue learnings, write HANDOFF.md

set -euo pipefail

command -v jq >/dev/null 2>&1 || { echo "Bootstrap plugin requires jq" >&2; exit 1; }

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // ""')

_SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$_SCRIPT_DIR")}"
QUEUE_FILE="$PLUGIN_ROOT/data/learnings-queue.json"
LOCKDIR="$PLUGIN_ROOT/data/.queue.lock"

WORKSPACE_NAME=$(basename "$CWD")
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Initialise queue file if missing
if [ ! -f "$QUEUE_FILE" ]; then
  echo "[]" > "$QUEUE_FILE"
fi

# ─── Extract correction patterns from transcript ─────────────────────────────

NEW_LEARNINGS=()

if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
  # Use jq to find user messages that contain correction patterns
  # Pattern matches: no, | actually | wrong | instead | don't | stop doing
  # macOS-compatible: use "i" flag for case-insensitive in jq test()
  CORRECTIONS=$(jq -r '
    .[] |
    select(.role == "user") |
    select(
      .content | tostring |
      test("no,|actually|wrong|instead|don.t|stop doing"; "i")
    ) |
    .content | tostring | .[0:200]
  ' "$TRANSCRIPT_PATH" 2>/dev/null || echo "")

  if [ -n "$CORRECTIONS" ]; then
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      # Build a learning entry JSON
      ENTRY_ID="learn-$(date +%s%N 2>/dev/null || date +%s)-$$"
      ENTRY=$(jq -n \
        --arg id "$ENTRY_ID" \
        --arg ts "$TIMESTAMP" \
        --arg ctx "$line" \
        --arg raw "$line" \
        --arg sid "$SESSION_ID" \
        --arg ws "$WORKSPACE_NAME" \
        '{
          id: $id,
          timestamp: $ts,
          source: "session-end",
          confidence: "HIGH",
          context: $ctx,
          raw_text: $raw,
          session_id: $sid,
          workspace: $ws,
          occurrences: 1,
          status: "pending"
        }')
      NEW_LEARNINGS+=("$ENTRY")
    done <<< "$CORRECTIONS"
  fi
fi

# ─── Queue learnings (with file lock) ────────────────────────────────────────

if [ ${#NEW_LEARNINGS[@]} -gt 0 ]; then
  # Acquire lock
  while ! mkdir "$LOCKDIR" 2>/dev/null; do sleep 0.1; done

  # Read current queue
  CURRENT_QUEUE=$(cat "$QUEUE_FILE" 2>/dev/null || echo "[]")

  # Append new learnings
  UPDATED_QUEUE="$CURRENT_QUEUE"
  for entry in "${NEW_LEARNINGS[@]}"; do
    UPDATED_QUEUE=$(echo "$UPDATED_QUEUE" | jq --argjson e "$entry" '. + [$e]')
  done

  echo "$UPDATED_QUEUE" > "$QUEUE_FILE"

  # Release lock
  rmdir "$LOCKDIR" 2>/dev/null
fi

# ─── Write HANDOFF.md (prepend, newest first) ────────────────────────────────

SESSION_DIR="$CWD/.claude/session"
if [ -n "$CWD" ] && [ "$CWD" != "$HOME" ]; then
  mkdir -p "$SESSION_DIR"
  HANDOFF_FILE="$SESSION_DIR/HANDOFF.md"

  # Build summary header
  LEARNING_COUNT=${#NEW_LEARNINGS[@]}
  PENDING_TOTAL=$(jq '[.[] | select(.status == "pending")] | length' "$QUEUE_FILE" 2>/dev/null || echo 0)

  NEW_ENTRY="## Session: $TIMESTAMP (workspace: $WORKSPACE_NAME)

- Session ID: $SESSION_ID
- Corrections captured: $LEARNING_COUNT
- Total pending learnings in queue: $PENDING_TOTAL
- Working directory: $CWD

"

  if [ -f "$HANDOFF_FILE" ]; then
    EXISTING=$(cat "$HANDOFF_FILE")
    printf '%s%s' "$NEW_ENTRY" "$EXISTING" > "$HANDOFF_FILE"
  else
    printf '%s' "$NEW_ENTRY" > "$HANDOFF_FILE"
  fi
fi

# ─── Clean up temp files ──────────────────────────────────────────────────────

rm -f /tmp/bootstrap-nudge-count-* 2>/dev/null || true
rm -f /tmp/bootstrap-scanned-* 2>/dev/null || true

exit 0
