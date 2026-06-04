# Fixture Portable — agent guide

## Stack

Next.js 15 App Router · TypeScript · Tailwind · shadcn/ui

## Layout

- Routes/pages: `src/app`
- Components: `src/components`
- Shared UI: `src/components/ui`
- API / data client: `src/lib/api`

## Commands (fast verification)

Use these for agent self-check—not full CI.

- Install: `pnpm install`
- Lint/format: `pnpm biome check --write .`
- Typecheck: `pnpm exec tsc --noEmit`
- Unit (single file): `pnpm vitest run path/to/file.test.tsx`
- E2E: use skill `playwright-e2e` or CI only—do not run the full suite after small edits

## Do not edit

`.next`, `dist`, `node_modules`

## Security

- Follow rule **`frontend-security`** and skill **`frontend-security`** for auth, env vars, API keys, and client/server boundaries.

## Harness

- **Emit strategy:** portable-only · **Harness owner:** solo · **Platform primary:** unix
- **Canonical skills:** `.agents/skills/` — edit here; run `scripts/sync-skills.sh` after skill edits
- **Shared entry:** `AGENTS.md` (this file)
- **Orchestration:** `agents/ORCHESTRATION.md`
- **Codex CLI:** skills `.agents/skills/` (canonical)

- **Validate harness:** `bash scripts/validate-target-harness.sh` (Linux/macOS) or `pwsh -File scripts/validate-target-harness.ps1` (Windows/macOS with pwsh); use `--strict` in CI

- **Other tools:** run skill `frontend-verify` or the lint/typecheck commands in this file before claiming done

## Sub-agents

For broad search or flow tracing, delegate to an explore sub-agent. Require replies with **Sources** as `path:startLine-endLine`. Parent opens only cited files.
