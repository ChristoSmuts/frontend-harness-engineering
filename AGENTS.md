# Frontend Harness Engineering (meta-repo)

This repository is a **toolkit**, not an application. Agents working here maintain templates and bootstrap docs.

## Layout

- `prompts/` — master bootstrap prompt for target projects
- `intake/` — questionnaire
- `manifest/` — artifact checklist
- `templates/` — files to generate or copy into frontend repos
- `.cursor/skills/frontend-harness-bootstrap/` — invoke to bootstrap another repo

## When editing this repo

- Keep `AGENTS.md` in generated **target** projects under ~60 lines; this file can be slightly longer.
- Templates use `{{PLACEHOLDER}}` syntax — do not commit placeholders into target repos without replacing them.

## Commands

No app build. Optional: validate template shell scripts with `shellcheck` if installed.
