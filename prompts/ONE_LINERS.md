# Bootstrap one-liners

Copy into the **target** project chat.

## New project

```text
Bootstrap frontend harness for this repo. Use skill frontend-harness-bootstrap (or prompts/MASTER_BOOTSTRAP.md from Frontend Harness Engineering). Run Phase A intake — I'll answer — then Phase B plan for approval, then generate.
```

## Existing project

```text
Bootstrap frontend harness. Inspect package.json and .cursor first. Ask only missing intake fields. Merge with existing AGENTS.md/rules if present. Templates from: C:\_Projects\Local\Frontend Harness Engineering\templates
```

## Fast path (defaults)

```text
Bootstrap frontend harness with defaults: Next 15 App Router + pnpm + shadcn + Tailwind + Biome + Vitest + Playwright CI-only. Infer paths from this repo. Generate without review if plan is obvious.
```

## Copy bootstrap skill only

```text
Copy .cursor/skills/frontend-harness-bootstrap from Frontend Harness Engineering into this repo, then run bootstrap Phase A–E.
```
