# Frontend harness intake questionnaire

The bootstrap agent collects these fields before generating artifacts. Infer from the repo when possible.

**Start here:** [INTAKE_OVERVIEW.md](INTAKE_OVERVIEW.md) — what bootstrap produces and what each answer controls.

Optional machine-readable export: [answers.schema.json](answers.schema.json) and [answers.example.json](answers.example.json). Use with `scripts/emit-from-intake.sh` for reproducible P0+P1+P2 emit (see [docs/EMIT_FROM_INTAKE.md](../docs/EMIT_FROM_INTAKE.md)).

**Do not commit per-project answers JSON into this toolkit repo.** Export to the target app (e.g. `.harness-intake/answers.json`, gitignored), OS temp, or `~/frontend-harness-intake/`. Only `answers.example.json` and `answers.schema.json` belong under `intake/` here.

## Phase A — AskQuestion bundle (agent)

See [INTAKE_OVERVIEW.md](INTAKE_OVERVIEW.md) for the full flow. **Collect `target_path` before** the preference form when the toolkit is open.

### Step 1 — Workspace (only when ambiguous)

| Question id | Options |
|-------------|---------|
| **workspace_context** | `target_repo_open` — app repo is open; harness files go here · `toolkit_open` — toolkit is open; I will paste the app path next |

When auto-detect is confident, skip this question.

### Step 2 — Harness preferences (after `target_path` resolved)

When using AskQuestion, run **one form** in this order:

| # | Question id | Options (use these labels in AskQuestion) |
|---|-------------|-------------------------------------------|
| 1 | **emit_strategy** | `full` — multi-tool: canonical `.agents/skills/` + Cursor/Claude mirrors + hooks · `portable-only` — `AGENTS.md` + `.agents/skills/` only (no Cursor rules/hooks) · `cursor-only` — Cursor rules/skills/hooks only (solo Cursor) |
| 2 | **primary_tool** | Cursor · Claude Code · Codex CLI · Gemini CLI · other |
| 3 | **tools_in_use** | multi-select: same list + other |
| 4 | **platform_primary** | `unix` — hooks use bash/sh templates · `windows` — hooks use PowerShell 7 templates |
| 5 | **harness_owner** | `solo` — I own harness changes · `team` — team owns harness (get `@handle` in chat) |
| 6 | **delivery_mode** | `standard` — include `.agent-scripts/`, optional Cursor hooks, optional harness CI · `agent-only` — agent-readable files only (no shell scripts, hooks, or workflows) |
| 7 | **hooks_prefs** | `full` — lint + typecheck + secret scan + shell guard on stop · `no_secret_scan` — verify + shell guard, no secret scan · `verify_only` — lint + typecheck only · `no_hooks` — no Cursor stop hooks *(skipped when `delivery_mode` is `agent-only`)* |
| 8 | **repo_type** | `brownfield` — existing codebase (merge/skip existing harness) · `greenfield` — new or minimal project |

**target_path rules (before Step 2):**

- **Target repo open** → `target_path` = `.`; ask for **toolkit_path** if not obvious.
- **Toolkit open** → user **must** paste absolute **target_path** before Step 2 (spaces OK). Default `toolkit_path` = `.`.

Windows paths for emit JSON: prefer `C:/dev/app` or `/c/dev/app` (see [docs/CROSS_PLATFORM.md](../docs/CROSS_PLATFORM.md)).

## Required before Phase C

| Field | Example | Notes |
|-------|---------|-------|
| **target_path** | macOS `/Users/you/dev/acme-web` · Linux `/home/you/projects/acme-web` · Windows `C:\dev\acme-web` or `C:/dev/acme-web` | Absolute path to the **frontend repo** where harness files are emitted. Use `.` when the open workspace is already that repo. **Required** when the open workspace is this toolkit (detect `manifest/ARTIFACT_MANIFEST.md` + `prompts/MASTER_BOOTSTRAP.md` at root). Monorepo app paths (e.g. `apps/web`) are relative to `target_path`. See [docs/CROSS_PLATFORM.md](../docs/CROSS_PLATFORM.md). |
| **toolkit_path** | `.` (toolkit open) · `tools/frontend-harness/` · submodule path | Must contain `templates/` before Phase C |
| **emit_strategy** | `full` / `portable-only` / `cursor-only` | See [docs/EMIT_STRATEGIES.md](../docs/EMIT_STRATEGIES.md) |
| **primary_tool** | Cursor, Claude Code, Codex CLI, Gemini CLI | Most-used agent product |
| **harness_owner** | `@handle` or `solo` | Who approves harness PRs |
| **canonical_skills_dir** | `.agents/skills/` | Default; `.cursor/skills/` only for `cursor-only` without CLI tools |
| **harness_scripts_dir** | `.agent-scripts` | Harness validate/sync in target (not app `scripts/`) |
| **platform_primary** | `unix` / `windows` | Drives `hooks.json` template ([docs/CROSS_PLATFORM.md](../docs/CROSS_PLATFORM.md)); ignored when `delivery_mode` is `agent-only` |
| **delivery_mode** | `standard` / `agent-only` | `standard` (default) copies maintenance scripts and optional hooks/CI; `agent-only` emits docs, rules, skills, and JSON allowlists only |

