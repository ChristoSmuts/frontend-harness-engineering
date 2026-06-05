# HARNESS_PATHS — `full` emit

Replace `{{HARNESS_PATHS}}` in `AGENTS.md.template`. Omit tool lines not in intake.

```markdown
- **Emit strategy:** {{EMIT_STRATEGY}} · **Harness owner:** {{HARNESS_OWNER}} · **Platform primary:** {{PLATFORM_PRIMARY}}
- **Canonical skills:** `{{CANONICAL_SKILLS_DIR}}/` — edit here; run `{{HARNESS_SCRIPTS_DIR}}/sync-skills.sh --all-mirrors` after changes
- **Shared entry:** `AGENTS.md` (this file)
- **Orchestration:** `agents/ORCHESTRATION.md` · Cursor: `.cursor/ORCHESTRATION.md` (includes hooks)
- **Cursor:** rules `.cursor/rules/`, skills `.cursor/skills/` (mirror), hooks `.cursor/hooks.json`
- **Codex CLI:** skills `{{CANONICAL_SKILLS_DIR}}/` (canonical)
```

Example (Cursor + Codex, unix):

```markdown
- **Emit strategy:** full · **Harness owner:** solo · **Platform primary:** unix
- **Canonical skills:** `.agents/skills/` — edit here; run `.agent-scripts/sync-skills.sh --all-mirrors` after changes
- **Shared entry:** `AGENTS.md` (this file)
- **Orchestration:** `agents/ORCHESTRATION.md` · Cursor: `.cursor/ORCHESTRATION.md`
- **Cursor:** rules `.cursor/rules/`, skills `.cursor/skills/` (mirror), hooks `.cursor/hooks.json`
- **Codex CLI:** skills `.agents/skills/` (canonical)
```
