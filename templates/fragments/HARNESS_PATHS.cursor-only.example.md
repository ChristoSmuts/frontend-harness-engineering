# HARNESS_PATHS — `cursor-only` emit

Replace `{{HARNESS_PATHS}}` in `AGENTS.md.template`. Do not reference `agents/ORCHESTRATION.md` in the target repo.

```markdown
- **Emit strategy:** {{EMIT_STRATEGY}} · **Harness owner:** {{HARNESS_OWNER}} · **Platform primary:** {{PLATFORM_PRIMARY}}
- **Canonical skills:** `{{CANONICAL_SKILLS_DIR}}/` — typically `.cursor/skills/`
- **Shared entry:** `AGENTS.md` (this file)
- **Orchestration:** `.cursor/ORCHESTRATION.md`
- **Cursor:** rules `.cursor/rules/`, hooks `.cursor/hooks.json`
```

Example:

```markdown
- **Emit strategy:** cursor-only · **Harness owner:** solo · **Platform primary:** unix
- **Canonical skills:** `.cursor/skills/`
- **Shared entry:** `AGENTS.md` (this file)
- **Orchestration:** `.cursor/ORCHESTRATION.md`
- **Cursor:** rules `.cursor/rules/`, hooks `.cursor/hooks.json`
```
