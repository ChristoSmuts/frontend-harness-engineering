# Orchestration — Fixture App

How coding agents should work in this frontend repo.

## Context strategy

| Task | Approach |
|------|----------|
| Find files / map an area | Explore sub-agent |
| Implement UI change | Parent reads cited files only |

Do **not** use role-based sub-agents. Use **task-shaped** delegation.

## Sub-agent handoff contract

```text
Scope paths: src/**
Do not edit files.
Return format:
---
Answer: (max 5 sentences)
Sources: path:startLine-endLine per claim
---
```

## Skills index

Canonical: `.agents/skills/`. Run `.agent-scripts/sync-skills.sh` after edits when mirrors exist.

| Skill | When to use |
|-------|-------------|
| `frontend-verify` | Before claiming done |

## MCP policy

Prefer CLI for git/GitHub. Enable design MCP only when needed.
