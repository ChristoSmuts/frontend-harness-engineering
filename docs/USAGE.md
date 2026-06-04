# Usage guide

See [MULTI_TOOL.md](MULTI_TOOL.md) for Cursor, Claude Code, Codex CLI, and Gemini CLI specifics. After bootstrap, see [HARNESS_GROWTH.md](HARNESS_GROWTH.md).

## Ways to bootstrap a target project

### 1. Bootstrap skill (recommended)

**From the target repo** — copy the bootstrap skill from this toolkit:

| Tool | Copy from toolkit |
|------|-------------------|
| Cursor | `.cursor/skills/frontend-harness-bootstrap/` |
| Claude Code, Codex, Gemini, others | `agents/skills/frontend-harness-bootstrap/` |

Or point the agent at this repo and say: *Use frontend-harness-bootstrap from Frontend Harness Engineering.*

Then run:

> Bootstrap the frontend harness for this project. AI tools: \<list yours\>. Follow MASTER_BOOTSTRAP phases A–E.

**From the toolkit repo** — open Frontend Harness Engineering, run the same skill (or point the agent at this repo). At intake, set **`target_path`** to the absolute path of each app you bootstrap (`toolkit_path`: `.`). Re-run with a new `target_path` for the next project. See [TOOLKIT_CONSUMPTION.md](TOOLKIT_CONSUMPTION.md).

### 2. Paste master prompt (any agent)

**Target workspace:** [prompts/MASTER_BOOTSTRAP.md](../prompts/MASTER_BOOTSTRAP.md) in the app repo chat:

> Target is this repo (`target_path` .). AI tools: Cursor, Codex CLI. Templates at `<path-to-toolkit>/templates/`.

**Toolkit workspace:**

> Toolkit is this repo. Bootstrap harness at target_path: `/Users/you/dev/acme-web` (or `C:\dev\acme-web`). AI tools: Cursor. toolkit_path: .

### 3. Manual copy

1. Complete [intake/QUESTIONNAIRE.md](../intake/QUESTIONNAIRE.md) yourself.
2. Copy templates from [templates/](../templates/).
3. Replace every `{{PLACEHOLDER}}`.
4. Pick skills from [manifest/ARTIFACT_MANIFEST.md](../manifest/ARTIFACT_MANIFEST.md).
5. Run `bash scripts/validate-target-harness.sh` and lint + typecheck; fix hook script commands.

## New vs existing projects

| Scenario | Agent behavior |
|----------|----------------|
| **New** | Ask full intake (or defaults); generate full P0+P1; add P2 from stack answers |
| **Existing** | Read `package.json`, `components.json`, tree under **`target_path`**; minimal questions; merge with existing harness dirs — do not blindly overwrite |

## Merging with existing harness

If `.cursor/rules`, `.claude/`, `.agents/`, or `AGENTS.md` already exist:

1. Phase B plan must show **create / merge / skip** per file.
2. Prefer merging new sections over duplicating instructions.
3. Keep combined `AGENTS.md` under ~60 lines (move detail into skills).

## Extending after bootstrap

When the agent fails a repeatable way, add **one** harness fix:

- A new rule line
- A skill section
- A hook matcher
- An orchestration note for sub-agents

Avoid installing many MCP servers "just in case."

## Maintenance scripts (target repo)

| Script | Purpose |
|--------|---------|
| `scripts/validate-target-harness.sh` / `.ps1` | Placeholders, line counts, hook paths, mirror drift |
| `scripts/sync-skills.sh` / `.ps1` | Copy canonical skills → `.cursor/` / `.claude/` mirrors |

See [CROSS_PLATFORM.md](CROSS_PLATFORM.md) for OS-specific commands.

Copied from toolkit on `full` emit; see [EMIT_STRATEGIES.md](EMIT_STRATEGIES.md).

## Framework quick map

See [FRAMEWORK_MAPPING.md](FRAMEWORK_MAPPING.md).
