# Frontend harness bootstrap (full reference)

This document consolidates the bootstrap system. For day-to-day use, see [USAGE.md](USAGE.md) and [prompts/MASTER_BOOTSTRAP.md](../prompts/MASTER_BOOTSTRAP.md).

## Why

Coding agents fail more often from **harness configuration** (context bloat, missing verification, vague rules) than from model capability alone. This toolkit implements ideas from [HumanLayer — Harness Engineering for Coding Agents](https://www.humanlayer.dev/blog/skill-issue-harness-engineering-for-coding-agents):

- `coding agent = model(s) + harness`
- Thin `AGENTS.md`, skills for progressive disclosure
- Sub-agents as **context firewalls**, not role personas
- Hooks for **silent success**, noisy failures only
- Failure-driven harness growth

## Workflow summary

1. **Intake** — [intake/QUESTIONNAIRE.md](../intake/QUESTIONNAIRE.md)
2. **Plan** — [manifest/ARTIFACT_MANIFEST.md](../manifest/ARTIFACT_MANIFEST.md)
3. **Generate** — [templates/](../templates/)
4. **Verify** — run hook commands
5. **Handoff** — [templates/ORCHESTRATION.md.template](../templates/ORCHESTRATION.md.template)

## Repository layout

```
Frontend Harness Engineering/
├── prompts/MASTER_BOOTSTRAP.md    # Agent workflow
├── intake/QUESTIONNAIRE.md
├── manifest/ARTIFACT_MANIFEST.md
├── templates/                     # Copy into target projects
├── docs/                          # Human docs
└── .cursor/skills/frontend-harness-bootstrap/
```

## Target project layout (after bootstrap)

```
your-frontend-app/
├── AGENTS.md
└── .cursor/
    ├── ORCHESTRATION.md
    ├── rules/*.mdc
    ├── skills/*/SKILL.md
    ├── hooks.json
    └── hooks/*.sh | *.ps1
```

## Quality gates

Before marking bootstrap complete:

- `AGENTS.md` ≤ ~60 lines
- No duplicate guidance across `AGENTS.md` and `alwaysApply` rules
- Skills use `disable-model-invocation: true` unless user opted into auto-invoke
- Verify hook tested once on the target repo
- Orchestration doc includes sub-agent handoff contract
