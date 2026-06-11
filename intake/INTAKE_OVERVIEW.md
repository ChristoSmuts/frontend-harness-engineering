# Bootstrap intake overview

Read this **before** Phase A questions. It explains what harness bootstrap produces and what each intake answer controls.

## What you'll get

| After bootstrap | Purpose |
|-----------------|---------|
| `AGENTS.md` | Thin always-on agent entry (~60 lines) |
| `.agents/skills/` | Canonical skills (`full` / `portable-only` emit) |
| `.cursor/rules/` | Cursor rules when Cursor is selected |
| `HARNESS_CHANGELOG.md` | Team audit trail (when team owner) |
| `agents/ORCHESTRATION.md` | Sub-agent handoff contract (multi-tool / portable) |

**`standard` delivery only** (default for emit/bootstrap):

| Artifact | Purpose |
|----------|---------|
| `.cursor/hooks/`, `hooks.json` | Cursor stop-hook back-pressure |
| `.agent-scripts/` | Harness validate/sync + hook support libs (**not** app build scripts) |
| `.github/workflows/` | Optional harness CI and secret scanning |

**`agent-only` delivery** omits shell scripts, Cursor hooks, and GitHub workflows. Skill mirrors for `full` emit are copied inline at emit time (no `sync-skills` script). See [docs/EMIT_STRATEGIES.md](../docs/EMIT_STRATEGIES.md).

The **web generator** (`web/`) always uses `agent-only` and returns a zip — no repo access required.

Toolkit meta-repo keeps its own `scripts/` for emit and CI. Only the **target frontend repo** receives `.agent-scripts/` when `delivery_mode` is `standard`.

## Question → controls → artifact

| Step / question | Your answer controls | Produces |
|-----------------|---------------------|----------|
| Workspace + **target_path** | Where files are written | Harness tree under `target_path`; `toolkit_path` for templates |
| **delivery_mode** | Scripts, hooks, CI | `standard` vs `agent-only` file set |
| **emit_strategy** | Layout breadth | `full` (mirrors + hooks) / `portable-only` / `cursor-only` file set |
| **primary_tool** | Default skill invocation style | Documented in `AGENTS.md` Harness section |
| **tools_in_use** | Which tool dirs get artifacts | `.cursor/`, `.claude/`, `.agents/` mirrors |
| **platform_primary** | Hook shell flavor | Unix vs Windows `hooks.json` templates (`standard` only) |
| **hooks_prefs** | Stop-hook behavior | Verify, secret scan, shell guard combinations (`standard` only) |
| **harness_owner** | Who approves harness PRs | `HARNESS_CHANGELOG.md` owner line |
| **repo_type** | Brownfield vs greenfield | Merge/skip vs generate; inspection depth at `target_path` |

## Phase A flow (agent)

1. Show this overview (brief).
2. **Auto-detect workspace** or ask `workspace_context` when ambiguous.
3. **Collect `target_path` first** when toolkit is open — before preference questions.
4. Run **AskQuestion** bundle for harness preferences (descriptive labels in [QUESTIONNAIRE.md](QUESTIONNAIRE.md)).
5. Post **intake summary**, then Phase B Harness Plan.

See [QUESTIONNAIRE.md](QUESTIONNAIRE.md) and [prompts/MASTER_BOOTSTRAP.md](../prompts/MASTER_BOOTSTRAP.md).
