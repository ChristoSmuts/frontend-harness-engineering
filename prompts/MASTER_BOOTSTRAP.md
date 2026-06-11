# Frontend harness bootstrap



You are bootstrapping **coding-agent harness + orchestration** for a **target frontend project** at **`target_path`** on disk. The open workspace may be that app repo **or** this Frontend Harness Engineering toolkit—when the toolkit is open, intake **must** collect `target_path` (absolute path to the app). Never emit harness files into the toolkit meta-repo.



Follow this workflow exactly. Do not skip intake. Do not generate artifacts until intake is complete (or the user says **"use defaults"** for listed fields).



Reference toolkit paths (if this repo is available): `intake/INTAKE_OVERVIEW.md`, `intake/QUESTIONNAIRE.md`, `intake/answers.schema.json`, `manifest/ARTIFACT_MANIFEST.md`, `manifest/TOOL_LAYOUT.md`, `templates/`, `docs/MULTI_TOOL.md`, `docs/EMIT_STRATEGIES.md`, `docs/TOOLKIT_CONSUMPTION.md`, `docs/CROSS_PLATFORM.md`.



## Principles (non-negotiable)



1. **Harness = model + configuration** — optimize context, verification, and progressive disclosure.

2. **Thin always-on context** — target `AGENTS.md` and `alwaysApply` rules stay under ~60 lines each; one concern per rule file.

3. **Skills for depth** — framework, design system, E2E live in tool-specific skills dirs (see `manifest/TOOL_LAYOUT.md`; portable format is `SKILL.md` under `.cursor/skills/`, `.claude/skills/`, and/or `.agents/skills/`) with `disable-model-invocation: true` unless the user requests auto-invoke.

4. **Sub-agents for context control** — document task-shaped delegation (locate, trace, research)—not role-based "frontend engineer" personas.

5. **Back-pressure** — where the tool supports hooks (Cursor by default), run fast lint + typecheck on stop; success is silent; only errors return to the agent. Other tools use the `frontend-verify` skill or commands in `AGENTS.md`.

6. **Failure-driven** — only add MCP servers, skills, and hooks the project needs; prefer CLI over bloated MCP tool lists.

7. **Inspect before inventing** — on brownfield repos, read `package.json`, existing harness dirs (`.cursor/`, `.claude/`, `.agents/`, `.gemini/`), `components.json`, and folder layout under **`target_path`** before generating.

8. **Multi-tool** — intake must record which AI tools the team uses; apply **emit_strategy** (see `docs/EMIT_STRATEGIES.md`). `AGENTS.md` is always the shared entry; canonical skills live in `.agents/skills/` for `full` emit; mirrors sync via `.agent-scripts/sync-skills.sh` or `.agent-scripts/sync-skills.ps1` in the target repo.



## Phase A — Intake



Show the developer **[intake/INTAKE_OVERVIEW.md](intake/INTAKE_OVERVIEW.md)** outcome preview (what bootstrap produces) before collecting answers.

Collect every item in `intake/QUESTIONNAIRE.md`, including **Required before Phase C**: `target_path`, `toolkit_path`, `emit_strategy`, `primary_tool`, `harness_owner`, `canonical_skills_dir` (default `.agents/skills/`), `harness_scripts_dir` (default `.agent-scripts`), and `platform_primary` (`unix` | `windows`). Infer from the repo when possible; only ask for gaps.

### Step 1 — Workspace + path (before preference questions)

**Auto-detect workspace** when possible:

- **Toolkit open** — `manifest/ARTIFACT_MANIFEST.md` + `prompts/MASTER_BOOTSTRAP.md` at workspace root
- **Target open** — frontend app markers (`package.json`, app tree) and not the toolkit layout above
- **Ambiguous** — use AskQuestion with **workspace_context** only (see `intake/QUESTIONNAIRE.md`)

**Path-first rule:** Do **not** show the harness preference AskQuestion bundle until **`target_path`** is resolved:

- **Toolkit detected** → ask user to paste absolute **`target_path`** immediately (spaces OK). Default **`toolkit_path`** to `.`. Do not default `target_path` to `.`.
- **Target detected** → `target_path` = `.`; confirm **`toolkit_path`** if not obvious (submodule, `tools/frontend-harness/`, multi-root).
- **Ambiguous + `toolkit_open`** → same as toolkit: collect path before preferences.

### Step 2 — Harness preferences (AskQuestion)

Use AskQuestion when available (see **Phase A — AskQuestion bundle** in `intake/QUESTIONNAIRE.md`). Use **descriptive option labels** from the questionnaire (each option states what it produces). Order: `emit_strategy` → `primary_tool` → `tools_in_use` → `platform_primary` → `harness_owner` → `delivery_mode` → `hooks_prefs` (skip when `agent-only`) → `repo_type`.

Record **`delivery_mode`** in exported JSON: `standard` (default — scripts, optional hooks/CI) or `agent-only` (docs, rules, skills only; inline skill mirrors for `full`). See `docs/EMIT_STRATEGIES.md`.

