---

name: frontend-harness-bootstrap

description: Bootstraps coding-agent harness (AGENTS.md, skills, rules, hooks, orchestration) for frontend projects. Supports Cursor, Claude Code, Codex CLI, Gemini CLI, and other SKILL.md agents. Use when starting a new frontend repo, setting up agent harness, or when the user mentions Frontend Harness Engineering bootstrap.

disable-model-invocation: true

---



# Frontend harness bootstrap



Bootstrap **coding-agent harness + orchestration** at **`target_path`** (see `prompts/MASTER_BOOTSTRAP.md`). The open workspace may be the app repo or this toolkit; when the toolkit is open, collect an absolute **`target_path`** to the frontend app.



## Before you start



1. Read `prompts/MASTER_BOOTSTRAP.md` from the Frontend Harness Engineering toolkit if available in workspace or path the user provides.

2. Read `docs/EMIT_STRATEGIES.md`, `docs/TOOLKIT_CONSUMPTION.md`, `docs/CROSS_PLATFORM.md`, and `manifest/TOOL_LAYOUT.md`.

3. Do not start Phase C until `templates/` is reachable at the recorded **toolkit_path**.



## Phases



### A — Intake



- Use `intake/QUESTIONNAIRE.md` — **AskQuestion bundle** when available (`workspace_context` first, then tools/emit/platform/hooks, then `repo_type`); optional `intake/answers.schema.json`.

- Collect **Required before Phase C**: `target_path`, `toolkit_path`, `emit_strategy`, `primary_tool`, `harness_owner`, `canonical_skills_dir`, `platform_primary` (`unix` | `windows`).

- **target_path in same turn:** `target_repo_open` → `.`; `toolkit_open` → user pastes absolute path before Phase B (spaces OK).

- **Answers JSON:** write outside toolkit (`~/frontend-harness-intake/`, target `.harness-intake/`, or `%TEMP%`)—not `intake/*.answers.json` in the toolkit repo.

- **Workspace:** toolkit root has `manifest/ARTIFACT_MANIFEST.md` + `prompts/MASTER_BOOTSTRAP.md` → require **`target_path`**; default **`toolkit_path`** to `.`. App workspace → **`target_path`** `.`, user supplies **`toolkit_path`**.

- **`target_path` examples:** macOS `/Users/.../app`, Linux `/home/.../app`, Windows `C:\...\app`, `C:/.../app`, or `/c/.../app` — absolute preferred (`docs/CROSS_PLATFORM.md`). Prefer `emit-from-intake` with `target_path` in JSON on Windows (spaces).

- **Emit guardrails:** Cursor + Codex/Gemini → `full` (not `cursor-only`). Never emit into toolkit root.

- Collect section **I** (AI coding tools) and sections G/H as needed.

- Brownfield: read `package.json`, harness dirs, app tree under **`target_path`** first.

- Accept **defaults** shortcut from questionnaire if user provides it.



### B — Plan



- Build table from `manifest/ARTIFACT_MANIFEST.md` (P0/P1/P2 only what applies).

- Header **target_path** (absolute). Include **emit_strategy**, canonical skills path, **platform_primary**, **toolkit_path**, paths per `TOOL_LAYOUT.md` (relative to **target_path**).

- Show create / merge / skip for existing harness files.

- Wait for approval unless user said generate without review.



### C — Generate



- Write into **`target_path`** (not toolkit root). Use `emit-from-intake` or shell if IDE blocks out-of-workspace writes.

- Branch on **emit_strategy** per `docs/EMIT_STRATEGIES.md` and `MASTER_BOOTSTRAP` Phase C.

- **Always copy maintenance scripts** to target `scripts/`: validate, sync, `lib/secret-patterns.*`, `lib/shell-guard.*`, `lib/harness-integrity.*`, and `lib/normalize-target-path.*`.

- **HARNESS_CHANGELOG.md** with `{{TOOLKIT_SHA}}` from toolkit git rev.

- **Canonical skills:** `.agents/skills/` for `full` / `portable-only`; `.cursor/skills/` for `cursor-only` only.

- **P1 security:** `frontend-security` rule + skill always (`docs/FRONTEND_SECURITY.md`).
- **Shell conventions:** `shell-conventions` rule (platform-aware from `platform_primary`; see `docs/CROSS_PLATFORM.md`).
- **Hooks:** select template from `platform_primary`, `features.shell_guard`, and `features.secret_scan_hook` (default true); copy `scan-secrets` when enabled; when `features.agent_security_hardening`, emit allowlists and `deny-unapproved-mcp` (`beforeMCPExecution`).

- **Optional deterministic emit:** `bash scripts/emit-from-intake.sh --answers <json-outside-toolkit> --toolkit <toolkit_path>` — see `docs/EMIT_FROM_INTAKE.md` (`--target` optional if JSON has `target_path`; use `emit-from-intake.ps1` on Windows).

- Templates: `AGENTS.md.template`, orchestration shared + cursor-hooks, `CLAUDE.md.template`, `GEMINI.md.template`, `fragments/HARNESS_PATHS.example.md`, `rules/*`, `skills/*`, `hooks/*`; optional `templates/codex/config.toml.template`; optional `templates/github/workflows/harness-validate.yml.template` and `secret-scan.yml.template` (`features.gitleaks_ci`).

- Claude rules: follow `docs/CLAUDE_RULES_FROM_MDC.md`.

- **AGENTS.md Harness:** include `emit_strategy`, `harness_owner`, and `platform_primary` (from intake); see `templates/fragments/HARNESS_PATHS.example.md`.

- Replace all `{{PLACEHOLDER}}` tokens.



### D — Verify



- Validate **`target_path`**: target-local `scripts/validate-target-harness.*`, or from toolkit: `bash "<toolkit_path>/scripts/validate-target-harness.sh" --strict "<target_path>"`.

- Lint + typecheck at **target_path**; for `full`, sync from target then re-validate.



### E — Handoff



- Summarize **target_path**, emit strategy, canonical path, platform_primary, artifacts per tool, validate/sync commands. User opens **target_path** for daily work.

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


