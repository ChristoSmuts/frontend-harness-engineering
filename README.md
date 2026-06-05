# Frontend Harness Engineering

A **bootstrap toolkit** for coding-agent harness and orchestration on frontend projects. Use it when starting a **new** repo or upgrading an **existing** one.

Works with **Cursor**, **Claude Code**, **Codex CLI**, **Gemini CLI**, and other agents that support `AGENTS.md` and portable `SKILL.md` skills.

## What this toolkit does

A **harness** is the agent-facing layer around your app: `AGENTS.md`, skills, rules, hooks, and orchestration notes. It is not your React/Next/Vite code — it is how coding agents learn your stack, verify their work, and stay aligned with your team.

This repo is the **source kit** for that layer. You (or your agent) run a structured bootstrap in a **target frontend repo** and end up with a repeatable layout: thin always-on context, task-shaped skills, optional Cursor hooks for lint/typecheck, and scripts to validate and sync paths across tools.

Typical flow:

1. **Intake** — Stack, tools, emit strategy, platform, **`target_path`** (where the app repo lives), and **`toolkit_path`**. When this toolkit repo is open, the agent asks for an absolute **`target_path`** to each app. See [intake/QUESTIONNAIRE.md](intake/QUESTIONNAIRE.md).
2. **Plan** — Agent proposes which artifacts to create (rules, skills, hooks, CI) from [manifest/ARTIFACT_MANIFEST.md](manifest/ARTIFACT_MANIFEST.md).
3. **Emit** — Files land at **`target_path`** from [templates/](templates/) (or via [scripts/emit-from-intake.sh](scripts/emit-from-intake.sh) with `--target` / JSON `target_path`).
4. **Verify** — `validate-target-harness` checks placeholders, emit strategy consistency, skill mirrors, and hook references; target repos can add [harness CI](docs/HARNESS_CI.md).
5. **Maintain** — Edit canonical skills, run `sync-skills`, grow the harness when agents fail the same way twice. With self-improvement enabled (default), repeat failures are logged to a failure ledger and the agent can auto-apply minimal canonical fixes — review harness diffs in git. See [docs/HARNESS_GROWTH.md](docs/HARNESS_GROWTH.md).

Emit modes (`full`, `portable-only`, `cursor-only`) control how much is generated — from Cursor-only rules and hooks to multi-tool parity with `.agents/skills/` as the canonical hub. Details: [docs/EMIT_STRATEGIES.md](docs/EMIT_STRATEGIES.md).

## Why use it

| Benefit | What you get |
|--------|----------------|
| **Faster, consistent setup** | One questionnaire and manifest instead of ad-hoc `AGENTS.md` per repo; bootstrap many apps from one toolkit checkout via **`target_path`**. |
| **Less context noise** | Thin `AGENTS.md` (~60 lines); depth lives in skills loaded only when relevant — agents stay focused on your code. |
| **Multi-tool without drift** | On `full` emit, write skills once under `.agents/skills/`, mirror to Cursor/Claude with `sync-skills`, and validate parity in CI. |
| **Automatic quality gates** | Optional Cursor stop hooks run lint/typecheck; validate scripts catch unreplaced `{{placeholders}}` and broken hook paths before merge. |
| **Cross-platform maintenance** | Bash and PowerShell scripts for validate/sync on Linux, macOS, and Windows — same harness on every OS your team uses. |
| **Failure-driven growth** | Start minimal; optionally auto-grow via failure ledger + `harness-self-improve` skill when the same mistake repeats (twice rule). Always review harness diffs in git — avoids bloated MCP and rule dumps up front. |
| **Team-ready defaults** | Orchestration handoffs, security skill pairing, governance docs, and golden fixtures so upgrades and reviews stay predictable. |

You keep owning the target repo; this toolkit only supplies templates, prompts, and maintenance scripts. Deeper walkthrough: [docs/START_HERE.md](docs/START_HERE.md).

## What this repo provides

