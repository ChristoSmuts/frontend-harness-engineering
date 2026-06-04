# Framework → harness artifacts

Use during Phase B planning.

| Intake | Generate | Skip |
|--------|----------|------|
| shadcn/ui | `shadcn-components` skill, UI rule | — |
| MUI / Chakra | Customize `ui-components` rule; optional skill | shadcn skill |
| Next App Router | `next-app-router` skill | `vite-react` skill |
| Vite + React | `vite-react` skill | `next-app-router` skill |
| TanStack Query | `data-fetching` skill | — |
| tRPC | Extend `data-fetching` skill content | — |
| Zod + RHF | `forms-validation` skill | — |
| Playwright | `playwright-e2e` skill (CI vs local subset in skill) | — |
| Storybook only | Mention in `AGENTS.md`; optional future skill | — |
| Figma MCP | Note in `AGENTS.md`; enable MCP only when needed | Always-on Figma MCP |
| Monorepo | Filter flags in `AGENTS.md` + verify hook | — |
| No E2E | Skip `playwright-e2e` | — |
| Windows-primary team | `verify-frontend.ps1` in hooks | or both sh + ps1 |

## Package manager → hook commands

| Manager | Install | Run script |
|---------|---------|------------|
| pnpm | `pnpm install` | `pnpm run <script>` |
| npm | `npm install` | `npm run <script>` |
| yarn | `yarn` | `yarn <script>` |
| bun | `bun install` | `bun run <script>` |

## Monorepo verify example

```bash
pnpm exec turbo run typecheck lint --filter={{APP_PACKAGE_NAME}}
```

Replace in `verify-frontend.sh` / `.ps1` and `AGENTS.md`.
