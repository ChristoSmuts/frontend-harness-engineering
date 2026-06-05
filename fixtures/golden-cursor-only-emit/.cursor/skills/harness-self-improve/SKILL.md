---
name: harness-self-improve
description: Maintains the project harness when repeat agent failures are logged. Use when the failure ledger shows count >= 2 for an open entry, the user asks to stop repeating a mistake, or a stop hook requests harness growth.
disable-model-invocation: true
---

# Harness self-improvement

## When to use

- Failure ledger (`.agents/harness/failure-ledger.json` or `.cursor/harness/failure-ledger.json`) has an entry with `count >= 2` and `fix_status: open`
- User says the agent keeps making the same mistake
- Cursor `stop` hook reports harness growth required
- User explicitly asks to update agent guidance for a repeatable failure

## Twice rule

- **First occurrence:** log to the failure ledger only (`count: 1`). Do not edit rules, skills, or hooks yet.
- **Second occurrence** (same fingerprint): increment `count`, then apply one minimal harness fix using this skill.

## Smallest-fix decision tree

| Failure shape | Prefer |
|---------------|--------|
| Always-on convention (wrong import path, forbidden dir, global pattern) | One line in `frontend-core` or scoped rule (`ui-components`, `typescript-react`) |
| Task-shaped workflow (wrong shadcn flow, wrong data layer, framework API) | Extend an existing P2 skill under canonical skills dir |
| Repeatable verify miss (lint/typecheck pattern) | Extend `frontend-verify` skill or verify hook |
| Delegation / handoff mistake | One note in `agents/ORCHESTRATION.md` or `.cursor/ORCHESTRATION.md` |

Prefer extending an existing skill over creating a new one. Max ~15 lines per patch.

## Failure ledger

Path (pick the one that exists):

- `full` / `portable-only`: `.agents/harness/failure-ledger.json`
- `cursor-only`: `.cursor/harness/failure-ledger.json`

When logging a failure:

1. Normalize `summary` (short, no secrets, no full chat dumps)
2. Compute stable `id` (e.g. sha256 of `category` + lowercase trimmed summary)
3. If `id` exists: increment `count`, update `last_seen`
4. Else: append entry with `count: 1`, `fix_status: open`, ISO-8601 timestamps

Categories: `ui-components`, `verify`, `security`, `routing`, `data-fetching`, `orchestration`, `other`.

## Auto-apply workflow

1. Load this skill and read the open ledger entry(s) with `count >= 2`
2. Pick the smallest artifact from the decision tree
3. Edit **canonical** harness only (`.cursor/skills/` for skills; `.cursor/rules/` for Cursor rules)
4. Do **not** duplicate guidance into `AGENTS.md` (keep <= 60 lines)
5. For a new project skill, run `.agent-scripts/register-harness-growth.sh --kind skill --name <kebab> --when "<when>" --summary "<what>"` (or `.ps1` on Windows)
6. For orchestration index rows: `.agent-scripts/register-harness-growth.sh --kind orchestration-row --name <skill> --when "<when>"`
7. Run `.agent-scripts/sync-skills.sh --all-mirrors --orchestration` (or `sync-skills.ps1 -AllMirrors -Orchestration`)
8. Run `.agent-scripts/validate-target-harness.sh` (or `.ps1`); fix errors before finishing
9. Append a row to `HARNESS_CHANGELOG.md` with trigger referencing the ledger `id`
10. Set ledger entry `fix_status: applied` and `fix_artifact` to what you changed

## New skill structure

```markdown
---
name: kebab-case-name
description: <WHAT in third person>. Use when <WHEN>.
disable-model-invocation: true
---
```

Follow existing skills in `.cursor/skills/` for section layout.

## Anti-bloat

- Dedupe by ledger `id` — one fix per fingerprint
- Prefer `shadcn-components` over `shadcn-button-rules`
- Mark false positives `fix_status: wontfix` in the ledger (user request)
- Prune resolved entries older than 90 days if the team agrees

## Project-specific notes

- Harness owner: solo
- Canonical skills: `.cursor/skills/`
- See toolkit `docs/HARNESS_GROWTH.md` for team governance
