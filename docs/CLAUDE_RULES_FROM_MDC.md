# Claude rules from Cursor `.mdc` templates

When bootstrap emits `.claude/rules/*.md` from `templates/rules/*.mdc.template`:

## Steps

1. Copy the markdown **body** below the closing `---` of the `.mdc` file (skip YAML frontmatter).
2. Do **not** include Cursor-only keys (`alwaysApply`, `globs`, `description` YAML) unless Claude product docs for your version support equivalent metadata.
3. Keep one concern per file (~50 lines).

## Example

**Source:** `templates/rules/frontend-core.mdc.template`

```markdown
---
description: Core frontend harness conventions
alwaysApply: true
---

# Frontend core

- Match existing patterns...
```

**Target:** `.claude/rules/frontend-core.md`

```markdown
# Frontend core

- Match existing patterns...
```

## Scoped rules (typescript-react, ui-components)

Cursor uses:

```yaml
globs: "**/*.{ts,tsx}"
alwaysApply: false
```

For Claude, either:

- Create separate rule files and document scope in the rule title, or
- Rely on Claude’s rule matching if your version supports path patterns — follow current Claude Code docs.

## See also

- [manifest/TOOL_LAYOUT.md](../manifest/TOOL_LAYOUT.md)
- [EMIT_STRATEGIES.md](EMIT_STRATEGIES.md)
