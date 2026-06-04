# Templates

Copy or generate these into a **target frontend project**. Replace every `{{TOKEN}}` before committing.

## Placeholder reference

See [../docs/PLACEHOLDERS.md](../docs/PLACEHOLDERS.md).

## Hooks and platform

| `platform_primary` | `hooks.json` source | Stop verify |
|--------------------|---------------------|-------------|
| `unix` (default) | `hooks.json.template` | `verify-frontend.sh` |
| `windows` | `hooks.windows.json.template` | `verify-frontend.ps1` |

- Ensure Unix scripts are executable: `chmod +x .cursor/hooks/*.sh`
- `deny-dangerous.sh` (unix) / `deny-dangerous.ps1` (windows) block dangerous shell when `features.shell_guard` is true
- `scan-secrets.sh` / `scan-secrets.ps1` scan git-changed files when `features.secret_scan_hook` is true (default)
- Hook JSON variants: `hooks.json.template` (shell + scan), `hooks.no-secret-scan.json.template`, `hooks.no-shell-guard.json.template`, `hooks.verify-only.json.template` (+ `hooks.windows.*`)
- P1 `rules/frontend-security.mdc.template` and `skills/frontend-security/` — see [../docs/FRONTEND_SECURITY.md](../docs/FRONTEND_SECURITY.md)
- Copy `scripts/lib/secret-patterns.*` to target with maintenance scripts
- See [../docs/CROSS_PLATFORM.md](../docs/CROSS_PLATFORM.md) for validate/sync on each OS

## Monorepo verify hooks

`verify-frontend.sh` / `.ps1` contain `{{MONOREPO_CD_BLOCK_START}}` … `{{MONOREPO_CD_BLOCK_END}}`. On bootstrap:

- **Monorepo no:** remove the entire block (including markers).
- **Monorepo yes:** replace with `cd "{{APP_PACKAGE_PATH}}"` (bash) or `Set-Location "{{APP_PACKAGE_PATH}}"` (PowerShell).

## Orchestration (preferred split)

1. `ORCHESTRATION.shared.md.template` → `agents/ORCHESTRATION.md` (and `.claude/ORCHESTRATION.md`)
2. `ORCHESTRATION.cursor-hooks.md.template` → `.cursor/ORCHESTRATION.cursor-hooks.md` + append to `.cursor/ORCHESTRATION.md`

Legacy monolithic: `ORCHESTRATION.md.template`.

## Harness paths fragment

`fragments/HARNESS_PATHS.example.md` — bullets for `{{HARNESS_PATHS}}` in `AGENTS.md`.

## Minimal set (P0 + P1)

1. `AGENTS.md.template` → `/AGENTS.md` (always)
2. Orchestration shared + cursor-hooks → per [../manifest/TOOL_LAYOUT.md](../manifest/TOOL_LAYOUT.md)
3. `rules/*.mdc.template` → `.cursor/rules/*.mdc` (Cursor only; drop `.template`)
4. `hooks/*` → `.cursor/hooks/` (Cursor only)
5. `hooks.json.template` or `hooks.windows.json.template` → `.cursor/hooks.json`
6. Copy four scripts to target `scripts/` (bash + PowerShell validate and sync)
8. `skills/*/` → **canonical** `.agents/skills/` first; mirror with sync scripts
9. Optional: `CLAUDE.md.template`, `GEMINI.md.template`, `HARNESS_CHANGELOG.md.template`, `codex/config.toml.template`, `github/workflows/harness-validate.yml.template`
10. Deterministic emit: [../docs/EMIT_FROM_INTAKE.md](../docs/EMIT_FROM_INTAKE.md) + `scripts/emit-from-intake.sh`

Add other skills per [../manifest/ARTIFACT_MANIFEST.md](../manifest/ARTIFACT_MANIFEST.md). Guides: [../docs/MULTI_TOOL.md](../docs/MULTI_TOOL.md), [../docs/EMIT_STRATEGIES.md](../docs/EMIT_STRATEGIES.md), [../docs/HARNESS_GROWTH.md](../docs/HARNESS_GROWTH.md).
