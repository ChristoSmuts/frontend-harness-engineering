# Emit strategies

How much harness material to generate into a **target frontend project** during bootstrap. Set in intake (`emit_strategy`) and applied in Phase C of [prompts/MASTER_BOOTSTRAP.md](../prompts/MASTER_BOOTSTRAP.md).

**Delivery mode** (`delivery_mode` in intake JSON) is orthogonal to emit strategy:

| Mode | When to use | Includes |
|------|-------------|----------|
| **`standard`** (default) | Teams that want maintenance scripts, optional Cursor hooks, optional harness CI | `.agent-scripts/`, hooks, workflows per features |
| **`agent-only`** | Trust-sensitive teams, web zip generator, paste-into-repo workflow | Agent-readable files only — docs, rules, skills, JSON allowlists; skill mirrors inlined for `full` |

The web generator (`web/`) always uses `agent-only`. For CLI emit, add `"delivery_mode": "agent-only"` to your answers JSON — see [docs/EMIT_FROM_INTAKE.md](EMIT_FROM_INTAKE.md).

## Strategies

| Strategy | When to use | Emits | Skips |
|----------|-------------|-------|-------|
| **`full`** | Team uses 2+ AI tools or wants IDE + CLI parity | All paths for each **selected** tool per [manifest/TOOL_LAYOUT.md](../manifest/TOOL_LAYOUT.md); canonical skills in `.agents/skills/`; mirrors in `.cursor/skills/` and/or `.claude/skills/`; four maintenance scripts on target (bash + PowerShell) | — |
| **`portable-only`** | CLI-first (Codex/Gemini/Claude Code) or minimal repo surface | `AGENTS.md`, `agents/ORCHESTRATION.md`, `.agents/skills/*`, optional `GEMINI.md`; when **Claude Code** is selected: `CLAUDE.md`, `.claude/rules/`, `.claude/ORCHESTRATION.md` | Cursor `.mdc` rules, hooks, `.cursor/skills/` |
| **`cursor-only`** | Solo Cursor, no CLI agents | `AGENTS.md`, `.cursor/rules/`, `.cursor/skills/`, hooks, `.cursor/ORCHESTRATION.md` | `.agents/skills/` mirrors unless user also selected Codex/Gemini (then use `full` or `portable-only` + Cursor) |

## Required intake fields

| Field | Purpose |
|-------|---------|
| **emit_strategy** | `full` \| `portable-only` \| `cursor-only` |
| **primary_tool** | Where the developer spends most agent time (drives `{{SKILLS_DIR}}` in rules when ambiguous) |
| **tools in use** | Cursor, Claude Code, Codex CLI, Gemini CLI, other — see [intake/QUESTIONNAIRE.md](../intake/QUESTIONNAIRE.md) |
| **canonical_skills_dir** | Default `.agents/skills/`; use `.cursor/skills/` only for `cursor-only` with no CLI tools |

## Canonical hub (multi-tool `full`)

1. **Write skills once** to `.agents/skills/<name>/SKILL.md`.
2. **Mirror** to tool-specific dirs with `.agent-scripts/sync-skills.sh` or `.agent-scripts/sync-skills.ps1` (copied to target on bootstrap).
3. **Do not edit mirrors by hand** — edit canonical, then sync.

Portable orchestration lives at `agents/ORCHESTRATION.md` (shared template only). Cursor-specific hook notes append in `.cursor/ORCHESTRATION.md` — see [templates/ORCHESTRATION.shared.md.template](../templates/ORCHESTRATION.shared.md.template).

## Combining strategy with tools

| Tools selected | Recommended strategy |
|----------------|----------------------|
| Cursor only | `cursor-only` |
| Codex or Gemini only | `portable-only` |
| Cursor + Codex/Gemini | `full` |
| Cursor + Claude + CLI | `full` |
| Copilot/Windsurf only | `portable-only` (`AGENTS.md` + `.agents/skills/`) |
| Claude Code only | `portable-only` (includes `.claude/` + `CLAUDE.md`) |

## Brownfield

Emit strategy applies to **new paths** only. Phase B must still show **create / merge / skip** per file.

## Migrating `cursor-only` → `full`

When adding Codex, Gemini, or Claude Code to a repo that used `cursor-only`:

1. Create `.agents/skills/` and move or copy skill folders from `.cursor/skills/` (canonical was `.cursor/skills/`).
2. Update `AGENTS.md` Harness section: `emit_strategy: full`, `canonical_skills_dir: .agents/skills/`.
3. Copy all four maintenance scripts if missing (see [TOOLKIT_CONSUMPTION.md](TOOLKIT_CONSUMPTION.md)).
4. Sync mirrors:

   ```bash
   bash .agent-scripts/sync-skills.sh --all-mirrors
   ```

   ```powershell
   pwsh -File .agent-scripts/sync-skills.ps1 -AllMirrors
   ```

5. Re-run validate ([CROSS_PLATFORM.md](CROSS_PLATFORM.md)).

One-time migration from `.cursor/skills` as source without moving files yet:

```bash
bash .agent-scripts/sync-skills.sh --canonical .cursor/skills --all-mirrors
```

```powershell
pwsh -File .agent-scripts/sync-skills.ps1 -Canonical .cursor/skills -AllMirrors
```

Then set canonical to `.agents/skills/` and copy skills there before future edits.

## Bootstrap guardrails

| Intake | Required emit |
|--------|----------------|
| Cursor + Codex or Gemini CLI | `full` (not `cursor-only`) |
| Codex/Gemini only | `portable-only` or `full` if IDE also |
| `cursor-only` + CLI tools listed | Agent must correct to `full` before Phase C |

## See also

- [docs/MULTI_TOOL.md](MULTI_TOOL.md) — per-product usage
- [docs/HARNESS_GROWTH.md](HARNESS_GROWTH.md) — when to change strategy as the team grows
