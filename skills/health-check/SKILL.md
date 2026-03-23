---
name: health-check
description: Quick diagnostic verification of workspace Claude Code configuration. Checks hooks, settings, rules, and memory.
disable-model-invocation: true
---

# Health Check — Workspace Diagnostic

Quick diagnostic verification of workspace Claude Code configuration.

## Workflow

### Phase 1: Investigation (parallel agents, quick mode)

Dispatch 3 agents:

1. **config-analyzer** — Full configuration audit (CLAUDE.md, rules, hooks, ARCHITECTURE.md, session, memory)
2. **codebase-analyzer** — Quick scan of key patterns (module count, tech stack basics)
3. Use config-analyzer's quality score as the headline metric

### Phase 2: Report Card

Format the output as a diagnostic report:

```
🏥 Workspace Health Check — /path/to/project
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Quality Score: 72/100

✅ CLAUDE.md: 64 lines (under 80 ✓)
   Sections: Identity ✓ | Tech Stack ✓ | Conventions ✓ | Build ✓ | Gotchas ✓ | Compact ✓ | Rule Index ✓

⚠️ Rules: 4 files (280 total lines)
   - 3/4 path-scoped ✓
   - 00-workspace.md: 45 lines ✓
   - 60-app.md: 120 lines ✓
   - 61-database.md: 95 lines ✓
   - 10-domain.md: 20 lines — ⚠️ No path-scoping (consider adding paths: frontmatter)

✅ Hooks: .claude/settings.json present, valid JSON
   - 2/2 hook scripts executable ✓

❌ ARCHITECTURE.md: Last updated 18 days ago (14 commits since)
   - Consider running /bootstrap or /audit-rules to refresh

✅ Session: .claude/session/ exists, HANDOFF.md present

📋 Learnings Queue: 6 pending items
   - Run /reflect to review and promote

💡 Tips:
   - cleanupPeriodDays is default (30) — consider setting to 99999 for extended session retention
   - Consider adding a Compact Instructions section to CLAUDE.md
```

### Phase 3: Auto-Fix Safe Issues

Offer to auto-fix issues that are safe to change without review:

| Issue | Auto-Fix |
|-------|----------|
| Hook scripts not executable | `chmod +x` |
| Missing `.claude/session/` directory | `mkdir -p` |
| Missing meta-rule (99-rule-iteration.md) | Create from template |

Ask user before applying any fix: "Would you like me to auto-fix the safe issues listed above?"
