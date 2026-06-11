export function buildHarnessNextSteps(projectName: string): string {
  return `# ${projectName} — harness next steps

You downloaded an **agent-only** harness (no shell scripts, hooks, or CI workflows).

## Install in your repo

1. Extract the zip at your frontend project root (same level as \`package.json\`).
2. Commit the new files with your team for review.
3. Open the project in your coding agent — \`AGENTS.md\` is the entry point.

## Security

- Review \`frontend-security\` rule/skill before auth or API work.
- Never commit secrets; use env prefixes documented in \`AGENTS.md\`.
- Optional hardening (MCP allowlists, domain allowlists): see the toolkit [FRONTEND_SECURITY](https://github.com/frontend-harness-engineering) docs if you adopt \`standard\` delivery later.

## Self-improving the harness

- With \`harness-self-improve\` skill included, repeat agent failures can be logged to \`.agents/harness/failure-ledger.json\` (or \`.cursor/harness/\` for cursor-only).
- After the same mistake twice, apply minimal fixes to canonical skills and update mirrors by hand (or add toolkit \`sync-skills\` scripts later).

## Growing the harness manually

- Add skills under your canonical skills directory when agents repeatedly miss stack-specific patterns.
- Keep \`AGENTS.md\` thin; put depth in skills loaded only when relevant.

## Optional automation (standard delivery)

From the [Frontend Harness Engineering](https://github.com/frontend-harness-engineering) toolkit you can later add:

- \`.agent-scripts/\` — validate and sync skill mirrors
- Cursor stop hooks — lint/typecheck on agent stop
- \`.github/workflows/harness-validate.yml\` — CI parity checks

Re-run bootstrap or \`emit-from-intake.sh\` with \`"delivery_mode": "standard"\` when your team is ready.
`;
}
