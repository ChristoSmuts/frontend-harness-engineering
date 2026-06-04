---
name: frontend-harness-bootstrap
description: Bootstraps Cursor harness artifacts (AGENTS.md, .cursor/rules, skills, hooks, orchestration) for frontend projects from intake and templates. Use when starting a new frontend repo, setting up agent harness, coding agent configuration, frontend orchestration, or when the user mentions Frontend Harness Engineering bootstrap.
disable-model-invocation: true
---

# Frontend harness bootstrap

Bootstrap **coding-agent harness + orchestration** for the current workspace (the target frontend project).

## Before you start

1. Read `prompts/MASTER_BOOTSTRAP.md` from the Frontend Harness Engineering toolkit if available in workspace or path the user provides.
2. Otherwise follow the phases below using templates from `templates/` in that toolkit or paths the user gives.

## Phases

### A — Intake

- Use `intake/QUESTIONNAIRE.md` (AskQuestion when available).
- Brownfield: read `package.json`, `components.json`, existing `.cursor/`, app tree first.
- Accept **defaults** shortcut from questionnaire if user provides it.

### B — Plan

- Build table from `manifest/ARTIFACT_MANIFEST.md` (P0/P1/P2 only what applies).
- Show create / merge / skip for existing harness files.
- Wait for approval unless user said generate without review.

### C — Generate

- Write into **current workspace root** (target project).
- Templates: `templates/AGENTS.md.template`, `templates/ORCHESTRATION.md.template`, `templates/rules/*`, `templates/skills/*`, `templates/hooks/*`.
- Replace all `{{PLACEHOLDER}}` tokens.
- Do not create unused P2 skills.

### D — Verify

- Run lint + typecheck commands from generated `AGENTS.md` / verify hook.
- Fix broken script paths.

### E — Handoff

- Summarize artifacts created and how to use skills + sub-agents.
- Remind: extend harness when agent fails, not preemptively with many MCP tools.

## Non-negotiable principles

- Thin `AGENTS.md` (~60 lines max in target)
- One concern per rule file (~50 lines)
- Sub-agents for locate/trace/research with `path:line` handoff — not "frontend engineer" personas
- Hooks: silent on success, errors only to agent
- Prefer CLI over large MCP tool lists when training data already covers the tool

## Placeholders reference

Common replacements: `{{PROJECT_NAME}}`, `{{FRAMEWORK}}`, `{{PACKAGE_MANAGER}}`, `{{LINT_CMD}}`, `{{TYPECHECK_CMD}}`, `{{ROUTES_PATH}}`, `{{COMPONENTS_PATH}}`, `{{UI_LIBRARY}}`, `{{FORBIDDEN_PATHS}}`, `{{APP_PACKAGE_NAME}}` (monorepo).

See template files for full list.
