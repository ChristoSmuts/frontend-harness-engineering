# Monorepo harness

Configure harness and verification when the frontend app lives in a workspace package (e.g. `apps/web`).

## Intake

Collect in questionnaire section A:

- Monorepo: yes
- App package path: `apps/web`
- Filter name for turbo: `web` → `{{APP_PACKAGE_NAME}}`

## Commands

Set placeholders for the **app package**, not repo root only:

```bash
# Example turbo
pnpm exec turbo run typecheck lint --filter=web
```

Wire into:

- `AGENTS.md` — `{{LINT_CMD}}`, `{{TYPECHECK_CMD}}`
- `.cursor/hooks/verify-frontend.sh` and `.ps1` — replace the `{{MONOREPO_CD_BLOCK_*}}` section with:
  - bash: `cd "{{APP_PACKAGE_PATH}}"` after project root `cd`
  - PowerShell: `Set-Location "{{APP_PACKAGE_PATH}}"`
- When **not** a monorepo, bootstrap removes the entire `MONOREPO_CD_BLOCK` (markers and comments) from both hook files
- skill `frontend-verify` — document `{{APP_PACKAGE_PATH}}` in Commands section

## Skills and scope

- `{{SCOPE_GLOBS}}` in orchestration: `apps/web/src/**` (not entire monorepo unless task requires)
- Sub-agents search package tree only unless tracing shared packages

## Canonical skills

Still repo-root `.agents/skills/` — one harness per repo; skills describe which package to edit.

## See also

- [FRAMEWORK_MAPPING.md](FRAMEWORK_MAPPING.md) — package manager table
- [PLACEHOLDERS.md](PLACEHOLDERS.md) — `{{APP_PACKAGE_PATH}}`, `{{APP_PACKAGE_NAME}}`
