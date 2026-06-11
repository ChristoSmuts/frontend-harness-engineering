# Start here

Entry point for **Frontend Harness Engineering** — bootstrap and maintain coding-agent harness on frontend repos.

**Choose your path:** see the comparison table in [README.md](../README.md#getting-started) — **web zip** ([`web/`](../web/)) vs **emit/bootstrap** (this doc). `delivery_mode` (`standard` vs `agent-only`) is independent of `emit_strategy`.

## Bootstrap a target project

### A — Target frontend repo open

1. Make the toolkit reachable: [TOOLKIT_CONSUMPTION.md](TOOLKIT_CONSUMPTION.md) (submodule, copy into `tools/frontend-harness/`, or multi-root).
2. Open the **target frontend repo** in your agent.
3. Run `frontend-harness-bootstrap` or paste [prompts/MASTER_BOOTSTRAP.md](../prompts/MASTER_BOOTSTRAP.md). Intake **`target_path`** defaults to `.` (this repo).
4. Approve Phase B, generate at **`target_path`**, verify per [CROSS_PLATFORM.md](CROSS_PLATFORM.md).

### B — Toolkit repo open (bootstrap many apps from one checkout)

1. Open **Frontend Harness Engineering** (this repo) in your agent.
2. Run the bootstrap skill or MASTER_BOOTSTRAP. At intake, provide **`target_path`** — absolute path to the app repo (macOS `/Users/.../app`, Linux `/home/.../app`, Windows `C:\...\app` or `C:/.../app`). **`toolkit_path`** is usually `.`.
3. Approve Phase B; emit into **`target_path`** via agent writes or `scripts/emit-from-intake.sh --target "<target_path>" --toolkit .`.
4. Validate from toolkit if needed: `bash scripts/validate-target-harness.sh --strict "<target_path>"`. Open **`target_path`** for day-to-day agent work.

See [intake/QUESTIONNAIRE.md](../intake/QUESTIONNAIRE.md) (`target_path`) and [CROSS_PLATFORM.md](CROSS_PLATFORM.md) (path normalization).

Optional deterministic emit: [EMIT_FROM_INTAKE.md](EMIT_FROM_INTAKE.md).

## Choose emit strategy

| Your tools | Strategy |
|------------|----------|
| Cursor only | `cursor-only` |
| Codex or Gemini CLI only | `portable-only` |
| Cursor + any CLI agent | `full` |

Details: [EMIT_STRATEGIES.md](EMIT_STRATEGIES.md). Paths: [manifest/TOOL_LAYOUT.md](../manifest/TOOL_LAYOUT.md).

**Guardrail:** Cursor + Codex/Gemini must **not** use `cursor-only` — use `full`.

## After bootstrap

| Need | Doc |
|------|-----|
| Day 0 checks | [HARNESS_GROWTH.md](HARNESS_GROWTH.md) |
| Security harness | [FRONTEND_SECURITY.md](FRONTEND_SECURITY.md) |
| Per-product usage | [MULTI_TOOL.md](MULTI_TOOL.md) |
| Linux / macOS / Windows commands | [CROSS_PLATFORM.md](CROSS_PLATFORM.md) |
| Team PR rules | [TEAM_GOVERNANCE.md](TEAM_GOVERNANCE.md) |
| Monorepo | [MONOREPO_HARNESS.md](MONOREPO_HARNESS.md) |
| Upgrade toolkit copy | [TOOLKIT_CONSUMPTION.md](TOOLKIT_CONSUMPTION.md) |
| Target-repo harness CI | [HARNESS_CI.md](HARNESS_CI.md) |
| Emit from intake JSON | [EMIT_FROM_INTAKE.md](EMIT_FROM_INTAKE.md) |

## Toolkit layout (this repo)

| Path | Purpose |
|------|---------|
| [prompts/MASTER_BOOTSTRAP.md](../prompts/MASTER_BOOTSTRAP.md) | Full agent workflow |
| [intake/QUESTIONNAIRE.md](../intake/QUESTIONNAIRE.md) | Intake fields (+ optional [answers.schema.json](../intake/answers.schema.json)) |
| [manifest/ARTIFACT_MANIFEST.md](../manifest/ARTIFACT_MANIFEST.md) | What to generate |
| [templates/](../templates/) | Files to emit into targets |
| [scripts/](../scripts/) | `validate`, `sync`, `emit-from-intake` |
| [fixtures/golden-full-emit/](../fixtures/golden-full-emit/) | Reference `full` emit tree for CI |

## Principles

- Thin `AGENTS.md` (~60 lines); skills for depth
- Task-shaped sub-agents (locate/trace), not role personas
- Hooks: silent success, errors only
- Grow harness when the agent fails — not preemptive MCP bloat

See [README.md](../README.md) for the HumanLayer-style rationale.
