# Cross-platform harness maintenance

Harness maintenance scripts and Cursor verify hooks must work on **Linux**, **macOS**, and **Windows** without requiring WSL.

## Requirements

| Component | Linux / macOS | Windows |
|-----------|---------------|---------|
| Validate harness (target repo) | `bash .agent-scripts/validate-target-harness.sh` | `pwsh -File .agent-scripts/validate-target-harness.ps1` |
| Sync skill mirrors (target repo) | `bash .agent-scripts/sync-skills.sh --all-mirrors` | `pwsh -File .agent-scripts/sync-skills.ps1 -AllMirrors` |
| Cursor stop hook (default) | `.cursor/hooks/verify-frontend.sh` | `.cursor/hooks/verify-frontend.ps1` when **Windows-primary** |
| PowerShell for `.ps1` scripts | Optional (pwsh 7+ if you prefer PS over bash) | **PowerShell 7+** (`pwsh`) — [install](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell) |

Bash on Windows via Git Bash is **optional** for maintenance scripts, not required.

## Remote `target_path` (bootstrap from toolkit)

When the open workspace is **Frontend Harness Engineering**, intake records **`target_path`** — the frontend repo that receives harness files. It is independent of **`platform_primary`** (hook templates only).

| OS | Example `target_path` |
|----|------------------------|
| macOS | `/Users/you/dev/acme-web` |
| Linux | `/home/you/projects/acme-web` |
| Windows | `C:\dev\acme-web`, `C:/dev/acme-web`, or Git Bash `/c/dev/acme-web` |

Prefer **absolute** paths. `scripts/emit-from-intake.sh` normalizes paths via [`scripts/lib/normalize-target-path.sh`](../scripts/lib/normalize-target-path.sh) (Windows drive letters → `/c/...` when using Git Bash) and refuses to emit into the toolkit meta-repo or mistaken nested folders under the toolkit.

### Windows paths and Git Bash

| Form | Notes |
|------|--------|
| `C:\dev\acme web` | OK in answers JSON; use `emit-from-intake.ps1` or bash with `target_path` in JSON only |
| `C:/dev/acme web` | Preferred in JSON for Git Bash emit |
| `/c/dev/acme web` | Git Bash absolute form |
| Paths with spaces | Quote in shell; **do not** pass `--target` from PowerShell as separate unquoted argv tokens |

Emit never creates a missing target directory. Invalid Windows paths must not produce `C:/...` trees inside the toolkit checkout.

Emit from toolkit root:

```bash
bash scripts/emit-from-intake.sh \
  --answers "$HOME/frontend-harness-intake/acme-web.answers.json" \
  --toolkit .
```

(`--target` optional when `target_path` is in the answers JSON—preferred on Windows so paths with spaces stay in JSON.)

Validate before target `.agent-scripts/` exist (from **toolkit** checkout):

```bash
bash scripts/validate-target-harness.sh --strict "/Users/you/dev/acme-web"
```

```powershell
pwsh -File scripts/validate-target-harness.ps1 -Strict -TargetRoot 'C:\dev\acme-web'
```

## Validate

From the **target repo root** (harness scripts live in `.agent-scripts/`, separate from app `scripts/`):

```bash
# Linux / macOS
bash .agent-scripts/validate-target-harness.sh
bash .agent-scripts/validate-target-harness.sh path/to/repo
bash .agent-scripts/validate-target-harness.sh --strict path/to/repo
```

```powershell
# Windows (PowerShell 7+)
pwsh -File .agent-scripts/validate-target-harness.ps1
pwsh -File .agent-scripts/validate-target-harness.ps1 -TargetRoot path\to\repo
pwsh -File .agent-scripts/validate-target-harness.ps1 -Strict
```

Legacy targets may still have `scripts/validate-target-harness.*` — validate warns and accepts; prefer migrating to `.agent-scripts/` (see [HARNESS_GROWTH.md](HARNESS_GROWTH.md)).

## Sync skills

After editing **canonical** skills (usually `.agents/skills/` on `full` emit):

```bash
bash .agent-scripts/sync-skills.sh --all-mirrors
# Optional: custom canonical dir (cursor-only → full migration)
CANONICAL_SKILLS_DIR=.cursor/skills bash .agent-scripts/sync-skills.sh --canonical .cursor/skills --all-mirrors
```

```powershell
pwsh -File .agent-scripts/sync-skills.ps1 -AllMirrors
pwsh -File .agent-scripts/sync-skills.ps1 -Canonical .cursor/skills -AllMirrors
```

Orchestration sync (when using split shared + cursor-hooks templates):

```bash
bash .agent-scripts/sync-skills.sh --orchestration
```

```powershell
pwsh -File .agent-scripts/sync-skills.ps1 -Orchestration
```

## Cursor hooks

| Intake `platform_primary` | `hooks.json` stop command | Template |
|---------------------------|---------------------------|----------|
| `unix` (default) | `.cursor/hooks/verify-frontend.sh` | `templates/hooks/hooks.json.template` |
| `windows` | `.cursor/hooks/verify-frontend.ps1` | `templates/hooks/hooks.windows.json.template` |

| Intake `platform_primary` | Shell guard (`beforeShellExecution`) |
|---------------------------|--------------------------------------|
| `unix` (default) | `.cursor/hooks/deny-dangerous.sh` (bash) |
| `windows` | `.cursor/hooks/deny-dangerous.ps1` (PowerShell) |

Mixed teams on Windows with `platform_primary: unix` still use the bash deny script (Git Bash required). Prefer `platform_primary: windows` on Windows-primary machines so both stop verify and shell guard use `.ps1`.

## Agent shell syntax

Emitted targets include a **`shell-conventions`** rule (`.cursor/rules/shell-conventions.mdc` on Cursor; `.claude/rules/shell-conventions.md` on Claude) driven by intake **`platform_primary`**:

| `platform_primary` | Agent Shell-tool syntax |
|--------------------|-------------------------|
| `windows` | PowerShell 7 only — no bash `&&`, heredocs, or `export` |
| `unix` (default) | bash/sh |

`AGENTS.md` includes a **Shell conventions** line; skill `frontend-verify` uses platform-appropriate command fences. The toolkit meta-repo has `.cursor/rules/shell-conventions.mdc` for maintainers on Windows.

## Monorepo

When the app package is not the repo root, bootstrap sets `{{APP_PACKAGE_PATH}}` in verify hooks (see [MONOREPO_HARNESS.md](MONOREPO_HARNESS.md)). Both `.sh` and `.ps1` verify scripts `cd` into that path before lint/typecheck.

## CI (toolkit meta-repo)

GitHub Actions runs bash validate on `ubuntu-latest` and PowerShell validate on `windows-latest` against `fixtures/minimal-full-emit/` and `fixtures/golden-full-emit/` (see [HARNESS_CI.md](HARNESS_CI.md)).

## See also

- [START_HERE.md](START_HERE.md)
- [TOOLKIT_CONSUMPTION.md](TOOLKIT_CONSUMPTION.md)
- [EMIT_STRATEGIES.md](EMIT_STRATEGIES.md)
