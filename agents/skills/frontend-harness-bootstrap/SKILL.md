---

name: frontend-harness-bootstrap

description: Bootstraps coding-agent harness (AGENTS.md, skills, rules, hooks, orchestration) for frontend projects. Supports Cursor, Claude Code, Codex CLI, Gemini CLI, and other SKILL.md agents. Use when starting a new frontend repo, setting up agent harness, or when the user mentions Frontend Harness Engineering bootstrap.

disable-model-invocation: true

---



# Frontend harness bootstrap



Bootstrap **coding-agent harness + orchestration** for the current workspace (the target frontend project).



## Before you start



1. Read `prompts/MASTER_BOOTSTRAP.md` from the Frontend Harness Engineering toolkit if available in workspace or path the user provides.

2. Read `docs/EMIT_STRATEGIES.md`, `docs/TOOLKIT_CONSUMPTION.md`, `docs/CROSS_PLATFORM.md`, and `manifest/TOOL_LAYOUT.md`.

3. Do not start Phase C until `templates/` is reachable at the recorded **toolkit_path**.



## Phases



### A — Intake



- Use `intake/QUESTIONNAIRE.md` (AskQuestion when available); optional `intake/answers.schema.json`.

- Collect **Required before Phase C**: `emit_strategy`, `primary_tool`, `harness_owner`, `canonical_skills_dir`, `platform_primary` (`unix` | `windows`), `toolkit_path`.

- **Emit guardrails:** Cursor + Codex/Gemini → `full` (not `cursor-only`). Fix mismatches before Phase C.

- Collect section **I** (AI coding tools) and sections G/H as needed.

- Brownfield: read `package.json`, `components.json`, existing `.cursor/`, `.claude/`, `.agents/`, `.gemini/`, app tree first.

- Accept **defaults** shortcut from questionnaire if user provides it.



### B — Plan



- Build table from `manifest/ARTIFACT_MANIFEST.md` (P0/P1/P2 only what applies).

- Include **emit_strategy**, canonical skills path, **platform_primary**, **toolkit_path**, paths per `TOOL_LAYOUT.md`.

- Show create / merge / skip for existing harness files.

- Wait for approval unless user said generate without review.



### C — Generate



- Write into **current workspace root** (target project).

- Branch on **emit_strategy** per `docs/EMIT_STRATEGIES.md` and `MASTER_BOOTSTRAP` Phase C.

- **Always copy maintenance scripts** to target `scripts/`: validate, sync, and `lib/secret-patterns.sh` / `lib/secret-patterns.ps1`.

- **HARNESS_CHANGELOG.md** with `{{TOOLKIT_SHA}}` from toolkit git rev.

- **Canonical skills:** `.agents/skills/` for `full` / `portable-only`; `.cursor/skills/` for `cursor-only` only.

- **P1 security:** `frontend-security` rule + skill always (`docs/FRONTEND_SECURITY.md`).
- **Hooks:** select template from `platform_primary`, `features.shell_guard`, and `features.secret_scan_hook` (default true); copy `scan-secrets` when enabled.

- **Optional deterministic emit:** `bash scripts/emit-from-intake.sh --answers <json> --target . --toolkit <toolkit_path>` — see `docs/EMIT_FROM_INTAKE.md`.

- Templates: `AGENTS.md.template`, orchestration shared + cursor-hooks, `CLAUDE.md.template`, `GEMINI.md.template`, `fragments/HARNESS_PATHS.example.md`, `rules/*`, `skills/*`, `hooks/*`; optional `templates/codex/config.toml.template`; optional `templates/github/workflows/harness-validate.yml.template`.

- Claude rules: follow `docs/CLAUDE_RULES_FROM_MDC.md`.

- **AGENTS.md Harness:** include `emit_strategy`, `harness_owner`, and `platform_primary` (from intake); see `templates/fragments/HARNESS_PATHS.example.md`.

- Replace all `{{PLACEHOLDER}}` tokens.



### D — Verify



- Run validate per OS (`docs/CROSS_PLATFORM.md`): bash or `pwsh -File scripts/validate-target-harness.ps1`.

- Run lint + typecheck from `AGENTS.md` / verify hook; for `full`, run sync (bash or ps1) after mirrors.



### E — Handoff



- Summarize emit strategy, canonical path, platform_primary, artifacts per tool, validate/sync commands.

- Point to `docs/START_HERE.md`, `docs/HARNESS_GROWTH.md`, `docs/MULTI_TOOL.md`, `docs/CROSS_PLATFORM.md`.

- Remind: extend harness when agent fails, not preemptively with many MCP tools.



## Non-negotiable principles



- Thin `AGENTS.md` (~60 lines max in target)

- One concern per rule file (~50 lines)

- Sub-agents for locate/trace/research with `path:line` handoff — not "frontend engineer" personas

- Hooks: silent on success, errors only to agent

- Prefer CLI over large MCP tool lists when training data already covers the tool



## Placeholders reference



Common replacements: `{{PROJECT_NAME}}`, `{{FRAMEWORK}}`, `{{TOOLKIT_SHA}}`, `{{PLATFORM_PRIMARY}}`, `{{LINT_CMD}}`, `{{TYPECHECK_CMD}}`, `{{ROUTES_PATH}}`, `{{COMPONENTS_PATH}}`, `{{HARNESS_PATHS}}`, `{{SKILLS_DIR}}`, `{{APP_PACKAGE_PATH}}` (monorepo).



See `docs/PLACEHOLDERS.md` in the toolkit for the full list.


