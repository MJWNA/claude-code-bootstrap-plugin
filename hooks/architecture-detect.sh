#!/usr/bin/env bash
# 3a. architecture-detect.sh — PostToolUse:Edit|Write
# Flag architecture-significant file changes and nudge ARCHITECTURE.md updates.

set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""')

# Nothing to check if no file path
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

_SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$_SCRIPT_DIR")}"

MESSAGE=""

# ─── Pattern matching on file path ────────────────────────────────────────────

case "$FILE_PATH" in
  # Database schema changes
  */lib/db/schema/*.ts | */db/schema/*.ts | */drizzle/schema/*.ts)
    MESSAGE="🏗️ Database schema changed. Consider updating ARCHITECTURE.md data architecture section."
    ;;

  # Route layout changes
  */app/*/layout.tsx | */app/*/layout.ts)
    MESSAGE="🏗️ Route layout changed. Consider updating ARCHITECTURE.md route architecture section."
    ;;

  # Proxy / middleware changes
  */proxy.ts | */middleware.ts)
    MESSAGE="🏗️ Proxy/middleware changed. Consider updating ARCHITECTURE.md."
    ;;

  # Module barrel export changes
  */modules/*/index.ts | */modules/*/index.tsx)
    MESSAGE="🏗️ Module barrel export changed. Consider updating ARCHITECTURE.md module boundaries section."
    ;;

  # Vercel config changes
  *vercel.json)
    MESSAGE="🏗️ Vercel config changed. Consider updating ARCHITECTURE.md deployment section."
    ;;
esac

# Output message if a pattern matched
if [ -n "$MESSAGE" ]; then
  echo "$MESSAGE"
fi

exit 0
