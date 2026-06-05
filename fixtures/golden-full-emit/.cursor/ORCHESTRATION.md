# Orchestration — Fixture App

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

Canonical skill files: `.agents/skills//`. After editing, run `.agent-scripts/sync-skills.sh` when this repo uses mirrored tool paths.

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
| `harness-self-improve` | Repeat failure in ledger (count >= 2), user asks to stop repeating a mistake, or stop hook requests harness growth |

Remove rows for skills not installed in this project.

## MCP policy

Prefer CLI for git/GitHub. Enable design MCP only for design-to-code tasks.

Prefer CLI for git/GitHub when possible. Enable design/browser MCP only for tasks that need them; disable after to save context.

## When harness grows (self-improvement loop)

1. **Log** user corrections and verify failures to the failure ledger (`.agents/harness/failure-ledger.json` for `full` / `portable-only`; `.cursor/harness/` for `cursor-only`).
2. **Twice rule:** first occurrence = ledger only; second = load skill `harness-self-improve`.
3. **Apply** one minimal fix (rule line, skill section, hook pattern, or orchestration note)—not bulk MCP installs.
4. **Sync** canonical skills: `.agent-scripts/sync-skills.sh --all-mirrors --orchestration` (or `.ps1`).
5. **Validate:** `.agent-scripts/validate-target-harness.sh` (or `.ps1`).
6. **Log** team-visible changes in `HARNESS_CHANGELOG.md` with ledger fingerprint in the trigger column.

See toolkit `docs/HARNESS_GROWTH.md`.
## Hooks (Cursor)

Configured in `.cursor/hooks.json`:

- **stop:** `verify-frontend` — format/lint + typecheck; success is silent
- **stop:** `scan-secrets` — scans git-changed files for high-confidence secret literals (if enabled)
- **beforeShellExecution:** `deny-dangerous` — blocks migrations, prod deploy, destructive git/shell, `.env` reads, and outbound requests to hosts not in `allowed-domains.txt` (if enabled)
- **beforeMCPExecution:** `deny-unapproved-mcp` — blocks MCP servers not listed in `mcp-allowlist.json` (if `agent_security_hardening` enabled at bootstrap)

Other tools: use skill `frontend-verify` or commands in `AGENTS.md` before claiming done.
