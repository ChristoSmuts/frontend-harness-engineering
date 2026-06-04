# Artifact manifest

Generate into the **target frontend project** (not into this toolkit unless maintaining templates).

## Priority legend

- **P0** — create on every bootstrap
- **P1** — create unless user opts out
- **P2** — create when intake matches
- **P3** — optional / failure-driven later

## P0 — Always

| Artifact | Target path | Template |
|----------|-------------|----------|
| Agent entry | `AGENTS.md` | `templates/AGENTS.md.template` |
| Core rule | `.cursor/rules/frontend-core.mdc` | `templates/rules/frontend-core.mdc.template` |
| Orchestration | `.cursor/ORCHESTRATION.md` | `templates/ORCHESTRATION.md.template` |

## P1 — Default on

| Artifact | Target path | Template |
|----------|-------------|----------|
| TS/React rule | `.cursor/rules/typescript-react.mdc` | `templates/rules/typescript-react.mdc.template` |
| UI rule | `.cursor/rules/ui-components.mdc` | `templates/rules/ui-components.mdc.template` |
| Hooks config | `.cursor/hooks.json` | `templates/hooks/hooks.json.template` |
| Verify script (Unix) | `.cursor/hooks/verify-frontend.sh` | `templates/hooks/verify-frontend.sh` |
| Verify script (Windows) | `.cursor/hooks/verify-frontend.ps1` | `templates/hooks/verify-frontend.ps1` |
| Shell guard | `.cursor/hooks/deny-dangerous.sh` | `templates/hooks/deny-dangerous.sh` |
| Verify skill | `.cursor/skills/frontend-verify/SKILL.md` | `templates/skills/frontend-verify/SKILL.md` |

## P2 — Conditional

| Condition | Artifact | Template |
|-----------|----------|----------|
| shadcn/ui | `.cursor/skills/shadcn-components/SKILL.md` | `templates/skills/shadcn-components/SKILL.md` |
| Next.js App Router | `.cursor/skills/next-app-router/SKILL.md` | `templates/skills/next-app-router/SKILL.md` |
| Vite + React (no Next) | `.cursor/skills/vite-react/SKILL.md` | `templates/skills/vite-react/SKILL.md` |
| TanStack Query / fetch patterns | `.cursor/skills/data-fetching/SKILL.md` | `templates/skills/data-fetching/SKILL.md` |
| Zod / RHF / forms | `.cursor/skills/forms-validation/SKILL.md` | `templates/skills/forms-validation/SKILL.md` |
| Playwright | `.cursor/skills/playwright-e2e/SKILL.md` | `templates/skills/playwright-e2e/SKILL.md` |
| a11y in PR checklist | `.cursor/skills/accessibility/SKILL.md` | `templates/skills/accessibility/SKILL.md` |

## P3 — Do not generate by default

- Dozens of MCP server configs
- LLM-generated 300-line agentfiles
- Role-based "frontend subagent" persona files
- Full E2E output on every agent stop
- Duplicate instructions in `AGENTS.md` and `alwaysApply` rules

## Post-generation checklist

- [ ] Target `AGENTS.md` ≤ ~60 lines
- [ ] Each rule ≤ ~50 lines, one concern
- [ ] Every skill `description` includes WHAT + WHEN
- [ ] Verify hook runs; only failures surface
- [ ] `ORCHESTRATION.md` describes sub-agents as context firewalls
- [ ] Commands match real `package.json` scripts (brownfield)
