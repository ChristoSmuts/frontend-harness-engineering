# Framework → harness artifacts

Use during Phase B planning.

| Intake | Generate | Skip |
|--------|----------|------|
| shadcn/ui | `shadcn-components` skill, UI rule | — |
| MUI / Chakra | Customize `ui-components` rule; optional skill | shadcn skill |
| Next App Router | `next-app-router` skill | `vite-react`, `remix`, `nuxt`, `sveltekit`, `astro` skills |
| Vite + React | `vite-react` skill | `next-app-router`, framework-specific skills |
| Remix | `remix` skill | `next-app-router`, `vite-react`, `nuxt`, `sveltekit`, `astro` |
| Nuxt | `nuxt` skill | other framework skills |
| SvelteKit | `sveltekit` skill | other framework skills |
| Astro | `astro` skill | other framework skills |
| Vue + Vite | `vue-vite` skill | other framework skills |
| Angular | `angular` skill | other framework skills |
| React Native / Expo | `react-native-expo` skill | web framework skills |
| other / custom | `custom-framework` skill | framework-specific skills |
| TanStack Query | `data-fetching` skill | — |
| tRPC | Extend `data-fetching` skill content | — |
| Zod + RHF | `forms-validation` skill | — |
| Playwright | `playwright-e2e` skill (CI vs local subset in skill) | — |
| Storybook only | Mention in `AGENTS.md`; optional future skill | — |
| Figma MCP | Note in `AGENTS.md`; enable MCP only when needed | Always-on Figma MCP |
| Monorepo | Filter flags in `AGENTS.md` + verify hook | See [MONOREPO_HARNESS.md](MONOREPO_HARNESS.md) |
| No E2E | Skip `playwright-e2e` | — |
| Windows-primary (`platform_primary: windows`) | `hooks.windows.json.template` → `verify-frontend.ps1` | default `hooks.json.template` uses `.sh` |

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
