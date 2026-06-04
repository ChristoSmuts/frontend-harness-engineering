---
name: frontend-verify
description: Runs fast lint/format and TypeScript checks for this frontend repo. Use before marking work complete, after UI or TypeScript edits, or when the user asks to verify, typecheck, or lint the project.
disable-model-invocation: true
---

# Frontend verify

## Commands

```bash
pnpm biome check --write .
pnpm exec tsc --noEmit
```

## Policy

- Fix all errors before claiming the task is done.
- Do **not** run the full E2E suite unless the user explicitly asks.
