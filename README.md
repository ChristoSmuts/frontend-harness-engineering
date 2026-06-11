# Frontend Harness Engineering

A **bootstrap toolkit** for coding-agent harness and orchestration on frontend projects. Use it when starting a **new** repo or upgrading an **existing** one.

Works with **Cursor**, **Claude Code**, **Codex CLI**, **Gemini CLI**, and other agents that support `AGENTS.md` and portable `SKILL.md` skills.

## What this toolkit does

A **harness** is the agent-facing layer around your app: `AGENTS.md`, skills, rules, and orchestration notes. It is not your React/Next/Vite code — it is how coding agents learn your stack and stay aligned with your team.

With **`standard`** delivery (default for emit/bootstrap), the harness can also include Cursor hooks, `.agent-scripts/` validate/sync tooling, and optional GitHub CI workflows. With **`agent-only`** delivery, you get agent-readable files only — no shell scripts, hooks, or workflows from this toolkit.

**Two ways to get a harness:**

| | **Web generator** ([`web/`](web/)) | **Emit / bootstrap** (this repo + your app) |
|---|-----------------------------------|---------------------------------------------|
| **Best for** | Quick zip; no agent session; teams wary of third-party shell scripts | In-repo setup; brownfield merge; hooks, CI, validate/sync |
| **Repo access** | Form only; optional `package.json` upload to pre-fill | Agent inspects the repo, or you write `answers.json` |
| **Output** | Zip — extract into your project | Files written to `target_path` |
| **Delivery** | Always `agent-only` | `standard` (default) or `agent-only` |

Local web dev: [web/README.md](web/README.md) (`bun install`, `bun run dev`). Deploy the `web/` directory on Vercel.

### Emit / bootstrap flow

1. **Intake** — preferences, stack, tools, `emit_strategy`, `delivery_mode`. See [intake/INTAKE_OVERVIEW.md](intake/INTAKE_OVERVIEW.md).
2. **Plan** — artifacts from [manifest/ARTIFACT_MANIFEST.md](manifest/ARTIFACT_MANIFEST.md).
3. **Emit** — [scripts/emit-from-intake.sh](scripts/emit-from-intake.sh) or agent writes templates.
4. **Verify** — `validate-target-harness` when `delivery_mode: standard`.
5. **Maintain** — edit skills, sync mirrors, grow harness — [docs/HARNESS_GROWTH.md](docs/HARNESS_GROWTH.md).

### Web flow

1. Open the generator → optional `package.json` upload.
2. Complete the questionnaire → review file list.
3. Download zip → extract at project root → read `HARNESS_NEXT_STEPS.md` in the archive.

`emit_strategy` (`full` / `portable-only` / `cursor-only`) is separate from `delivery_mode` — see [docs/EMIT_STRATEGIES.md](docs/EMIT_STRATEGIES.md).

## Agent-only without the web UI

Add `"delivery_mode": "agent-only"` to your intake JSON (start from [intake/answers.example.json](intake/answers.example.json)):

```bash
bash scripts/emit-from-intake.sh --answers /path/to/answers.json --target /path/to/your-app
```

Zip without the web app:

```bash
bash scripts/emit-harness-zip.sh --answers /path/to/answers.json --output my-app-harness.zip
```

Or run the bootstrap skill / [prompts/MASTER_BOOTSTRAP.md](prompts/MASTER_BOOTSTRAP.md) and choose **delivery mode → agent-only** at intake.

| Omitted (`agent-only`) | Included |
|------------------------|----------|
| `.agent-scripts/`, `.cursor/hooks/`, `.github/workflows/` | `AGENTS.md`, rules, skills, orchestration |
| `.codex/config.toml` hook wiring | Failure ledger + security allowlists (when features on) |
| | Skill mirrors inlined for `full` emit |

Use **`standard`** when you want Cursor stop hooks, harness CI, or `sync-skills` maintenance scripts.