### Step 3 — Intake summary

Before Phase B, post a short **intake summary** table: resolved paths, emit strategy, tools, platform, hooks, and brownfield fields inferred from **`target_path`**.

**`target_path` (cross-platform):** macOS `/Users/you/dev/acme-web`, Linux `/home/you/projects/acme-web`, Windows `C:\dev\acme-web`, `C:/dev/acme-web`, or Git Bash `/c/dev/acme-web`. Prefer absolute paths; emit normalizes via `scripts/lib/normalize-target-path.sh` (see `docs/CROSS_PLATFORM.md`). Quote paths in shell commands. Avoid storing raw `~/...` in answers JSON—expand to absolute. **Never** pass unquoted Windows paths with spaces to bash from PowerShell—use `emit-from-intake.ps1` or JSON-only `--answers` (no broken `--target` argv).

**Toolkit:** Do not start Phase C until `templates/` is reachable at `toolkit_path`. See `docs/TOOLKIT_CONSUMPTION.md`.

**Guardrails:** Reject if resolved `target_path` is the toolkit meta-repo. Brownfield inspection uses **`target_path`**, not the toolkit root when the toolkit is open.



**Emit guardrails (correct before Phase B/C):**



- **Cursor + Codex or Gemini CLI** → must use `full`, not `cursor-only`.

- If intake has CLI tools but `emit_strategy` is `cursor-only`, change to `full` (or `portable-only` if no Cursor).

- Solo Cursor, no CLI → `cursor-only` is OK.



**Defaults shortcut:** user may say *"defaults: Next 15 App Router + pnpm + shadcn + Tailwind + Biome + Vitest + Playwright CI-only"* — then infer the rest from the repo at **`target_path`**. If emit strategy omitted: solo Cursor → `cursor-only`; any CLI tool → `full` or `portable-only` per user preference.



Optional: export intake as JSON matching `intake/answers.schema.json` for reproducibility. Write answers **outside** this toolkit repo (target `.harness-intake/answers.json`, `%TEMP%`, or `~/frontend-harness-intake/`)—not under `intake/` except `answers.example.json`.

**Brownfield `AGENTS.md`:** if merging existing content (e.g. Next.js agent-rules blocks), preserve UTF-8 (no BOM). Prefer emit-then-append fragments over PowerShell `Set-Content` without `-Encoding utf8NoBOM`.



## Phase B — Plan (user-visible)



Emit a **Harness Plan** table:



| Artifact | Path | Purpose | When loaded |

|----------|------|---------|-------------|



List only what this project needs (see `manifest/ARTIFACT_MANIFEST.md`). Header: **target_path** (absolute). Include **emit_strategy**, **canonical_skills_dir**, **platform_primary**, **toolkit_path**, and **per-tool paths** from `manifest/TOOL_LAYOUT.md` (paths in the table are relative to **target_path**). Include **`.agent-scripts/`** — harness validate/sync (not app build scripts). Wait for user approval unless they said **"generate without review"**.



## Phase C — Generate (at `target_path`)



Apply **emit_strategy** from `docs/EMIT_STRATEGIES.md` (default paths in `manifest/TOOL_LAYOUT.md`). All files go under **`target_path`**. If the IDE blocks writes outside the open workspace, use terminal/`emit-from-intake` from the toolkit.



### Always (every emit strategy)



- Root `AGENTS.md` from `templates/AGENTS.md.template` — Harness section from `templates/fragments/HARNESS_PATHS.example.md` pattern; **must** include `emit_strategy`, `harness_owner`, and `platform_primary` (unix | windows); state canonical skills dir and sync/validate scripts

- Copy maintenance scripts to target **`.agent-scripts/`** (default `harness_scripts_dir`; separate from app `scripts/`):

  - `validate-target-harness.sh`, `validate-target-harness.ps1`

  - `sync-skills.sh`, `sync-skills.ps1`

  - `register-harness-growth.sh`, `register-harness-growth.ps1` (when self-improve enabled)

  - `lib/secret-patterns.sh`, `lib/secret-patterns.ps1`, `lib/normalize-target-path.sh`, `lib/normalize-target-path.ps1`, `lib/shell-guard.*`, `lib/harness-integrity.*`

- `HARNESS_CHANGELOG.md` from `templates/HARNESS_CHANGELOG.md.template` — include **Toolkit SHA** (git rev of toolkit at bootstrap) in the initial row or a `Toolkit SHA:` line under the table



### `full` (multi-tool parity)



- **Canonical:** write all skills to `.agents/skills/*/SKILL.md` first; `agents/ORCHESTRATION.md` from `templates/ORCHESTRATION.shared.md.template`

- **Cursor (if selected):** `.cursor/rules/*.mdc`, mirror skills to `.cursor/skills/`, hooks, `.cursor/ORCHESTRATION.md` = shared + `templates/ORCHESTRATION.cursor-hooks.md.template`

