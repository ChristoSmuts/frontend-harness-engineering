# Artifact manifest

Generate into the **target frontend project** (not into this toolkit unless maintaining templates).

Apply **emit_strategy** from [docs/EMIT_STRATEGIES.md](../docs/EMIT_STRATEGIES.md). Paths below use **canonical** (`.agents/skills/`, `agents/ORCHESTRATION.md`) for `full` / `portable-only`; **cursor-only** uses `.cursor/skills/` as canonical per [TOOL_LAYOUT.md](TOOL_LAYOUT.md).

## Priority legend

- **P0** — create on every bootstrap (respect emit strategy skips)
- **P1** — create unless user opts out
- **P2** — create when intake matches
- **P3** — optional / failure-driven later

## P0 — Always

| Artifact | Cursor | Claude | Portable hub | Template |
|----------|--------|--------|--------------|----------|
| Agent entry | `AGENTS.md` | `AGENTS.md` | `AGENTS.md` | `templates/AGENTS.md.template` |
| Orchestration (shared) | — | `.claude/ORCHESTRATION.md` | `agents/ORCHESTRATION.md` | `templates/ORCHESTRATION.shared.md.template` |
| Orchestration (Cursor) | `.cursor/ORCHESTRATION.md` | — | — | shared + `templates/ORCHESTRATION.cursor-hooks.md.template` |
| Cursor hooks fragment | `.cursor/ORCHESTRATION.cursor-hooks.md` | — | — | `templates/ORCHESTRATION.cursor-hooks.md.template` (for sync) |
| Core rule | `.cursor/rules/frontend-core.mdc` | `.claude/rules/frontend-core.md` | — | `templates/rules/frontend-core.mdc.template` |
| Security rule | `.cursor/rules/frontend-security.mdc` | `.claude/rules/frontend-security.md` | — | `templates/rules/frontend-security.mdc.template` |
| Claude entry (optional) | — | `CLAUDE.md` | — | `templates/CLAUDE.md.template` |
| Gemini entry (optional) | — | — | `GEMINI.md` | `templates/GEMINI.md.template` |

## P1 — Default on

| Artifact | Cursor | Claude | Portable hub | Template |
|----------|--------|--------|--------------|----------|
| TS/React rule | `.cursor/rules/typescript-react.mdc` | `.claude/rules/typescript-react.md` | — | `templates/rules/typescript-react.mdc.template` |
| UI rule | `.cursor/rules/ui-components.mdc` | `.claude/rules/ui-components.md` | — | `templates/rules/ui-components.mdc.template` |
| Hooks config | `.cursor/hooks.json` | — | — | `hooks.json.template` (unix) or `hooks.windows.json.template` |
| Verify scripts | `.cursor/hooks/verify-frontend.sh` / `.ps1` | — | — | `templates/hooks/*` |
| Shell guard | `.cursor/hooks/deny-dangerous.sh` | — | — | `templates/hooks/deny-dangerous.sh` |
| Verify skill | mirror | mirror | **canonical** `.agents/skills/frontend-verify/` | `templates/skills/frontend-verify/SKILL.md` |
| Security skill | mirror | mirror | **canonical** `.agents/skills/frontend-security/` | `templates/skills/frontend-security/SKILL.md` |
| Secret scan hook | `.cursor/hooks/scan-secrets.*` | — | — | `templates/hooks/scan-secrets.sh` / `.ps1` (opt-out: `features.secret_scan_hook`) |
| Secret patterns lib | — | — | `scripts/lib/secret-patterns.*` | toolkit `scripts/lib/` (copied on emit) |
| Harness changelog (teams) | — | — | `HARNESS_CHANGELOG.md` | `templates/HARNESS_CHANGELOG.md.template` |
| Maintenance scripts | `scripts/sync-skills.sh` + `.ps1` | — | — | toolkit `scripts/` (**every** emit) |
| Validate scripts | `scripts/validate-target-harness.sh` + `.ps1` | — | — | toolkit `scripts/` (**every** emit) |
| Harness CI workflow (teams) | — | — | `.github/workflows/harness-validate.yml` | `templates/github/workflows/harness-validate.yml.template` |
| Codex config (opt-in) | — | — | `.codex/config.toml` | `templates/codex/config.toml.template` |

## P2 — Conditional skills

Write to **canonical** skills dir first; mirror on `full` emit.

| Condition | Skill name | Template |
|-----------|------------|----------|
| shadcn/ui | `shadcn-components` | `templates/skills/shadcn-components/SKILL.md` |
| Next.js App Router | `next-app-router` | `templates/skills/next-app-router/SKILL.md` |
| Vite + React (no Next) | `vite-react` | `templates/skills/vite-react/SKILL.md` |
| Remix | `remix` | `templates/skills/remix/SKILL.md` |
| Nuxt | `nuxt` | `templates/skills/nuxt/SKILL.md` |
| SvelteKit | `sveltekit` | `templates/skills/sveltekit/SKILL.md` |
| Astro | `astro` | `templates/skills/astro/SKILL.md` |
| Vue + Vite | `vue-vite` | `templates/skills/vue-vite/SKILL.md` |
| Angular | `angular` | `templates/skills/angular/SKILL.md` |
| React Native / Expo | `react-native-expo` | `templates/skills/react-native-expo/SKILL.md` |
| other / custom | `custom-framework` | `templates/skills/custom-framework/SKILL.md` |
| TanStack Query / fetch | `data-fetching` | `templates/skills/data-fetching/SKILL.md` |
| Zod / RHF / forms | `forms-validation` | `templates/skills/forms-validation/SKILL.md` |
| Playwright | `playwright-e2e` | `templates/skills/playwright-e2e/SKILL.md` |
| a11y in PR checklist | `accessibility` | `templates/skills/accessibility/SKILL.md` |
| Parallel agents (opt-in) | — | `templates/rules/harness-immutable.mdc.template` |

## P3 — Do not generate by default

- Dozens of MCP server configs
- LLM-generated 300-line agentfiles
- Role-based "frontend subagent" persona files
- Full E2E output on every agent stop
- Duplicate instructions in `AGENTS.md` and `alwaysApply` rules

## Legacy template

`templates/ORCHESTRATION.md.template` — monolithic; prefer **shared + cursor-hooks** split for new bootstraps.

## Post-generation checklist

- [ ] Target `AGENTS.md` ≤ ~60 lines
- [ ] No unreplaced `{{` tokens (validate script: bash or `pwsh -File scripts/validate-target-harness.ps1`)
- [ ] Each rule ≤ ~50 lines, one concern
- [ ] Every skill `description` includes WHAT + WHEN
- [ ] Verify hook runs; only failures surface
- [ ] `agents/ORCHESTRATION.md` describes sub-agents as context firewalls
- [ ] Mirrors match canonical after `scripts/sync-skills.sh` (`full` emit)
- [ ] Commands match real `package.json` scripts (brownfield)
