# Harness CI for target repos

Copy [templates/github/workflows/harness-validate.yml.template](../templates/github/workflows/harness-validate.yml.template) to `.github/workflows/harness-validate.yml` after bootstrap (or enable `features.harness_ci_workflow` in intake JSON for `emit-from-intake`).

## What it runs

| Job | Purpose |
|-----|---------|
| `validate-unix` | `bash .agent-scripts/validate-target-harness.sh --strict` |
| `sync-check` | Runs `sync-skills.sh --all-mirrors` and fails if mirrors differ from canonical |

## Strict mode

`--strict` turns warnings (line count, mirror drift, platform/hook mismatch) into CI failures. Use on teams that want enforceable harness hygiene.

```bash
bash .agent-scripts/validate-target-harness.sh --strict
pwsh -File .agent-scripts/validate-target-harness.ps1 -Strict
```

## When to run sync locally vs in CI

- **Locally:** after every edit under `.agents/skills/`, before commit.
- **CI:** catches forgotten sync on PRs; optional if your team always syncs locally.

## Pre-commit (optional)

See [templates/hooks/pre-commit-sync.example](../templates/hooks/pre-commit-sync.example) for a bash hook that syncs when canonical skills change.

## Toolkit meta-repo CI

This toolkit validates `fixtures/minimal-full-emit/` (smoke) and `fixtures/golden-full-emit/` (full emit reference) in [.github/workflows/validate-toolkit.yml](../.github/workflows/validate-toolkit.yml).

## See also

- [TEAM_GOVERNANCE.md](TEAM_GOVERNANCE.md)
- [CROSS_PLATFORM.md](CROSS_PLATFORM.md)
- [EMIT_FROM_INTAKE.md](EMIT_FROM_INTAKE.md)