## Why use it

| Benefit | What you get |
|--------|----------------|
| **Web zip (agent-only)** | Questionnaire → download → paste into repo; no shell scripts in the bundle |
| **Faster, consistent setup** | One intake + manifest instead of ad-hoc `AGENTS.md` per repo |
| **Less context noise** | Thin `AGENTS.md` (~60 lines); depth in skills on demand |
| **Multi-tool without drift** | `full` + `standard`: canonical `.agents/skills/` + `sync-skills` + CI |
| **Quality gates (`standard`)** | Cursor hooks, validate scripts, optional Gitleaks CI |
| **Failure-driven growth** | Optional failure ledger + `harness-self-improve` skill |

Deeper walkthrough: [docs/START_HERE.md](docs/START_HERE.md).

## What this repo provides

| Path | Purpose |
|------|---------|
| [web/](web/) | Next.js harness generator (agent-only zip) |
| [prompts/MASTER_BOOTSTRAP.md](prompts/MASTER_BOOTSTRAP.md) | Full agent bootstrap workflow |
| [intake/QUESTIONNAIRE.md](intake/QUESTIONNAIRE.md) | Intake fields incl. `delivery_mode` |
| [docs/EMIT_FROM_INTAKE.md](docs/EMIT_FROM_INTAKE.md) | Deterministic emit from JSON |
| [docs/EMIT_STRATEGIES.md](docs/EMIT_STRATEGIES.md) | `emit_strategy` + `delivery_mode` |
| [scripts/emit-from-intake.sh](scripts/emit-from-intake.sh) | Emit harness to `target_path` |
| [scripts/emit-harness-zip.sh](scripts/emit-harness-zip.sh) | Emit to zip (CLI) |
| [fixtures/golden-agent-only-full-emit/](fixtures/golden-agent-only-full-emit/) | Reference agent-only `full` emit |
| [fixtures/golden-full-emit/](fixtures/golden-full-emit/) | Reference `standard` `full` emit |

## Getting Started

### Option A — Web generator

1. Run locally (`cd web && bun run dev`) or use your deployed Vercel URL.
2. Answer the questionnaire (upload `package.json` optionally).
3. Download the zip and extract into your frontend repo root.

### Option B — App repo open (bootstrap)

1. Open your frontend project in your coding agent.
2. Make this toolkit reachable — [docs/TOOLKIT_CONSUMPTION.md](docs/TOOLKIT_CONSUMPTION.md).
3. Run `frontend-harness-bootstrap` or paste [prompts/MASTER_BOOTSTRAP.md](prompts/MASTER_BOOTSTRAP.md).
4. Choose `delivery_mode` (`standard` or `agent-only`) and other intake answers.
5. Approve the plan — harness files are written here.

### Option C — Toolkit repo open (bootstrap many apps)

1. Open this toolkit in your agent.
2. Provide absolute **`target_path`** to each app at intake.
3. Repeat for additional apps.

Brownfield: same as B or C — the agent inspects the repo before generating.

### After bootstrap

**`agent-only`:** edit canonical skills (and mirrors if `full`); no `sync-skills` script — mirrors were copied at emit. See `HARNESS_NEXT_STEPS.md` (web zip) or [docs/HARNESS_GROWTH.md](docs/HARNESS_GROWTH.md).

**`standard`:** run `.agent-scripts/sync-skills.sh` after skill edits; `validate-target-harness.sh --strict` in CI; optional hooks per intake features.

Re-emit: [docs/EMIT_FROM_INTAKE.md](docs/EMIT_FROM_INTAKE.md).

## Principles

Aligned with [HumanLayer — Harness Engineering](https://www.humanlayer.dev/blog/skill-issue-harness-engineering-for-coding-agents): thin always-on context, skills for depth, sub-agents for context control, failure-driven growth, canonical `.agents/skills/` hub on `full` emit.

## License

Use freely within your team and projects.