| Path | Purpose |
|------|---------|
| [prompts/MASTER_BOOTSTRAP.md](prompts/MASTER_BOOTSTRAP.md) | Paste into any coding agent to run the full workflow |
| [intake/QUESTIONNAIRE.md](intake/QUESTIONNAIRE.md) | Intake fields (`target_path`, `toolkit_path`, stack, tools) |
| [manifest/ARTIFACT_MANIFEST.md](manifest/ARTIFACT_MANIFEST.md) | What to generate and in what order |
| [manifest/TOOL_LAYOUT.md](manifest/TOOL_LAYOUT.md) | Per-tool paths (Cursor, Claude, Codex, Gemini) |
| [docs/MULTI_TOOL.md](docs/MULTI_TOOL.md) | How to use the harness with each product |
| [docs/EMIT_STRATEGIES.md](docs/EMIT_STRATEGIES.md) | `full` / `portable-only` / `cursor-only` emit modes |
| [docs/HARNESS_GROWTH.md](docs/HARNESS_GROWTH.md) | After bootstrap — scaling multi-tool, team, agents |
| [scripts/](scripts/) | `sync-skills`, `validate-target-harness`, `emit-from-intake`, `register-harness-growth` |
| [docs/EMIT_FROM_INTAKE.md](docs/EMIT_FROM_INTAKE.md) | Deterministic emit from `answers.json` |
| [docs/HARNESS_CI.md](docs/HARNESS_CI.md) | Target-repo harness CI workflow |
| [fixtures/golden-full-emit/](fixtures/golden-full-emit/) | Reference `full` emit output for CI |
| [fixtures/golden-portable-only-emit/](fixtures/golden-portable-only-emit/) | Reference `portable-only` emit for CI |
| [fixtures/golden-cursor-only-emit/](fixtures/golden-cursor-only-emit/) | Reference `cursor-only` emit for CI |
| [templates/](templates/) | Copy/adapt into target projects |
| [.cursor/skills/frontend-harness-bootstrap/](.cursor/skills/frontend-harness-bootstrap/) | Cursor skill |
| [agents/skills/frontend-harness-bootstrap/](agents/skills/frontend-harness-bootstrap/) | Portable skill (Codex, Gemini, others) |

## Quick start

### A — Target frontend repo open

1. Scaffold your app (Next, Vite, etc.) and open it in your agent.
2. Run `frontend-harness-bootstrap` or paste [prompts/MASTER_BOOTSTRAP.md](prompts/MASTER_BOOTSTRAP.md). **`target_path`** is `.` (this repo).
3. Approve the plan; harness files are written here.

### B — Toolkit repo open (multiple projects)

1. Open **Frontend Harness Engineering** in Cursor (or your agent).
2. Run the bootstrap skill or MASTER_BOOTSTRAP. At intake, set **`target_path`** to the app repo, for example:

   - macOS: `/Users/you/dev/acme-web`
   - Linux: `/home/you/projects/acme-web`
   - Windows: `C:\dev\acme-web` or `C:/dev/acme-web`

3. **`toolkit_path`** is usually `.` here. Emit: `bash scripts/emit-from-intake.sh --answers answers.json --target "<path>" --toolkit .`
4. Open **`target_path`** for daily agent work; repeat with a new path for the next app.

Details: [docs/START_HERE.md](docs/START_HERE.md), [docs/CROSS_PLATFORM.md](docs/CROSS_PLATFORM.md).

### Existing project

Same as A or B. The agent **inspects** `package.json`, layout, and harness dirs under **`target_path`** before generating.

### Using templates manually

Copy from [templates/](templates/) into your target repo and replace `{{PLACEHOLDER}}` values. See [docs/USAGE.md](docs/USAGE.md) and [docs/MULTI_TOOL.md](docs/MULTI_TOOL.md).

### After bootstrap

- **Canonical skills:** `.agents/skills/` for multi-tool `full` emit; run `scripts/sync-skills.sh` after skill edits.
- **Validate:** `bash scripts/validate-target-harness.sh` (add `--strict` in CI).
- **Re-emit:** `bash scripts/emit-from-intake.sh` with intake JSON — see [docs/EMIT_FROM_INTAKE.md](docs/EMIT_FROM_INTAKE.md).
- **Another app from toolkit:** same bootstrap flow, new **`target_path`** — [docs/TOOLKIT_CONSUMPTION.md](docs/TOOLKIT_CONSUMPTION.md).
- **Grow the harness:** [docs/HARNESS_GROWTH.md](docs/HARNESS_GROWTH.md).
- **Self-improvement (default on):** failure ledger under `.agents/harness/` (or `.cursor/harness/` for cursor-only); Cursor stop hook may re-engage the agent when open ledger entries need a harness fix. Opt out at intake with `features.harness_self_improve: false`.

## Principles

Aligned with [HumanLayer — Skill Issue: Harness Engineering](https://www.humanlayer.dev/blog/skill-issue-harness-engineering-for-coding-agents):

- Thin always-on context (`AGENTS.md`, core rules)
- Skills for progressive disclosure (portable `SKILL.md`)
- Sub-agents for **context control** (locate/trace), not role personas
- Hooks for fast lint + typecheck on stop where supported (silent success)
- Failure-driven: add harness pieces when the agent actually fails; optional structured loop (ledger → twice rule → minimal fix → changelog)
- Canonical hub: `.agents/skills/` with mirrors for Cursor/Claude on `full` emit

## License

Use freely within your team and projects.