## A. Project identity

| Field | Example |
|-------|---------|
| Project name | `acme-web` |
| Repo type | greenfield / brownfield |
| Monorepo | yes / no — if yes, app package path(s) e.g. `apps/web` |
| Package manager | pnpm / npm / yarn / bun |

## B. Framework & runtime

| Field | Example |
|-------|---------|
| Framework | Next.js App Router, Vite+React, Remix, Nuxt, SvelteKit, Astro |
| Versions | Next 15, React 19 |
| Router/layout conventions | where `app/`, layouts, `loading.tsx` live |
| Rendering | RSC / SSR / CSR expectations |

## C. Language & quality

| Field | Example |
|-------|---------|
| TypeScript strict | yes / no |
| Path aliases | `@/*` → `./src/*` |
| Linter/formatter | Biome / ESLint + Prettier |
| Lint command | `pnpm biome check --write .` |
| Typecheck command | `pnpm exec tsc --noEmit` or `turbo run typecheck --filter=web` |
| Unit tests | Vitest / Jest / none |
| E2E | Playwright / Cypress / none |
| E2E policy for agent | CI only / subset command / never in session |

## D. UI & design system

| Field | Example |
|-------|---------|
| Component library | shadcn/ui, MUI, Chakra, internal, none |
| Styling | Tailwind, CSS modules, styled-components |
| Tokens location | `globals.css`, `theme.ts` |
| Figma / design MCP | yes / no |
| `components.json` path | if shadcn |

## E. Structure & conventions

| Field | Example |
|-------|---------|
| Pages/routes path | `src/app` or `app/` |
| Components path | `src/components` |
| Features path | `src/features` (optional) |
| Hooks / lib paths | `src/hooks`, `src/lib` |
| API client path | `src/lib/api` |
| Barrel imports | allowed / avoid |
| Forbidden edit paths | `.next`, `dist`, `node_modules`, generated |

## F. Data & API (frontend-facing)

| Field | Example |
|-------|---------|
| Data fetching | fetch, TanStack Query, tRPC, server actions |
| Error/loading UI pattern | brief description or file path |
| Public env prefix | `NEXT_PUBLIC_` |
| Auth stack | none, NextAuth, Clerk, custom BFF, etc. |

## G. Harness preferences

| Field | Example |
|-------|---------|
| MCP servers to enable | list, or "none / minimal" |
| CLI preferred over MCP | gh, linear custom CLI, etc. |
| Hooks on stop | format + typecheck yes/no |
| Shell guards | deny migrations, deploy, `rm -rf` yes/no |
| Secret scan hook (Cursor stop) | scan git-changed files for secret literals yes/no (default yes) |
| Agent security hardening | MCP allowlist hook, allowed-domains, strict harness integrity yes/no (default no) |
| Gitleaks CI | `.github/workflows/secret-scan.yml` on push/PR yes/no (default no) |
| MCP allowlist | server ids when hardening enabled, e.g. `cursor-ide-browser` |
| Self-improvement loop | auto-grow harness on repeat failures yes/no (default yes) |
| Product in-app AI (BAML) | yes / no — separate from coding-agent harness |

## H. Team workflow

| Field | Example |
|-------|---------|
| Issue tracker | Linear, GitHub Issues, Jira |
| PR checklist | screenshots, a11y, Storybook |
| CI commands agent must not dump | full E2E, full test suite |

## I. AI coding tools

| Field | Example |
|-------|---------|
| Tools in use (multi) | Cursor, Claude Code, Codex CLI, Gemini CLI, GitHub Copilot, other |
| Primary tool | (also in Required table) where the developer spends most agent time |
| Emit strategy | `full` / `portable-only` / `cursor-only` — see [docs/EMIT_STRATEGIES.md](../docs/EMIT_STRATEGIES.md) |

If the user does not specify tools, ask once. Default for a solo dev is often **Cursor only** with `cursor-only` emit; teams mixing CLI and IDE should select every tool they use and prefer **`full`** with canonical `.agents/skills/` (see `manifest/TOOL_LAYOUT.md`).

---

## Defaults bundle (optional)

User says:

> defaults: Next 15 App Router + pnpm + shadcn + Tailwind + Biome + Vitest + Playwright CI-only

Agent infers remaining paths from repo structure and `package.json`.
