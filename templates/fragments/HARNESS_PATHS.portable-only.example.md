# HARNESS_PATHS — `portable-only` emit

Replace `{{HARNESS_PATHS}}` in `AGENTS.md.template`. Add Claude or Gemini lines when those tools are in intake.

```markdown
- **Emit strategy:** {{EMIT_STRATEGY}} · **Harness owner:** {{HARNESS_OWNER}} · **Platform primary:** {{PLATFORM_PRIMARY}}
- **Canonical skills:** `{{CANONICAL_SKILLS_DIR}}/` — edit here; run `scripts/sync-skills.sh` after changes when mirrors exist
- **Shared entry:** `AGENTS.md` (this file)
- **Orchestration:** `agents/ORCHESTRATION.md`
- **Codex CLI:** skills `{{CANONICAL_SKILLS_DIR}}/` (canonical)
```

Example (Codex only):

```markdown
- **Emit strategy:** portable-only · **Harness owner:** solo · **Platform primary:** unix
- **Canonical skills:** `.agents/skills/` — edit here
- **Shared entry:** `AGENTS.md` (this file)
- **Orchestration:** `agents/ORCHESTRATION.md`
- **Codex CLI:** skills `.agents/skills/` (canonical)
```

Example (Claude Code only):

```markdown
- **Emit strategy:** portable-only · **Harness owner:** solo · **Platform primary:** unix
- **Canonical skills:** `.agents/skills/` — edit here
- **Shared entry:** `AGENTS.md` (this file)
- **Orchestration:** `agents/ORCHESTRATION.md` · Claude: `.claude/ORCHESTRATION.md`
- **Claude Code:** `CLAUDE.md`, rules `.claude/rules/`, skills `.agents/skills/` (canonical)
```