- **Claude (if selected):** optional `CLAUDE.md`, `.claude/rules/*.md` per `docs/CLAUDE_RULES_FROM_MDC.md`, mirror skills, `.claude/ORCHESTRATION.md` = shared only

- **Codex/Gemini (if selected):** `.agents/skills/` (canonical), optional `GEMINI.md`; optional `.codex/config.toml` from `templates/codex/config.toml.template` when user opts in

- Run sync once after mirrors (bash or pwsh per `docs/CROSS_PLATFORM.md`)



### `portable-only`



- `AGENTS.md`, `agents/ORCHESTRATION.md` (shared template), `.agents/skills/*`

- Optional `GEMINI.md` if Gemini selected

- Skip Cursor rules/hooks and `.cursor/skills/` unless Cursor is the only tool (then prefer `cursor-only`)



### `cursor-only`



- `AGENTS.md`, `.cursor/rules/`, `.cursor/skills/` (canonical for this strategy), hooks, `.cursor/ORCHESTRATION.md` (shared + cursor-hooks composed into `.cursor/` only)

- Do **not** leave `agents/ORCHESTRATION.md` in the target repo (orchestration is only under `.cursor/`). `emit-from-intake.sh` does this automatically.

- Skip `.agents/skills/` unless Codex/Gemini also selected (then use `full`)



**Skills:** P1 always includes `frontend-verify` and **`frontend-security`**; enable only relevant P2 skills. **Hooks:** Cursor only when Cursor paths emitted.



- **P1 security:** `templates/rules/frontend-security.mdc.template`, `templates/skills/frontend-security/SKILL.md` (see `docs/FRONTEND_SECURITY.md`)

- **Hooks template** (pick by `platform_primary`, `features.shell_guard`, `features.secret_scan_hook` default true): `hooks.json.template` / `hooks.no-secret-scan.json.template` / `hooks.no-shell-guard.json.template` / `hooks.verify-only.json.template` (and `hooks.windows.*` counterparts)

- Copy `scan-secrets.sh` / `.ps1` when `secret_scan_hook` is enabled

- When `features.agent_security_hardening`: emit `.agents/harness/allowed-domains.txt` and `mcp-allowlist.json` (from intake `mcp_allowlist` if set), copy `deny-unapproved-mcp.*`, patch `hooks.json` with `beforeMCPExecution`

- When `features.gitleaks_ci`: emit `.github/workflows/secret-scan.yml`



Replace all `{{PLACEHOLDER}}` values. Remove unused skill folders.

**Deterministic emit (recommended when jq + bash available):** after intake, write `answers.json` and run:

```bash
bash scripts/emit-from-intake.sh --answers path/to/answers.json --target "<target_path>" --toolkit path/to/frontend-harness-engineering
```

(`--target` may be omitted when `target_path` is set in the answers JSON.)

See `docs/EMIT_FROM_INTAKE.md`. Agent still reviews brownfield merges and app-specific skill content.

**Target CI (teams):** copy `templates/github/workflows/harness-validate.yml.template` unless user opts out (`features.harness_ci_workflow: false`).

Do not copy the entire toolkit into the target—only selected artifacts plus maintenance scripts under `.agent-scripts/` (emitter lives in toolkit `scripts/` only).



## Phase D — Verify



1. Run validate on **`target_path`** (`docs/CROSS_PLATFORM.md`):

   - From **target** (after scripts copied): `bash .agent-scripts/validate-target-harness.sh` or `pwsh -File .agent-scripts/validate-target-harness.ps1`

   - From **toolkit** (before or without local scripts): `bash "<toolkit_path>/scripts/validate-target-harness.sh" --strict "<target_path>"` (or pwsh `-TargetRoot`)

2. Run fast lint + typecheck from target `AGENTS.md` / verify hook (cwd = **target_path**). Fix script paths if they fail.

3. For `full` emit with mirrors: run sync from **target_path** (`.agent-scripts/sync-skills.sh` or `sync-skills.ps1 -AllMirrors`) and re-run validate.



Summarize what was created (one short paragraph).



## Phase E — Handoff



Tell the user:



- **target_path** (absolute)—open that folder for day-to-day agent work; re-bootstrap another app from the toolkit with a new `target_path`

- **emit_strategy**, canonical skills path, **platform_primary**, and paths created per tool

- How to invoke skills in **primary_tool**; edit canonical skills then sync for `full`

- Validate/sync commands for their OS (`docs/CROSS_PLATFORM.md`)

- Sub-agent handoff format in `ORCHESTRATION.md` (see `AGENTS.md`)

- `docs/HARNESS_GROWTH.md`, `docs/MULTI_TOOL.md`, `docs/START_HERE.md` for scaling

- Extend harness **when the agent fails**, not preemptively with dozens of MCP tools



Do not `git commit` unless the user asks.


