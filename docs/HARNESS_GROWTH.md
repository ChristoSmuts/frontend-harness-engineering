# Harness growth guide

Single entry point for maintaining your frontend **coding-agent harness** after bootstrap. Your harness is the configuration (not the app) that keeps agents aligned with stack, design system, and verification.

## Lifecycle map

| Stage | When | What to do | Read |
|-------|------|------------|------|
| **Day 0** | Right after bootstrap | Run validate + lint/typecheck; skim `AGENTS.md` | [USAGE.md](USAGE.md), [MULTI_TOOL.md](MULTI_TOOL.md) |
| **Week 2+** | Same agent mistake twice | One minimal harness fix | Below — failure-driven |
| **Multi-tool** | Adding Codex, Claude, or second IDE | `full` emit or sync mirrors | [EMIT_STRATEGIES.md](EMIT_STRATEGIES.md), `scripts/sync-skills.sh` |
| **Team** | Second human editing harness | Owner + PR rules | [TEAM_GOVERNANCE.md](TEAM_GOVERNANCE.md) |
| **Parallel agents** | Cloud agents / multiple chats | Branches + scope | [PARALLEL_AGENTS.md](PARALLEL_AGENTS.md) |
| **Design system** | Figma/tokens/shadcn drift | Skills + MCP discipline | [DESIGN_SYSTEM_CONTEXT.md](DESIGN_SYSTEM_CONTEXT.md) |
| **Monorepo** | turbo/nx multi-app | Per-package verify | [MONOREPO_HARNESS.md](MONOREPO_HARNESS.md) |
| **Toolkit upgrade** | New template version | Copy or re-merge | [TOOLKIT_CONSUMPTION.md](TOOLKIT_CONSUMPTION.md) |

## Day 0 checklist

1. From target repo root: run validate per OS ([CROSS_PLATFORM.md](CROSS_PLATFORM.md)) — `bash scripts/validate-target-harness.sh` or `pwsh -File scripts/validate-target-harness.ps1`.
2. Run lint + typecheck from `AGENTS.md` (or trigger Cursor stop hook once).
3. Confirm **canonical skills** path in Harness section (usually `.agents/skills/`).
4. If `full` emit: run sync (`sync-skills.sh` or `sync-skills.ps1 -AllMirrors`) after any manual skill edit.

## Failure-driven growth (default)

When the agent fails the **same way twice**:

1. Pick the smallest fix: one rule line, one skill paragraph, one hook pattern, or one orchestration note.
2. Edit **canonical** skills (`.agents/skills/` for `full` / `portable-only`).
3. Run `scripts/sync-skills.sh` if mirrors exist.
4. Log in `HARNESS_CHANGELOG.md` (teams).
5. Do **not** add many MCP servers “just in case.”

## When to re-bootstrap vs patch

| Situation | Action |
|-----------|--------|
| New framework (e.g. Vite → Next) | Re-run bootstrap merge; update P2 skills |
| Added second AI tool | Switch emit to `full`; add mirrors + sync script |
| `AGENTS.md` over 60 lines | Move content into skills; trim entry file |
| Broken placeholders / paths | Fix + `validate-target-harness.sh` |

## Canonical hub reminder

For multi-tool teams, **`.agents/skills/`** is the source of truth. Cursor and Claude directories are mirrors unless you used `cursor-only` with no CLI tools.

## See also

- [prompts/MASTER_BOOTSTRAP.md](../prompts/MASTER_BOOTSTRAP.md) — full bootstrap workflow
- [manifest/ARTIFACT_MANIFEST.md](../manifest/ARTIFACT_MANIFEST.md) — what to generate
