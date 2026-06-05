# Team harness governance

How multiple humans maintain one frontend harness without bloat or conflicting instructions.

## Roles

| Role | Responsibility |
|------|----------------|
| **Harness owner** | Intake field `harness_owner`; approves harness PRs; decides emit strategy changes |
| **Feature developers** | Edit app code; avoid drive-by harness edits during features |
| **Agent sessions** | Follow `AGENTS.md`; load skills when task matches |

## PR rules for harness files

Apply to `AGENTS.md`, `**/ORCHESTRATION.md`, `**/.agents/skills/**`, mirrors, `.cursor/rules/**`, `.claude/rules/**`, hooks, `HARNESS_CHANGELOG.md`:

1. **One concern per change** — no drive-by refactors across harness + app in one PR unless labeled.
2. **`AGENTS.md` ≤ ~60 lines** — move depth into skills.
3. **No duplicate guidance** — if it is in an `alwaysApply` rule, do not repeat verbatim in `AGENTS.md`.
4. **Canonical first** — edit `.agents/skills/`; run `scripts/sync-skills.sh` before merge when mirrors exist.
5. **Changelog** — one row in `HARNESS_CHANGELOG.md` per intentional harness change.

## Brownfield merge policy

Phase B bootstrap plan must list **create / merge / skip** per path ([USAGE.md](USAGE.md)):

- **Merge:** append new bullets to `AGENTS.md`; do not duplicate existing rules.
- **Skip:** leave third-party or legacy agent config untouched.
- **Create:** new skill folder only when intake condition matches P2.

## When to re-bootstrap vs patch

| Trigger | Prefer |
|---------|--------|
| Single repeated agent mistake | Patch one skill/rule |
| New tool (e.g. add Claude) | `full` emit paths + sync script |
| Harness > 2x intended size | Trim + move to skills; optional re-bootstrap merge |
| Toolkit major upgrade | [TOOLKIT_CONSUMPTION.md](TOOLKIT_CONSUMPTION.md) |

## CI sync discipline

When `.agents/skills/**` changes in a PR:

1. Run `bash scripts/sync-skills.sh --all-mirrors` locally and commit mirrors, **or**
2. Rely on the `sync-check` job in [HARNESS_CI.md](HARNESS_CI.md) (`harness-validate.yml`) to fail the PR if mirrors drift.

## Security-sensitive harness changes

Treat PRs that touch **`.cursor/hooks.json`**, **`.cursor/hooks/*`**, **`.cursor/rules/*`**, or **`mcp-allowlist.json`** as security-sensitive:

1. Require **harness owner** review (intake field `harness_owner`).
2. Run `validate-target-harness.sh --strict` locally before merge.
3. Document new MCP servers or allowed domains in `HARNESS_CHANGELOG.md`.
4. Do not add hook scripts that call `curl`, `wget`, or external URLs outside the project's allowlist pattern.

## Review checklist (human)

- [ ] `scripts/validate-target-harness.sh` passes (use `--strict` for harness-only PRs)
- [ ] Lint/typecheck commands still match `package.json`
- [ ] Mirrors synced if multi-tool
- [ ] No new MCP servers without justification in changelog
- [ ] Hook path changes stay under `.cursor/hooks/` or `scripts/`

## See also

- [HARNESS_GROWTH.md](HARNESS_GROWTH.md)
- [PARALLEL_AGENTS.md](PARALLEL_AGENTS.md)
