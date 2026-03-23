#!/usr/bin/env bash
# 2b. compaction-reinject.sh — SessionStart:compact
# Re-inject critical context after compaction.

set -euo pipefail

command -v jq >/dev/null 2>&1 || { echo "Bootstrap plugin requires jq" >&2; exit 1; }

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')

_SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$_SCRIPT_DIR")}"
QUEUE_FILE="$PLUGIN_ROOT/data/learnings-queue.json"

OUTPUT_LINES=()

# 1. Re-inject learnings queue count (pending items)
if [ -f "$QUEUE_FILE" ]; then
  PENDING_COUNT=$(jq '[.[] | select(.status == "pending")] | length' "$QUEUE_FILE" 2>/dev/null || echo 0)
  if [ "$PENDING_COUNT" -gt 0 ]; then
    OUTPUT_LINES+=("📚 Learnings queue: ${PENDING_COUNT} pending item(s) awaiting promotion to rules.")
  fi
fi

# 2. Re-inject last HANDOFF.md entry (first paragraph)
HANDOFF_FILE="$CWD/.claude/session/HANDOFF.md"
if [ -f "$HANDOFF_FILE" ]; then
  # Extract the first non-empty paragraph (up to first blank line after content)
  FIRST_PARA=$(awk '
    /^[[:space:]]*$/ { if (found) exit }
    /[^[:space:]]/ { found=1; print }
  ' "$HANDOFF_FILE" | head -10)
  if [ -n "$FIRST_PARA" ]; then
    OUTPUT_LINES+=("📋 Last session handoff:")
    OUTPUT_LINES+=("$FIRST_PARA")
  fi
fi

# 3. Re-inject workspace health one-liner if CLAUDE.md missing
if [ -n "$CWD" ] && [ "$CWD" != "$HOME" ] && [ ! -f "$CWD/CLAUDE.md" ]; then
  OUTPUT_LINES+=("⚠️  Workspace has no CLAUDE.md — run /bootstrap to configure.")
fi

# Always output something (compaction always loses context)
if [ ${#OUTPUT_LINES[@]} -eq 0 ]; then
  echo "♻️  Context restored after compaction. Workspace config looks healthy."
else
  for line in "${OUTPUT_LINES[@]}"; do
    echo "$line"
  done
fi

exit 0
