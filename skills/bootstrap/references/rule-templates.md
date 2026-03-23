# Rule Templates

## 00-workspace.md (always-on, no path-scoping)

```markdown
# Workspace

## Architecture
- {top-level directory descriptions from codebase-analyzer}
- {major modules/domains identified}

## Conventions
- {language conventions detected — e.g. Australian English}
- {import patterns detected — e.g. path aliases}
- {file naming conventions detected}
- {component patterns detected}

## Gotchas
- Path-scoped rules only trigger on file READ, not WRITE/CREATE
- Quote glob patterns starting with { or * in YAML frontmatter (e.g. `"*.ts"` not `*.ts`)
```

## 99-rule-iteration.md (always-on, no path-scoping)

```markdown
# Rule Iteration

When implementing features or discovering patterns, update the config:

## After Every Commit
- Pattern used 3+ times → extract into a path-scoped rule
- Existing rule contradicted by code → update the rule
- Gotcha discovered → add to CLAUDE.md Key Gotchas OR domain rule (not both)
- Architecture changed → update ARCHITECTURE.md

## After Every Milestone
- Run /audit-rules to check for staleness, gaps, redundancy, drift
- Run /reflect to review and promote queued learnings
- Run /health-check to verify config integrity
- Check CLAUDE.md is still under 80 lines — move content to rules if not

## Quality Tests (apply before adding anything)
- Deletion test: would removing this cause a mistake? If no → don't add
- Duplication test: does this exist elsewhere? If yes → don't duplicate
- Discoverability test: could Claude find this from the code? If yes → don't add
- Positive framing: "use X" not "don't use Y"
```

## Domain Rule Template (path-scoped)

```markdown
---
paths:
  - "{detected path glob}"
---

# {Domain Name}

## {Section}
- {actionable instruction from codebase analysis}
- {another instruction}
```
