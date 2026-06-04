# Orchestration — Fixture Cursor

How coding agents should work in this frontend repo.

## Context strategy

| Task | Approach |
|------|----------|
| Find files / map an area | Explore sub-agent or parallel explore tasks |
| Find symbol / needle | Direct Grep/Glob in parent, then Read |
| Implement UI change | Parent reads cited files only; edits locally |
| Full architecture survey | One explore sub-agent per concern (routing, data, UI) |

Do **not** use role-based sub-agents ("frontend engineer", "backend engineer"). Use **task-shaped** delegation.

## Sub-agent handoff contract

Include in every sub-agent prompt:

```text
Scope paths: src/**
Do not edit files.
Return format:
---
Answer: (max 5 sentences)
Sources: path:startLine-endLine per claim
Not found: (if applicable)
---
```

Parent agent: trust the summary; open **Sources** only when implementing.

## Skills index

Canonical skill files: `.cursor/skills//`. After editing, run `scripts/sync-skills.sh` when this repo uses mirrored tool paths.

| Skill | When to use |
|-------|-------------|
| `frontend-verify` | Before claiming done; lint + typecheck |
| `frontend-security` | auth, env, API keys, or security-sensitive UI/API work |
| `shadcn-components` | shadcn/ui components and primitives |
| `next-app-router` | App Router routes and RSC boundaries |
| `vite-react` | N/A — skill not installed |
| `data-fetching` | N/A — skill not installed |
| `forms-validation` | N/A — skill not installed |
| `playwright-e2e` | N/A — skill not installed |
| `accessibility` | N/A — skill not installed |

Remove rows for skills not installed in this project.

## MCP policy

Prefer CLI for git/GitHub.

Prefer CLI for git/GitHub when possible. Enable design/browser MCP only for tasks that need them; disable after to save context.

## When harness grows

Add one fix per repeatable failure: a rule line, skill section, or hook—not bulk MCP installs. Log team-visible changes in `HARNESS_CHANGELOG.md` when used. See your toolkit `docs/HARNESS_GROWTH.md`.
## Hooks (Cursor)

Configured in `.cursor/hooks.json`:

- **stop:** `verify-frontend` — format/lint + typecheck; success is silent
- **stop:** `scan-secrets` — scans git-changed files for high-confidence secret literals (if enabled)
- **beforeShellExecution:** `deny-dangerous` — blocks migrations, prod deploy, destructive git/shell (if enabled)

Other tools: use skill `frontend-verify` or commands in `AGENTS.md` before claiming done.
