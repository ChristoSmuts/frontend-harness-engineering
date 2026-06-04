# Emit harness from intake JSON

Reproducible bootstrap for P0+P1+P2 artifacts using [intake/answers.schema.json](../intake/answers.schema.json) and [manifest/emit-manifest.json](../manifest/emit-manifest.json).

## Prerequisites

- **bash** and **jq** (Linux/macOS/Git Bash; CI installs jq automatically)
- Toolkit root with `templates/` and `manifest/emit-manifest.json`

## Quick start

```bash
# From toolkit root (or pass --toolkit)
bash scripts/emit-from-intake.sh \
  --answers intake/answers.example.json \
  --target /path/to/frontend-repo \
  --toolkit .
```

```powershell
pwsh -File scripts/emit-from-intake.ps1 `
  -Answers intake/answers.example.json `
  -Target C:\path\to\frontend-repo `
  -Toolkit .
```

PowerShell wrapper delegates to bash when Git Bash is available.

## Flags

| Flag | Purpose |
|------|---------|
| `--merge` | Respect `merge_policy` in answers (skip paths marked `skip`) |
| `--no-strict` | Do not fail emit when validate warnings occur |

Default: runs `validate-target-harness.sh --strict` on the target after sync.

## Answers file

Copy [intake/answers.example.json](../intake/answers.example.json) or [fixtures/golden-full-emit/intake.answers.json](../fixtures/golden-full-emit/intake.answers.json). Required fields match the schema; `features` toggles P2 skills and optional artifacts.

| Feature | Effect |
|---------|--------|
| `shadcn` | `shadcn-components` skill |
| `codex_hooks` | `.codex/config.toml` with stop hook |
| `shell_guard` | `deny-dangerous` in hooks (unix: `.sh`, windows: `.ps1`); when `false`, emits verify-only `hooks.json` (no `beforeShellExecution`) |
| `harness_ci_workflow` | `.github/workflows/harness-validate.yml` |

Framework skills: one framework skill is chosen by matching `framework` (e.g. Next → `next-app-router`, Vue → `vue-vite`, `other` → `custom-framework`).

## Agent bootstrap integration

1. Run intake (Phase A) and export JSON.
2. Run `emit-from-intake` into the target repo.
3. Agent reviews diff, brownfield merges, and app-specific skill tweaks.
4. Phase D: re-run validate + lint/typecheck.

See [prompts/MASTER_BOOTSTRAP.md](../prompts/MASTER_BOOTSTRAP.md) Phase C.

## Golden reference fixture

[fixtures/golden-full-emit/](../fixtures/golden-full-emit/) is the committed reference tree for `full` emit. CI runs emitter round-trip and `diff`s against it.

## See also

- [HARNESS_CI.md](HARNESS_CI.md)
- [PLACEHOLDERS.md](PLACEHOLDERS.md)
- [FRAMEWORK_MAPPING.md](FRAMEWORK_MAPPING.md)
