---
name: bootstrap
description: Analyse workspace and create/audit Claude Code configuration. Use when entering a new repo, setting up a project, or when workspace config is missing or weak.
---

# Bootstrap Workspace

Analyse the current workspace and scaffold or audit Claude Code configuration. Creates all 6 artefacts: CLAUDE.md, rules, hooks, ARCHITECTURE.md, session directory, and meta-rule.

## Workflow

### Phase 1: Investigation (parallel agents)

Dispatch 3 agents simultaneously:

1. **codebase-analyzer** — Scan directory structure, tech stack (package.json + code), import patterns, file naming, module boundaries, external dependencies
2. **git-history-analyzer** — Scan last 20 commits, file churn, emerging patterns, contributor areas
3. **config-analyzer** — Check existing .claude/ config, CLAUDE.md, ARCHITECTURE.md, session files, memory

### Phase 2: Cross-Reference

Compare agent outputs to determine:
- **New workspace** (no config exists) → full scaffold
- **Existing workspace** (partial config) → gap analysis + targeted patches

### Phase 3: Generate Proposal

Using templates from `references/`, generate:

1. **CLAUDE.md** — see `references/claude-md-template.md`
   - Fill `{detected}` placeholders with codebase-analyzer findings
   - Include Compact Instructions section
   - Target under 80 lines

2. **`.claude/rules/00-workspace.md`** — see `references/rule-templates.md`
   - Universal identity rule (no path-scoping)
   - Populated from codebase-analyzer patterns
   - Include path-scoping limitation warning and YAML quoting note

3. **`.claude/rules/99-rule-iteration.md`** — see `references/rule-templates.md`
   - Meta-rule that drives the evolution loop
   - References /audit-rules, /reflect, /health-check

4. **Domain rules** — Generate path-scoped rules for major areas detected by codebase-analyzer
   - Example: `60-app-architecture.md` with `paths: ["app/**"]`
   - Follow numbering convention: 10-49 domain, 60-69 app arch

5. **ARCHITECTURE.md** — see `references/architecture-template.md`
   - System overview with ASCII diagram
   - Route architecture, module boundaries, data architecture
   - External integrations table
   - Tech decisions log (empty, populated as decisions are made)

6. **`.claude/session/`** — Create directory if missing

### Phase 4: Present & Approve

Present the complete proposal to the user:
- Show each file's content or summary
- Highlight what's new vs what would be modified
- Wait for user approval before writing anything

### Phase 5: Write & Commit

On approval:
1. Write all files
2. `git add CLAUDE.md ARCHITECTURE.md .claude/`
3. `git commit -m "feat: add Claude Code project configuration"`

## Quality Standards

Apply these tests to all generated content:
- **Deletion test:** Would removing this line cause a mistake? If no → don't include
- **Discoverability test:** Could Claude find this from the code? If yes → don't include
- **Positive framing:** "Use X" not "Don't use Y"
- **No duplication:** Each fact lives in one place only
