# Tool layout — where harness artifacts go

Skills use the portable **`SKILL.md`** format (works across Cursor, Claude Code, Codex CLI, Gemini CLI, and others). **Rules and hooks are tool-specific** — generate only for tools the team selected in intake.

## Intake fields

See [intake/QUESTIONNAIRE.md](../intake/QUESTIONNAIRE.md): **Required before Phase C** (`emit_strategy`, `primary_tool`, `harness_owner`, `canonical_skills_dir`) and section **I. AI coding tools**.

## Emit strategies

Bootstrap Phase C branches on **emit_strategy**. Full reference: [docs/EMIT_STRATEGIES.md](../docs/EMIT_STRATEGIES.md).

| Strategy | Canonical skills | Mirrors |
|----------|------------------|---------|
| `full` | `.agents/skills/` | `.cursor/skills/`, `.claude/skills/` per selected tools |
| `portable-only` | `.agents/skills/` | None (CLI-first) |
| `cursor-only` | `.cursor/skills/` | None unless CLI tools also selected → use `full` |

Default **canonical_skills_dir** for multi-tool teams: `.agents/skills/`. Sync mirrors with [scripts/sync-skills.sh](../scripts/sync-skills.sh).

## Path matrix

| Artifact | Template | Cursor | Claude Code | Codex CLI | Gemini CLI |
|----------|----------|--------|-------------|-----------|------------|
| Agent entry (always) | `templates/AGENTS.md.template` | `AGENTS.md` | `AGENTS.md` | `AGENTS.md` | `AGENTS.md` |
| Claude entry (optional) | `templates/CLAUDE.md.template` | — | `CLAUDE.md` | — | — |
| Gemini entry (optional) | `templates/GEMINI.md.template` | — | — | — | `GEMINI.md` |
| Orchestration (shared) | `templates/ORCHESTRATION.shared.md.template` | `.cursor/ORCHESTRATION.md` (+ cursor-hooks) | `.claude/ORCHESTRATION.md` | `agents/ORCHESTRATION.md` | `agents/ORCHESTRATION.md` |
| Skills (each skill folder) | `templates/skills/*/` | `.cursor/skills/<name>/` **mirror** | `.claude/skills/<name>/` **mirror** | `.agents/skills/<name>/` **canonical** | `.agents/skills/<name>/` **canonical** |
| Rules (always-on) | `templates/rules/*.mdc.template` | `.cursor/rules/*.mdc` | `.claude/rules/*.md` (body from template; drop Cursor-only YAML or map `alwaysApply`) | — (use `AGENTS.md`) | — (use `AGENTS.md` + `GEMINI.md`) |
| Hooks | `templates/hooks/*` | `.cursor/hooks.json` + `.cursor/hooks/*` | — (use skill `frontend-verify` / manual) | `.codex/` hooks when project is trusted — see [docs/MULTI_TOOL.md](../docs/MULTI_TOOL.md) | — (use skill / manual) |

## Emit rules (bootstrap Phase C)

1. **Always** write root `AGENTS.md` with a **Harness** section (see `templates/fragments/HARNESS_PATHS.example.md`).
2. **Skills:** write to **canonical** dir first (`.agents/skills/` for `full` / `portable-only`; `.cursor/skills/` for `cursor-only`); mirror with `scripts/sync-skills.sh` on `full`.
3. **Orchestration:** `agents/ORCHESTRATION.md` = shared template only; `.cursor/ORCHESTRATION.md` = shared + cursor-hooks append; `.claude/ORCHESTRATION.md` = shared only.
4. **Rules:** generate `.mdc` only for Cursor; generate `.claude/rules/*.md` for Claude (markdown body from templates; do not commit broken Cursor frontmatter into Claude rules).
5. **Hooks:** generate only for **Cursor** by default; document Codex hook wiring separately if the user opts in.
6. **Do not** duplicate the whole toolkit into the target — only selected artifacts.

## Brownfield

Inspect existing harness dirs before overwriting:

| Tool | Inspect |
|------|---------|
| Cursor | `.cursor/` |
| Claude Code | `.claude/`, `CLAUDE.md` |
| Codex | `.codex/`, `.agents/` |
| Gemini CLI | `.gemini/`, `.agents/` |
| Any | root `AGENTS.md` |

Plan must show **create / merge / skip** per path per [docs/USAGE.md](../docs/USAGE.md).

## Portable hub (`.agents/`)

Codex and Gemini CLI both discover **`.agents/skills/`**. For **`full`** emit, this directory is the **canonical** skills source; `.cursor/skills/` and `.claude/skills/` are mirrors maintained by `scripts/sync-skills.sh`.

Optional reference copies:

- `agents/rules/*.md` — portable rule text for teams that want one file under version control (not auto-loaded by Cursor; useful for docs and non-Cursor agents).

## Toolkit repo (this meta-repo)

| Purpose | Path |
|---------|------|
| Cursor bootstrap skill | `.cursor/skills/frontend-harness-bootstrap/` |
| Portable bootstrap skill | `agents/skills/frontend-harness-bootstrap/` |
| Master prompt (any chat/CLI) | `prompts/MASTER_BOOTSTRAP.md` |
