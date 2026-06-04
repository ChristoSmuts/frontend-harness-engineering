# Frontend harness bootstrap (reference)

**Start here:** [START_HERE.md](START_HERE.md) — bootstrap workflow, emit strategies, and cross-platform commands.

## Agent workflow

Full phases A–E: [prompts/MASTER_BOOTSTRAP.md](../prompts/MASTER_BOOTSTRAP.md).

## Quality gates (target repo)

Before marking bootstrap complete:

- `AGENTS.md` ≤ ~60 lines
- No unreplaced `{{` tokens (validate: [CROSS_PLATFORM.md](CROSS_PLATFORM.md))
- Skills use `disable-model-invocation: true` unless user opted into auto-invoke
- Verify hook tested once on the target repo
- Orchestration includes sub-agent handoff contract
- On `full` emit: mirrors match canonical after sync

## Target layout (`full` emit)

```
your-frontend-app/
├── AGENTS.md
├── agents/ORCHESTRATION.md
├── .agents/skills/*/SKILL.md    # canonical
├── scripts/
│   ├── validate-target-harness.sh
│   ├── validate-target-harness.ps1
│   ├── sync-skills.sh
│   └── sync-skills.ps1
├── .cursor/                     # if Cursor
│   ├── skills/*/SKILL.md        # mirrors
│   ├── hooks.json
│   └── hooks/*.sh | *.ps1
└── .claude/                     # if Claude Code
```

## See also

| Doc | Topic |
|-----|--------|
| [USAGE.md](USAGE.md) | Three bootstrap methods |
| [EMIT_STRATEGIES.md](EMIT_STRATEGIES.md) | full / portable-only / cursor-only |
| [TOOLKIT_CONSUMPTION.md](TOOLKIT_CONSUMPTION.md) | Submodule / copy / multi-root |
