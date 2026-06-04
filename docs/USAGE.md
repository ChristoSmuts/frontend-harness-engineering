# Usage guide

## Three ways to bootstrap a target project

### 1. Cursor skill (recommended)

In the **target** frontend repo, ensure the bootstrap skill is available:

- **Option A:** Copy `.cursor/skills/frontend-harness-bootstrap/` from this toolkit into the target once, or
- **Option B:** Add this toolkit path to your workflow and say: *Use frontend-harness-bootstrap from Frontend Harness Engineering.*

Then run:

> Bootstrap the frontend harness for this project. Follow MASTER_BOOTSTRAP phases A–E.

### 2. Paste master prompt

Open [prompts/MASTER_BOOTSTRAP.md](../prompts/MASTER_BOOTSTRAP.md) in the target workspace chat. Add:

> Target is this repo. Run intake from intake/QUESTIONNAIRE.md. Templates are at `<path-to-this-toolkit>/templates/`.

If the toolkit is not in workspace, attach or paste the questionnaire and relevant templates.

### 3. Manual copy

1. Complete [intake/QUESTIONNAIRE.md](../intake/QUESTIONNAIRE.md) yourself.
2. Copy templates from [templates/](../templates/).
3. Replace every `{{PLACEHOLDER}}`.
4. Pick skills from [manifest/ARTIFACT_MANIFEST.md](../manifest/ARTIFACT_MANIFEST.md).
5. Run lint + typecheck; fix hook script commands.

## New vs existing projects

| Scenario | Agent behavior |
|----------|----------------|
| **New** | Ask full intake (or defaults); generate full P0+P1; add P2 from stack answers |
| **Existing** | Read `package.json`, `components.json`, tree; minimal questions; merge with existing `.cursor/` — do not blindly overwrite |

## Merging with existing harness

If `.cursor/rules` or `AGENTS.md` already exist:

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

## Framework quick map

See [FRAMEWORK_MAPPING.md](FRAMEWORK_MAPPING.md).
