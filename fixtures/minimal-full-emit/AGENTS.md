# Fixture App — agent guide

## Stack

Next.js 15 App Router · TypeScript · Tailwind · shadcn/ui

## Layout

- Routes/pages: `src/app`
- Components: `src/components`
- Shared UI: `src/components/ui`
- API / data client: `src/lib/api`

## Commands (fast verification)

- Install: `pnpm install`
- Lint/format: `pnpm biome check --write .`
- Typecheck: `pnpm exec tsc --noEmit`
- E2E: use skill `playwright-e2e` or CI only

## Do not edit

`.next`, `dist`, `node_modules`

## Harness

- **Emit strategy:** full (toolkit CI smoke — partial tree, not manifest-complete) · **Harness owner:** solo · **Platform primary:** unix
- **Canonical skills:** `.agents/skills/` — edit here; run `.agent-scripts/sync-skills.sh` or `.agent-scripts/sync-skills.ps1 -AllMirrors` after changes
- **Shared entry:** `AGENTS.md` (this file)
- **Orchestration:** `agents/ORCHESTRATION.md` · Cursor: `.cursor/ORCHESTRATION.md`
- **Cursor:** rules `.cursor/rules/`, skills `.cursor/skills/` (mirror), hooks `.cursor/hooks.json`
- **Validate:** `bash .agent-scripts/validate-target-harness.sh` or `pwsh -File .agent-scripts/validate-target-harness.ps1`

## Sub-agents

For broad search or flow tracing, delegate to an explore sub-agent. Require replies with **Sources** as `path:startLine-endLine`. Parent opens only cited files.
