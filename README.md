# Frontend Harness Engineering

A **bootstrap toolkit** for coding-agent harness and orchestration on frontend projects. Use it when starting a **new** repo or upgrading an **existing** one.

## What this repo provides

| Path | Purpose |
|------|---------|
| [prompts/MASTER_BOOTSTRAP.md](prompts/MASTER_BOOTSTRAP.md) | Paste into Cursor (or invoke the skill) to run the full workflow |
| [intake/QUESTIONNAIRE.md](intake/QUESTIONNAIRE.md) | Fields the agent collects from the user |
| [manifest/ARTIFACT_MANIFEST.md](manifest/ARTIFACT_MANIFEST.md) | What to generate and in what order |
| [templates/](templates/) | Copy/adapt into target projects (`.cursor/`, `AGENTS.md`) |
| [.cursor/skills/frontend-harness-bootstrap/](.cursor/skills/frontend-harness-bootstrap/) | Project skill: "bootstrap frontend harness" |

## Quick start

### New project

1. Scaffold your app (Next, Vite, etc.).
2. Open the app repo in Cursor.
3. Either:
   - **Skill:** Ask the agent to apply the skill `frontend-harness-bootstrap` and point it at this repo’s `prompts/MASTER_BOOTSTRAP.md`, or
   - **Paste:** Copy [prompts/MASTER_BOOTSTRAP.md](prompts/MASTER_BOOTSTRAP.md) into chat and say: *Bootstrap frontend harness for this project.*

The agent runs intake → plan → generates artifacts **in the target project** (not in this toolkit repo).

### Existing project

Same as above. The agent should **inspect** `package.json`, folder layout, and any existing `.cursor/` before asking intake questions.

### Using templates manually

Copy from [templates/](templates/) into your target repo and replace `{{PLACEHOLDER}}` values. See [docs/USAGE.md](docs/USAGE.md).

## Principles

Aligned with [HumanLayer — Skill Issue: Harness Engineering](https://www.humanlayer.dev/blog/skill-issue-harness-engineering-for-coding-agents):

- Thin always-on context (`AGENTS.md`, core rules)
- Skills for progressive disclosure
- Sub-agents for **context control** (locate/trace), not role personas
- Hooks for fast lint + typecheck on stop (silent success)
- Failure-driven: add harness pieces when the agent actually fails

## License

Use freely within your team and projects.