---
name: frontend-verify
description: Runs fast lint/format and TypeScript checks for this frontend repo. Use before marking work complete, after UI or TypeScript edits, or when the user asks to verify, typecheck, or lint the project.
disable-model-invocation: true
---

# Frontend verify

## Commands

Run from project root{{MONOREPO_SKILL_NOTE}}:

{{VERIFY_CMDS_BLOCK}}

## Policy

- Fix all errors before claiming the task is done.
- Do **not** run the full E2E suite or entire unit test matrix unless the user explicitly asks.
- On success, report briefly; do not paste large green test logs into context.

## Optional single-file unit test

{{UNIT_VERIFY_CMDS_BLOCK}}

Replace file path when testing one module.
