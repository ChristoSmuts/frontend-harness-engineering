# Parallel coding agents

Guidance when multiple agent sessions (Cursor chat, Cloud Agents, Claude Code, Codex) may run on the same repo concurrently.

## Core rules

1. **Branch per task** — One feature branch per agent session; avoid two agents on `main`.
2. **Harness is shared state** — Do not edit `AGENTS.md`, skills, rules, or `ORCHESTRATION.md` during feature work unless that *is* the task.
3. **Sub-agents are read-only** — Handoff contract: no file edits; parent implements from citations.
4. **Verify once per task** — Parent runs `frontend-verify` or stop hook before claiming done; sub-agents do not need separate full lint runs.

## Sibling agents (two top-level sessions)

| Risk | Mitigation |
|------|------------|
| Same file edited twice | Disjoint scope globs in orchestration notes; split by feature folder |
| Harness drift | Optional `harness-immutable` rule ([templates/rules/harness-immutable.mdc.template](../templates/rules/harness-immutable.mdc.template)) |
| Hook noise | Cursor stop hook per session is OK; avoid auto-format wars—commit or stash between agents |

## Cloud / background agents

- Treat like any session: branch, scope prompt, read-only explore sub-agents.
- Do not assume harness on disk matches remote branch until pull/rebase.
- Document long-running agent tasks in issue tracker; harness owner reviews harness commits separately.

## Sub-agent handoff (reminder)

```text
Scope paths: src/features/checkout/**
Do not edit files.
Return format:
---
Answer: (max 5 sentences)
Sources: path:startLine-endLine per claim
---
```

## See also

- [HARNESS_GROWTH.md](HARNESS_GROWTH.md)
- [TEAM_GOVERNANCE.md](TEAM_GOVERNANCE.md)
