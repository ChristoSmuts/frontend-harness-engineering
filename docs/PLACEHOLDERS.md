# Placeholder tokens

Replace all `{{TOKEN}}` values when generating into a target project.

| Token | Description | Example |
|-------|-------------|---------|
| `{{PROJECT_NAME}}` | Display name | `Acme Web` |
| `{{FRAMEWORK}}` | Stack label | `Next.js 15 App Router` |
| `{{STYLING}}` | CSS approach | `Tailwind v4` |
| `{{UI_LIBRARY}}` | Components | `shadcn/ui` |
| `{{ROUTES_PATH}}` | Pages | `src/app` |
| `{{COMPONENTS_PATH}}` | UI components | `src/components` |
| `{{SHARED_UI_PATH}}` | Primitives | `src/components/ui` |
| `{{API_CLIENT_PATH}}` | API layer | `src/lib/api` |
| `{{PACKAGE_MANAGER}}` | pm | `pnpm` |
| `{{INSTALL_CMD}}` | Install | `pnpm install` |
| `{{LINT_CMD}}` | Lint/format | `pnpm biome check --write .` |
| `{{TYPECHECK_CMD}}` | Types | `pnpm exec tsc --noEmit` |
| `{{UNIT_TEST_SINGLE_CMD}}` | One file test | `pnpm vitest run path/to/file.test.tsx` |
| `{{FORBIDDEN_PATHS}}` | No-edit list | `` `.next`, `dist`, `node_modules` `` |
| `{{PATH_ALIAS}}` | Import alias | `@/` |
| `{{COMPONENT_NAMING}}` | Convention | `PascalCase files` |
| `{{UI_RULE_GLOBS}}` | Rule scope | `**/components/**`, `**/app/**` |
| `{{UI_LIBRARY_SPECIFIC_RULES}}` | Extra bullets | shadcn/Radix notes |
| `{{TOKENS_PATH}}` | Theme | `src/app/globals.css` |
| `{{COMPONENTS_JSON_PATH}}` | shadcn config | `components.json` |
| `{{SHADCN_ADD_CMD}}` | Add component | `pnpm dlx shadcn@latest add` |
| `{{SCOPE_GLOBS}}` | Sub-agent scope | `src/**` |
| `{{MCP_POLICY}}` | MCP usage | `Figma MCP only for design tasks` |
| `{{APP_PACKAGE_NAME}}` | Turbo filter | `web` |
| `{{APP_PACKAGE_PATH}}` | Monorepo cwd | `apps/web` |
| `{{DATA_FETCHING_PATTERN}}` | Data layer | `TanStack Query v5` |
| `{{TYPES_PATH}}` | Shared types | `src/types/api.ts` |
| `{{VALIDATION_LIB}}` | Zod etc. | `Zod` |
| `{{FORM_LIB}}` | RHF etc. | `React Hook Form` |
| `{{FORMS_REFERENCE_PATH}}` | Example form | `src/features/auth/LoginForm.tsx` |
| `{{PLAYWRIGHT_CONFIG_PATH}}` | Config | `playwright.config.ts` |
| `{{PLAYWRIGHT_TEST_DIR}}` | Tests | `e2e` |
| `{{PLAYWRIGHT_SUBSET_CMD}}` | Subset | `pnpm exec playwright test e2e/checkout` |
| `{{PLAYWRIGHT_RUN_CMD}}` | Full local | `pnpm exec playwright test` |
| `{{TESTID_CONVENTION}}` | test ids | `data-testid="page-action"` |
| `{{VITE_ENTRY}}` | Vite entry | `src/main.tsx` |
| `{{BUILD_CMD}}` | Build | `pnpm run build` |
| `{{SERVER_ACTIONS_PATTERN}}` | Next actions | `src/app/actions/*.ts` |
| `{{A11Y_PROJECT_PATTERNS}}` | Team a11y notes | free text |
| `{{A11Y_CMD_OPTIONAL}}` | axe etc. | optional |
| `{{SKILL_*_WHEN}}` | Orchestration table | short when-clauses |
| `{{BOOTSTRAP_DATE}}` | Changelog | ISO date |
| `{{TOOLKIT_SHA}}` | Toolkit git rev at bootstrap | `abc1234` |
| `{{MONOREPO_CD_BLOCK_START}}` | Marker in verify hooks | Remove block when not monorepo |
| `{{MONOREPO_CD_BLOCK_END}}` | Marker in verify hooks | Pair with START |
| `{{HARNESS_PATHS}}` | Per-tool harness bullets | Per-strategy fragments under `templates/fragments/HARNESS_PATHS.*.example.md` |
| `{{CURSOR_HARNESS_LINE}}` | Cursor stop-hook note in `AGENTS.md` | Empty when `portable-only` or Cursor not selected |
| `{{MONOREPO_SKILL_NOTE}}` | `frontend-verify` cwd hint | Empty or ` (or \`apps/web\` in monorepos)` |
| `{{CANONICAL_SKILLS_DIR}}` | Source of truth for skills | `.agents/skills/` (`full` / `portable-only`); `.cursor/skills/` (`cursor-only`) |
| `{{EMIT_STRATEGY}}` | Bootstrap emit mode | `full` / `portable-only` / `cursor-only` |
| `{{PLATFORM_PRIMARY}}` | Primary dev OS for hooks | `unix` / `windows` |
| `{{HARNESS_OWNER}}` | Harness maintainer | `@handle` or `solo` |
| `{{CODEX_HOOKS_BLOCK}}` | Codex `[hooks]` TOML block | Set by emitter when `features.codex_hooks` |
| `{{SKILLS_DIR}}` | Path in always-on rules | Same as `{{CANONICAL_SKILLS_DIR}}` unless `primary_tool` is Cursor-only with `cursor-only` |

Skill-specific placeholders in `_SKILL_TEMPLATE.md` use the same naming style.
