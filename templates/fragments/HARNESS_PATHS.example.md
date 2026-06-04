# HARNESS_PATHS fragments (for AGENTS.md Harness section)

Replace `{{HARNESS_PATHS}}` in `AGENTS.md.template` with bullets from the file that matches **emit_strategy**. Do not commit pseudo-templating (`{{#if}}`) in target repos.

| Emit strategy | Fragment file |
|---------------|---------------|
| `full` | [HARNESS_PATHS.full.example.md](HARNESS_PATHS.full.example.md) |
| `portable-only` | [HARNESS_PATHS.portable-only.example.md](HARNESS_PATHS.portable-only.example.md) |
| `cursor-only` | [HARNESS_PATHS.cursor-only.example.md](HARNESS_PATHS.cursor-only.example.md) |

Deterministic emit builds the Harness block via `scripts/lib/build-answers-map.sh` (`build_harness_paths_block`). Agent-driven bootstrap should follow the same shape as the matching fragment.
