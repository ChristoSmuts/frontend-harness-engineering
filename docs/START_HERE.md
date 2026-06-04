# Start here

Entry point for **Frontend Harness Engineering** — bootstrap and maintain coding-agent harness on frontend repos.

## Bootstrap a target project

1. Make the toolkit reachable: [TOOLKIT_CONSUMPTION.md](TOOLKIT_CONSUMPTION.md) (submodule, copy into `tools/frontend-harness/`, or multi-root).
2. Open the **target frontend repo** in your agent (Cursor, Claude Code, Codex, Gemini, etc.).
3. Run intake and generate:
   - **Skill:** `frontend-harness-bootstrap` from `.cursor/skills/` or `agents/skills/`
   - **Or paste:** [prompts/MASTER_BOOTSTRAP.md](../prompts/MASTER_BOOTSTRAP.md) with your AI tools listed
4. Approve the Phase B plan, then generate artifacts in the **target** repo (not this meta-repo).
5. Verify: [CROSS_PLATFORM.md](CROSS_PLATFORM.md) — run validate (`--strict` in CI) + lint/typecheck; on `full` emit, run sync.
6. Optional: deterministic emit via [EMIT_FROM_INTAKE.md](EMIT_FROM_INTAKE.md) and `scripts/emit-from-intake.sh`.

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
