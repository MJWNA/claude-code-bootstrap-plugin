# Hook Scripts Reference

The bootstrap plugin provides 8 hooks that auto-fire on Claude Code lifecycle events.

## Core Hooks (Tier 1)

| Script | Event | Matcher | Purpose |
|--------|-------|---------|---------|
| `session-start-scan.sh` | SessionStart | startup | Detects weak/missing workspace config. Nudges to run /bootstrap |
| `compaction-reinject.sh` | SessionStart | compact | Re-injects learnings queue count, last HANDOFF.md entry after compaction |
| `cognitive-loop-filter.sh` | Stop | (all) | Smart-filtered nudge when tool use detected. Rate-limited to 3/session |
| `session-end-reflect.sh` | SessionEnd | (all) | Comprehensive session reflection. Extracts corrections, writes HANDOFF.md |
| `correction-detect.sh` | UserPromptSubmit | (all) | Real-time correction/confirmation detection via regex. Queues to learnings |
| `post-commit-nudge.sh` | PostToolUse | Bash | Reminds to update rules/ARCHITECTURE.md/CLAUDE.md after git commits |

## Valuable Hooks (Tier 2)

| Script | Event | Matcher | Purpose |
|--------|-------|---------|---------|
| `architecture-detect.sh` | PostToolUse | Edit\|Write | Flags architecture-significant file changes (schema, layout, proxy, barrel exports) |
| `error-pattern-detect.sh` | PostToolUseFailure | (all) | Tracks repeated failures. Warns at 3+ failures for same tool in a session |

## Data Files

| File | Written By | Read By |
|------|-----------|---------|
| `data/learnings-queue.json` | correction-detect, session-end-reflect | /reflect skill |
| `data/error-log.json` | error-pattern-detect | /health-check skill |
