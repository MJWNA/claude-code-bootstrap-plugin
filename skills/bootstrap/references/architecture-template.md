# Architecture Template

Use this as the scaffold when creating ARCHITECTURE.md.

---

# Architecture

> Last updated: {date}. Run /bootstrap or /audit-rules to refresh.

## System Overview
{ASCII diagram generated from codebase-analyzer output showing major layers and their relationships}

## Route Architecture
| Route Group | URL Prefix | Purpose |
|-------------|-----------|---------|
| {detected} | {detected} | {detected} |

## Module Boundaries
{from codebase-analyzer modules output — list each module with its public API}

## Data Architecture
{from schema files if detected — tables, key relationships, naming conventions}

## External Integrations
| Service | Purpose | Package |
|---------|---------|---------|
| {detected from package.json} | {detected} | {detected} |

## Tech Decisions Log
| Decision | Rationale |
|----------|-----------|
| (populated as decisions are made) | |
