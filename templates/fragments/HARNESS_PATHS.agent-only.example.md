# HARNESS_PATHS — `agent-only` delivery

Used when `delivery_mode` is `agent-only`. No validate/sync scripts or hooks in the harness tree.

```markdown
- **Emit strategy:** {{EMIT_STRATEGY}} · **Delivery:** agent-only · **Harness owner:** {{HARNESS_OWNER}}
- **Canonical skills:** `{{CANONICAL_SKILLS_DIR}}/` — edit here; mirrors are pre-copied at emit for `full` emit
- **Shared entry:** `AGENTS.md` (this file)
```

For `full` + agent-only with Cursor + Codex, mirrors under `.cursor/skills/` are included without a sync script.
