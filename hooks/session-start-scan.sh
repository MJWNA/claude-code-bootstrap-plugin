#!/usr/bin/env bash
# 2a. session-start-scan.sh — SessionStart:startup
# Detect weak/missing workspace configuration. One-time execution per session.

set -euo pipefail

command -v jq >/dev/null 2>&1 || { echo "Bootstrap plugin requires jq" >&2; exit 1; }

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')

_SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$_SCRIPT_DIR")}"

# Skip home directory
if [ "$CWD" = "$HOME" ]; then
  exit 0
fi

# One-time per session via flag file
FLAG_FILE="/tmp/bootstrap-scanned-${SESSION_ID}"
if [ -f "$FLAG_FILE" ]; then
  exit 0
fi
touch "$FLAG_FILE"

# Run checks
ISSUES=()

# 1. CLAUDE.md exists?
if [ ! -f "$CWD/CLAUDE.md" ]; then
  ISSUES+=("❌ CLAUDE.md missing")
else
  # 2. Under 80 lines?
  LINE_COUNT=$(wc -l < "$CWD/CLAUDE.md" | tr -d ' ')
  if [ "$LINE_COUNT" -gt 80 ]; then
    ISSUES+=("⚠️  CLAUDE.md is ${LINE_COUNT} lines (target: under 80)")
  fi
fi

# 3. .claude/rules/ exists?
if [ ! -d "$CWD/.claude/rules" ]; then
  ISSUES+=("❌ .claude/rules/ directory missing")
else
  # 4. Path-scoped rules? (look for 'paths:' frontmatter in any rule file)
  HAS_SCOPED=false
  for f in "$CWD/.claude/rules/"*.md; do
    [ -f "$f" ] || continue
    if head -20 "$f" | grep -q "^paths:"; then
      HAS_SCOPED=true
      break
    fi
  done
  if [ "$HAS_SCOPED" = false ]; then
    ISSUES+=("⚠️  No path-scoped rules found in .claude/rules/ (add 'paths:' frontmatter)")
  fi
fi

# 5. ARCHITECTURE.md exists?
if [ ! -f "$CWD/ARCHITECTURE.md" ]; then
  ISSUES+=("⚠️  ARCHITECTURE.md missing")
fi

# 6. .claude/session/ exists?
if [ ! -d "$CWD/.claude/session" ]; then
  ISSUES+=("⚠️  .claude/session/ directory missing (session continuity disabled)")
fi

# 7. Meta-rule (99-rule-iteration) exists?
META_RULE_EXISTS=false
for f in "$CWD/.claude/rules/"*rule-iteration* "$CWD/.claude/rules/99-"*; do
  [ -f "$f" ] && META_RULE_EXISTS=true && break
done
if [ "$META_RULE_EXISTS" = false ]; then
  ISSUES+=("⚠️  Meta-rule (99-rule-iteration) missing in .claude/rules/")
fi

# Output results
if [ ${#ISSUES[@]} -gt 0 ]; then
  echo "🔍 Bootstrap scan — workspace config issues detected:"
  for issue in "${ISSUES[@]}"; do
    echo "  $issue"
  done
  echo ""
  echo "  Run /bootstrap to set up"
fi

exit 0
