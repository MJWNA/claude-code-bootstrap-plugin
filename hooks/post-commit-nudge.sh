#!/usr/bin/env bash
# 2f. post-commit-nudge.sh — PostToolUse:Bash
# Nudge after git commits to keep rules and docs in sync.

set -euo pipefail

command -v jq >/dev/null 2>&1 || { echo "Bootstrap plugin requires jq" >&2; exit 1; }

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Only fire on git commit commands
if echo "$COMMAND" | grep -q "git commit"; then
  echo "📝 Post-commit checklist:"
  echo "  1. Update .claude/rules/ if this commit changed patterns or conventions"
  echo "  2. Update ARCHITECTURE.md if this commit changed system structure"
  echo "  3. Update CLAUDE.md if this commit changed the project's key gotchas"
fi

exit 0
