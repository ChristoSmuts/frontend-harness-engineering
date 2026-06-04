# Frontend Harness Engineering

A **bootstrap toolkit** for coding-agent harness and orchestration on frontend projects. Use it when starting a **new** repo or upgrading an **existing** one.

Works with **Cursor**, **Claude Code**, **Codex CLI**, **Gemini CLI**, and other agents that support `AGENTS.md` and portable `SKILL.md` skills.

## What this repo provides

| Path | Purpose |
|------|---------|
| [prompts/MASTER_BOOTSTRAP.md](prompts/MASTER_BOOTSTRAP.md) | Paste into any coding agent to run the full workflow |
| [intake/QUESTIONNAIRE.md](intake/QUESTIONNAIRE.md) | Fields the agent collects from the user |
| [manifest/ARTIFACT_MANIFEST.md](manifest/ARTIFACT_MANIFEST.md) | What to generate and in what order |
| [manifest/TOOL_LAYOUT.md](manifest/TOOL_LAYOUT.md) | Per-tool paths (Cursor, Claude, Codex, Gemini) |
| [docs/MULTI_TOOL.md](docs/MULTI_TOOL.md) | How to use the harness with each product |
| [docs/EMIT_STRATEGIES.md](docs/EMIT_STRATEGIES.md) | `full` / `portable-only` / `cursor-only` emit modes |
| [docs/HARNESS_GROWTH.md](docs/HARNESS_GROWTH.md) | After bootstrap — scaling multi-tool, team, agents |
| [scripts/](scripts/) | `sync-skills`, `validate-target-harness`, `emit-from-intake` |
| [docs/EMIT_FROM_INTAKE.md](docs/EMIT_FROM_INTAKE.md) | Deterministic emit from `answers.json` |
| [docs/HARNESS_CI.md](docs/HARNESS_CI.md) | Target-repo harness CI workflow |
| [fixtures/golden-full-emit/](fixtures/golden-full-emit/) | Reference `full` emit output for CI |
| [fixtures/golden-portable-only-emit/](fixtures/golden-portable-only-emit/) | Reference `portable-only` emit for CI |
| [fixtures/golden-cursor-only-emit/](fixtures/golden-cursor-only-emit/) | Reference `cursor-only` emit for CI |
| [templates/](templates/) | Copy/adapt into target projects |
| [.cursor/skills/frontend-harness-bootstrap/](.cursor/skills/frontend-harness-bootstrap/) | Cursor skill |
| [agents/skills/frontend-harness-bootstrap/](agents/skills/frontend-harness-bootstrap/) | Portable skill (Codex, Gemini, others) |

## Quick start

### New project

1. Scaffold your app (Next, Vite, etc.).
2. Open the app repo in your coding agent (Cursor, Claude Code, Codex, Gemini CLI, etc.).
3. Either:
   - **Skill:** Copy `frontend-harness-bootstrap` from `.cursor/skills/` or `agents/skills/` in this toolkit, then ask to bootstrap, or
   - **Paste:** Copy [prompts/MASTER_BOOTSTRAP.md](prompts/MASTER_BOOTSTRAP.md) into chat and say which tools you use, e.g. *Bootstrap frontend harness for this project. Tools: Cursor + Codex CLI.*

The agent runs intake → plan → generates artifacts **in the target project** (not in this toolkit repo).

### Existing project

Same as above. The agent should **inspect** `package.json`, folder layout, and any existing harness dirs (`.cursor/`, `.claude/`, `.agents/`, `.gemini/`) before asking intake questions.

### Using templates manually

Copy from [templates/](templates/) into your target repo and replace `{{PLACEHOLDER}}` values. See [docs/USAGE.md](docs/USAGE.md) and [docs/MULTI_TOOL.md](docs/MULTI_TOOL.md).

### After bootstrap

- **Canonical skills:** `.agents/skills/` for multi-tool `full` emit; run `scripts/sync-skills.sh` after skill edits.
- **Validate:** `bash scripts/validate-target-harness.sh` (add `--strict` in CI).
- **Re-emit:** `bash scripts/emit-from-intake.sh` with intake JSON — see [docs/EMIT_FROM_INTAKE.md](docs/EMIT_FROM_INTAKE.md).
- **Grow the harness:** [docs/HARNESS_GROWTH.md](docs/HARNESS_GROWTH.md).

## Principles

Aligned with [HumanLayer — Skill Issue: Harness Engineering](https://www.humanlayer.dev/blog/skill-issue-harness-engineering-for-coding-agents):

- Thin always-on context (`AGENTS.md`, core rules)
- Skills for progressive disclosure (portable `SKILL.md`)
- Sub-agents for **context control** (locate/trace), not role personas
- Hooks for fast lint + typecheck on stop where supported (silent success)
- Failure-driven: add harness pieces when the agent actually fails
- Canonical hub: `.agents/skills/` with mirrors for Cursor/Claude on `full` emit

## License

Use freely within your team and projects.
