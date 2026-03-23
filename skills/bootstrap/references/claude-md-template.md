# CLAUDE.md Template

Use this as the scaffold when creating a new CLAUDE.md. Replace `{detected}` values with findings from the codebase-analyzer agent.

---

# CLAUDE.md

## Project Identity
{One-line description from package.json or README}. {Production URL if applicable}.

## Tech Stack
| Layer | Technology |
|-------|-----------|
| Framework | {detected} |
| Database | {detected} |
| Auth | {detected} |
| Styling | {detected} |
| Deployment | {detected} |

## Non-Negotiable Conventions
1. {from codebase analysis — most important convention}
2. {from codebase analysis}
3. {from codebase analysis}

## Build & Run
```bash
{detected from package.json scripts}
```

## Key Gotchas
(Populated as the project grows — see .claude/rules/99-rule-iteration.md)

## Compact Instructions
When compacting, preserve: current task context, recent corrections, active learnings, and any in-progress architectural decisions.

## Rule Index
| File | Domain | Scope |
|------|--------|-------|
| 00-workspace | Identity + conventions | Always |
| 99-rule-iteration | Meta: iterate on rules | Always |

---

**Important:** The template above uses fenced code blocks. When the /bootstrap skill generates actual CLAUDE.md files, render these as real code fences (not escaped). The `Build & Run` section should contain the actual scripts detected from package.json.
