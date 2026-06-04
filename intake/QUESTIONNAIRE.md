# Frontend harness intake questionnaire

The bootstrap agent collects these fields before generating artifacts. Infer from the repo when possible.

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

## G. Harness preferences

| Field | Example |
|-------|---------|
| MCP servers to enable | list, or "none / minimal" |
| CLI preferred over MCP | gh, linear custom CLI, etc. |
| Hooks on stop | format + typecheck yes/no |
| Shell guards | deny migrations, deploy, `rm -rf` yes/no |
| Product in-app AI (BAML) | yes / no — separate from Cursor harness |

## H. Team workflow

| Field | Example |
|-------|---------|
| Issue tracker | Linear, GitHub Issues, Jira |
| PR checklist | screenshots, a11y, Storybook |
| CI commands agent must not dump | full E2E, full test suite |

---

## Defaults bundle (optional)

User says:

> defaults: Next 15 App Router + pnpm + shadcn + Tailwind + Biome + Vitest + Playwright CI-only

Agent infers remaining paths from repo structure and `package.json`.
