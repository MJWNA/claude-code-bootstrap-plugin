---
name: reflect
description: Review the learnings queue. Promote corrections and patterns to rules or CLAUDE.md with human approval.
disable-model-invocation: true
---

# Reflect — Learning Promotion

Review the learnings queue accumulated by hooks. Promote worthy items to rules or CLAUDE.md with human approval.

## Learnings Queue Location

`${CLAUDE_PLUGIN_ROOT}/data/learnings-queue.json`

If the queue is empty, inform the user: "📋 Learnings queue is empty. Learnings are captured automatically during your sessions via correction detection and session-end reflection."

## Workflow

### Step 1: Read & Group

Read the learnings queue. Group by confidence level:

1. **HIGH** (corrections) — "no, use X", "actually...", "wrong", "stop doing" — present first
2. **MEDIUM** (confirmations) — "perfect", "yes exactly", "good call" — present second
3. **LOW** (suggestions) — indirect or contextual learnings — present third

### Step 2: Apply Guards

For each learning, evaluate:

| Guard | Check | Action if Fails |
|-------|-------|----------------|
| **Deletion test** | Would removing this cause a real mistake? | Recommend discard |
| **Duplication test** | Does this already exist in a rule or CLAUDE.md? | Recommend discard |
| **Bloat test** | Would adding to CLAUDE.md push it over 80 lines? | Recommend rule file instead |
| **Promotion threshold** | Seen 3+ times (occurrences field)? | Flag as strong candidate ⭐ |
| **Positive framing** | Phrased as "use X" not "don't use Y"? | Rewrite before promoting |

### Step 3: Present Recommendations

For each learning:

```
📋 Learning #1 [HIGH] ⭐ (seen 5 times)
"Use neon-http driver for stateless queries, not neon-serverless"
Source: correction-detect | First seen: 2026-03-20 | Workspace: /Users/.../project

Recommendation: PROMOTE → .claude/rules/61-database-schema.md
Guard results: ✅ deletion ✅ duplication ✅ bloat ⭐ promotion (5x)

Action? [P]romote / [D]efer / [X] Discard
```

### Step 4: Apply Decisions

- **Promote** → Write to the specified rule file or CLAUDE.md. If rule file doesn't exist, create it with proper path-scoping frontmatter.
- **Defer** → Keep in queue with status "pending" for next /reflect
- **Discard** → Set status to "discarded" (kept for audit trail, filtered from future /reflect views)

### Step 5: Summary

After all items processed:
```
📊 Reflect Summary:
  Promoted: 3 (2 to rules, 1 to CLAUDE.md)
  Deferred: 1
  Discarded: 2
  Remaining in queue: 4 pending items
```

## Cross-Workspace Learning

Learnings from all workspaces accumulate in one queue. If a learning appears across 3+ different workspaces, recommend promotion to a **global rule** (`~/.claude/rules/`) rather than a project rule.
