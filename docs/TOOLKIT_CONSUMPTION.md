# Consuming the toolkit without cloning into the app repo

Ways to run bootstrap when the harness toolkit and the frontend app are not the same folder.

## Options

| Method | Pros |
|--------|------|
| **Toolkit repo open** | Keep one Frontend Harness Engineering checkout; bootstrap many apps via intake **`target_path`** (see [CROSS_PLATFORM.md](CROSS_PLATFORM.md)) |
| **Submodule** | Pin version; `templates/` and `scripts/` always available in the app repo |
| **One-time copy** | Copy `templates/`, `scripts/`, and `prompts/MASTER_BOOTSTRAP.md` into target or internal repo |
| **Paste prompt** | Paste `MASTER_BOOTSTRAP.md` + path to templates on disk |
| **Cursor multi-root** | Open toolkit + target; agent reads both (`target_path` may still be explicit) |

Phase A must record **`toolkit_path`** (where `templates/` lives) and **`target_path`** (where harness files are written). Do not start Phase C without resolvable `templates/`. Do not set `target_path` to the toolkit meta-repo root.

## Recommended copy set (target `tools/frontend-harness/`)

```
tools/frontend-harness/
  templates/
  manifest/emit-manifest.json
  intake/answers.schema.json
  scripts/validate-target-harness.sh
  scripts/validate-target-harness.ps1
  scripts/sync-skills.sh
  scripts/sync-skills.ps1
  scripts/emit-from-intake.sh
  scripts/emit-from-intake.ps1
  scripts/lib/
  prompts/MASTER_BOOTSTRAP.md
  docs/HARNESS_GROWTH.md
  docs/CROSS_PLATFORM.md
  docs/EMIT_FROM_INTAKE.md
```

On bootstrap Phase C, copy maintenance scripts to the **target repo** `.agent-scripts/` on **every** emit strategy (`full`, `portable-only`, `cursor-only`). The toolkit keeps its own `scripts/` for emit and CI.

Record toolkit git SHA in target `HARNESS_CHANGELOG.md` when bootstrapping or upgrading (see [templates/HARNESS_CHANGELOG.md.template](../templates/HARNESS_CHANGELOG.md.template)).

## Upgrade path

1. Diff toolkit `templates/` vs your copy.
2. Merge intentional template changes into target harness files (do not blind overwrite customized skills).
3. Re-run validate and sync using [CROSS_PLATFORM.md](CROSS_PLATFORM.md):

   ```bash
   bash .agent-scripts/validate-target-harness.sh
   bash .agent-scripts/sync-skills.sh --all-mirrors
   ```

   ```powershell
   pwsh -File .agent-scripts/validate-target-harness.ps1
   pwsh -File .agent-scripts/sync-skills.ps1 -AllMirrors
   ```

## See also

- [START_HERE.md](START_HERE.md)
- [USAGE.md](USAGE.md)
- [HARNESS_GROWTH.md](HARNESS_GROWTH.md)
- [CROSS_PLATFORM.md](CROSS_PLATFORM.md)
