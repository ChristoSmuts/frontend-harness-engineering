# Frontend harness bootstrap

You are bootstrapping **coding-agent harness + orchestration** for a **target frontend project** (the workspace the user is bootstrapping—not necessarily the "Frontend Harness Engineering" toolkit repo unless that is the target).

Follow this workflow exactly. Do not skip intake. Do not generate artifacts until intake is complete (or the user says **"use defaults"** for listed fields).

Reference toolkit paths (if this repo is available): `intake/QUESTIONNAIRE.md`, `manifest/ARTIFACT_MANIFEST.md`, `templates/`.

## Principles (non-negotiable)

1. **Harness = model + configuration** — optimize context, verification, and progressive disclosure.
2. **Thin always-on context** — target `AGENTS.md` and `alwaysApply` rules stay under ~60 lines each; one concern per rule file.
3. **Skills for depth** — framework, design system, E2E live in `.cursor/skills/` with `disable-model-invocation: true` unless the user requests auto-invoke.
4. **Sub-agents for context control** — document task-shaped delegation (locate, trace, research)—not role-based "frontend engineer" personas.
5. **Back-pressure** — hooks run fast lint + typecheck on `stop`; success is silent; only errors return to the agent.
6. **Failure-driven** — only add MCP servers, skills, and hooks the project needs; prefer CLI over bloated MCP tool lists.
7. **Inspect before inventing** — on brownfield repos, read `package.json`, existing `.cursor/`, `components.json`, and folder layout before generating.

## Phase A — Intake

Use the AskQuestion tool when available. Otherwise ask conversationally. Collect every item in `intake/QUESTIONNAIRE.md`. Infer from the repo when possible; only ask for gaps.

**Defaults shortcut:** user may say *"defaults: Next 15 App Router + pnpm + shadcn + Tailwind + Biome + Vitest + Playwright CI-only"* — then infer the rest from the repo.

## Phase B — Plan (user-visible)

Emit a **Harness Plan** table:

| Artifact | Path | Purpose | When loaded |
|----------|------|---------|-------------|

List only what this project needs (see `manifest/ARTIFACT_MANIFEST.md`). Wait for user approval unless they said **"generate without review"**.

## Phase C — Generate (in the target project)

Create project-scoped artifacts:

- Root `AGENTS.md` (from `templates/AGENTS.md.template`)
- `.cursor/rules/*.mdc` (from `templates/rules/`)
- `.cursor/skills/*/` (from `templates/skills/` — enable only relevant skills)
- `.cursor/hooks.json` + `.cursor/hooks/*` (from `templates/hooks/` — adapt commands to package manager and OS)
- `.cursor/ORCHESTRATION.md` (from `templates/ORCHESTRATION.md.template`)

Replace all `{{PLACEHOLDER}}` values. Remove unused skill folders or skip creating them.

Do not copy the entire toolkit into the target—only the selected artifacts.

## Phase D — Verify

Run the fast verification commands wired in hooks (lint + typecheck). Fix script paths if they fail. Summarize what was created (one short paragraph).

## Phase E — Handoff

Tell the user:

- How to invoke skills for common tasks
- That sub-agents should use the handoff format in `ORCHESTRATION.md`
- To extend harness **when the agent fails**, not preemptively with dozens of MCP tools

Do not `git commit` unless the user asks.
