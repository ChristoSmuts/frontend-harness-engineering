# Frontend Harness Engineering (meta-repo)



This repository is a **toolkit**, not an application. Agents working here maintain templates and bootstrap docs.



## Layout



- `prompts/` — master bootstrap prompt for target projects

- `intake/` — questionnaire + `answers.schema.json`

- `manifest/` — artifact checklist, tool layout

- `templates/` — files to generate or copy into frontend repos

- `scripts/` — validate and sync (bash + PowerShell); copied to targets on bootstrap

- `fixtures/minimal-full-emit/` — CI smoke fixture (sync/validate scripts)
- `fixtures/golden-full-emit/` — reference `full` emit tree + `intake.answers.json`
- `fixtures/golden-portable-only-emit/` — reference `portable-only` emit + intake JSON
- `fixtures/golden-cursor-only-emit/` — reference `cursor-only` emit + intake JSON
- `scripts/emit-from-intake.sh` — deterministic harness emit (requires jq)

- `docs/START_HERE.md` — documentation hub

- `.cursor/skills/frontend-harness-bootstrap/` — Cursor: bootstrap another repo

- `agents/skills/frontend-harness-bootstrap/` — portable skill (Codex, Gemini, Claude, paste workflow)



## When editing this repo



- Keep `AGENTS.md` in generated **target** projects under ~60 lines; this file can be slightly longer.

- Templates use double-brace PLACEHOLDER syntax — do not commit unreplaced tokens into target repos.

- Keep `.cursor/skills/frontend-harness-bootstrap` and `agents/skills/frontend-harness-bootstrap` in sync.



## Commands



No app build.



```bash

# Optional local checks (Linux/macOS/Git Bash)

shellcheck scripts/*.sh templates/hooks/*.sh

bash scripts/validate-target-harness.sh fixtures/minimal-full-emit
bash scripts/validate-target-harness.sh --strict fixtures/golden-full-emit
bash scripts/validate-fixture-manifest.sh --profile full fixtures/golden-full-emit

```



```powershell

# Windows / macOS (PowerShell 7+)

pwsh -File scripts/validate-target-harness.ps1 -TargetRoot fixtures/minimal-full-emit

```



CI: `.github/workflows/validate-toolkit.yml` on push/PR (Linux, Windows, macOS).

## Shell conventions

On Windows, Shell-tool commands must use **PowerShell 7** syntax — not bash (`&&`, heredocs, `export`, etc.). See Cursor rule **`.cursor/rules/shell-conventions.mdc`**. Harness maintenance scripts have bash (CI) and `pwsh -File` (Windows) pairs — do not mix syntax in one command.


