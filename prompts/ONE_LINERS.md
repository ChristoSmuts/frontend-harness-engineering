# Bootstrap one-liners

## Toolkit repo open (remote target)

```text
Bootstrap frontend harness from this toolkit repo. target_path: /Users/you/dev/acme-web (or C:\dev\acme-web). toolkit_path: . AI tools: Cursor + Codex CLI. Run MASTER_BOOTSTRAP Phase A–E.
```

## Target project chat

### New project

```text
Bootstrap frontend harness for this repo. Use skill frontend-harness-bootstrap (or prompts/MASTER_BOOTSTRAP.md from Frontend Harness Engineering). Run Phase A intake — I'll answer — then Phase B plan for approval, then generate.
```

## Existing project

```text
Bootstrap frontend harness. AI tools: Cursor + Codex CLI. Inspect package.json and existing .cursor/, .agents/ first. Ask only missing intake fields. Merge with existing AGENTS.md/rules if present. Templates from: <path-to-toolkit>/templates — paths per manifest/TOOL_LAYOUT.md
```

## Fast path (defaults)

```text
Bootstrap frontend harness with defaults: Next 15 App Router + pnpm + shadcn + Tailwind + Biome + Vitest + Playwright CI-only. Infer paths from this repo. Generate without review if plan is obvious.
```

## Copy bootstrap skill only

```text
Copy frontend-harness-bootstrap skill from Frontend Harness Engineering (.cursor/skills/ or agents/skills/) into this repo, then run bootstrap Phase A–E. Say which AI tools you use in intake.
```
