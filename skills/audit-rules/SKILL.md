---
name: audit-rules
description: Deep analysis of workspace rules, CLAUDE.md, and architecture docs against actual codebase state. Finds staleness, gaps, redundancy, and drift.
disable-model-invocation: true
---

# Audit Rules

Deep analysis of workspace configuration against actual codebase state. Dispatches parallel agents to find staleness, gaps, redundancy, and drift.

## Workflow

### Phase 1: Investigation (parallel agents)

Dispatch 3 agents simultaneously:

1. **codebase-analyzer** — Current code patterns, imports, naming, structure, module boundaries
2. **git-history-analyzer** — What changed since rules were last updated, file churn, emerging patterns
3. **config-analyzer** — All rules with line counts, CLAUDE.md analysis, ARCHITECTURE.md state

### Phase 2: Cross-Reference

Compare agent outputs to identify:

| Category | Detection Logic |
|----------|----------------|
| **STALENESS** | Rules reference patterns that no longer exist in the code |
| **GAPS** | Code patterns (3+ occurrences) with no matching rule |
| **REDUNDANCY** | Same content in CLAUDE.md AND a rule file, or duplicated across rules |
| **DRIFT** | Git shows an area has evolved significantly since its rule was last modified |
| **BLOAT** | CLAUDE.md over 80 lines, any rule file over 200 lines |

### Phase 3: Present Findings

Format as a table:

| # | Category | File | Issue | Proposed Fix |
|---|----------|------|-------|-------------|
| 1 | STALENESS | 10-domain.md:15 | References `UserService` but it was renamed to `AccountService` | Update rule |
| 2 | GAP | (none) | `drizzle-orm` import pattern used 12 times, no rule | Create 61-database.md |
| 3 | REDUNDANCY | CLAUDE.md:45 ↔ 00-workspace.md:12 | Same convention documented twice | Remove from CLAUDE.md |
| 4 | DRIFT | 60-app.md | Last modified 2 weeks ago, 14 commits to app/ since | Review and update |
| 5 | BLOAT | CLAUDE.md | 94 lines (target: 80) | Move 3 gotchas to domain rules |

### Phase 4: Apply Fixes

User approves per-item. For each approved fix:
- **Update**: Edit the specific rule file
- **Create**: Generate new path-scoped rule from template
- **Delete**: Remove duplicated content
- **Move**: Relocate content from CLAUDE.md to rule file
- Commit after all fixes applied

## Quality Standards

Same as /bootstrap — deletion test, discoverability, positive framing, no duplication.
