## Hooks (Cursor)

Configured in `.cursor/hooks.json`:

- **stop:** `verify-frontend` — format/lint + typecheck; success is silent
- **stop:** `scan-secrets` — scans git-changed files for high-confidence secret literals (if enabled)
- **beforeShellExecution:** `deny-dangerous` — blocks migrations, prod deploy, destructive git/shell (if enabled)

Other tools: use skill `frontend-verify` or commands in `AGENTS.md` before claiming done.
