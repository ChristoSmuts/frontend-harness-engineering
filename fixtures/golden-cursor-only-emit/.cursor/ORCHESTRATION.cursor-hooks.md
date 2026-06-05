## Hooks (Cursor)

Configured in `.cursor/hooks.json`:

- **stop:** `verify-frontend` — format/lint + typecheck; success is silent
- **stop:** `scan-secrets` — scans git-changed files for high-confidence secret literals (if enabled)
- **beforeShellExecution:** `deny-dangerous` — blocks migrations, prod deploy, destructive git/shell, `.env` reads, and outbound requests to hosts not in `allowed-domains.txt` (if enabled)
- **beforeMCPExecution:** `deny-unapproved-mcp` — blocks MCP servers not listed in `mcp-allowlist.json` (if `agent_security_hardening` enabled at bootstrap)

Other tools: use skill `frontend-verify` or commands in `AGENTS.md` before claiming done.
