# Templates

Copy or generate these into a **target frontend project**. Replace every `{{TOKEN}}` before committing.

## Placeholder reference

See [../docs/PLACEHOLDERS.md](../docs/PLACEHOLDERS.md).

## Hooks on Windows

- Use `verify-frontend.ps1` in `hooks.json` if the team is Windows-only, or register both scripts.
- Ensure scripts are executable on Unix: `chmod +x .cursor/hooks/*.sh`
- For `hooks.json` on Windows-only, point `stop` at `.cursor/hooks/verify-frontend.ps1`

## Minimal set (P0 + P1)

1. `AGENTS.md.template` → `/AGENTS.md`
2. `ORCHESTRATION.md.template` → `.cursor/ORCHESTRATION.md`
3. `rules/*.mdc.template` → `.cursor/rules/*.mdc` (drop `.template`)
4. `hooks/*` → `.cursor/hooks/`
5. `hooks.json.template` → `.cursor/hooks.json`
6. `skills/frontend-verify/` → `.cursor/skills/frontend-verify/`

Add other skills per [../manifest/ARTIFACT_MANIFEST.md](../manifest/ARTIFACT_MANIFEST.md).
