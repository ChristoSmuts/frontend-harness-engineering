# Frontend security harness

How the toolkit reduces common agent security mistakes in bootstrapped frontend repos.

## What ships on bootstrap (P1)

| Artifact | Purpose |
|----------|---------|
| Rule `frontend-security` | Always-on bullets: no secrets in source, env prefixes, auth boundaries, agent-runtime exfil policy |
| Skill `frontend-security` | Depth for auth, env, cookies, dangerous APIs, MCP/hook policy, automated checks |
| `scripts/lib/secret-patterns.*` | Shared patterns for validate + hooks |
| Hook `scan-secrets` (Cursor, default on) | `stop` hook; scans **git-changed** files for high-confidence literals |
| Hook `deny-dangerous` (Cursor, default on) | `beforeShellExecution`; blocks destructive ops, env reads, outbound shell unless allowlisted |

Portable-only / Claude paths get the **rule + skill**; Cursor also gets hooks when `features.secret_scan_hook` is not `false`.

## Optional agent security hardening (P2)

Enable at intake with `"features": { "agent_security_hardening": true }`:

| Artifact | Purpose |
|----------|---------|
| `.agents/harness/allowed-domains.txt` | Domains allowed for shell outbound (`curl`, `wget`, etc.) |
| `.agents/harness/mcp-allowlist.json` | MCP server ids allowed for agent tool calls |
| Hook `deny-unapproved-mcp` | `beforeMCPExecution`; blocks MCP calls to servers not on the allowlist |
| `validate-target-harness` integrity checks | Hook path confinement, suspicious patterns in harness hooks/rules |

Pair with `"features": { "gitleaks_ci": true }` for CI secret scanning on every push/PR.

## Agent-runtime threat model

| Threat | P1 coverage | P2 / org mitigations |
|--------|-------------|----------------------|
| Secrets committed to git | `scan-secrets` stop hook, `frontend-security` rule | `gitleaks_ci` workflow |
| Agent runs destructive shell | `deny-dangerous` | Harness PR review |
| Agent `curl`s secrets to unknown host | `deny-dangerous` blocks outbound shell unless host is in `allowed-domains.txt` | Egress firewall, Cursor org policies |
| Agent reads `.env` via shell | `deny-dangerous` blocks `cat .env` / `type .env` patterns | Secret manager, not local `.env` on agent machines |
| Agent exfil via MCP tools | `frontend-security` policy bullets | `agent_security_hardening` + `deny-unapproved-mcp` hook + Cursor MCP allowlists |
| Malicious `.cursor/hooks.json` or hook scripts | `validate-target-harness` path confinement + suspicious-pattern scan | `harness_owner` PR review; treat hook changes as security-sensitive |
| Prompt injection in issues/comments | `frontend-security` — untrusted instructions vs repo rules | Human review; do not paste untrusted content into agent context |
| Dependency CVEs | Not in harness | Dependabot, npm audit, SCA in CI |

Repo harness **cannot** replace product-level controls: Cursor admin MCP restrictions, extension allowlists, and network policies remain essential for MCP exfiltration.

## What automated checks catch

- Stripe-like `sk_live_` / `sk_test_` literals
- AWS access key id prefix `AKIA…`
- PEM private key blocks
- Obvious hardcoded `password = "…"` / `api_key = "…"` assignments (8+ chars)
- Tracked `.env` files in git
- Hook scripts referenced from outside `.cursor/hooks/` or `scripts/`
- Suspicious outbound tooling in harness hook scripts (on `--strict` or with `agent_security_hardening`)

## What they do not catch

- Secrets only in unchanged files (until CI Gitleaks runs)
- Encoded/obfuscated values
- Legitimate test fixtures that match patterns (rare; adjust or opt out)
- Live MCP/HTTP traffic after a hook is bypassed or disabled
- Organization-level threats when hardening features are off

Use **Gitleaks** or GitHub secret scanning in CI for production assurance.

## Opt out

Intake / `answers.json`:

```json
"features": {
  "secret_scan_hook": false,
  "shell_guard": false,
  "agent_security_hardening": false,
  "gitleaks_ci": false
}
```

Teams on slow machines or noisy false positives can disable individual hooks while keeping the rule and skill.

## Intake fields

| Field | Example |
|-------|---------|
| `public_env_prefix` | `NEXT_PUBLIC_`, `VITE_` |
| `auth_stack` | `NextAuth`, `Clerk`, `none (follow existing patterns)` |
| `features.secret_scan_hook` | `true` (default) |
| `features.shell_guard` | `true` (default) |
| `features.agent_security_hardening` | `false` (default); MCP hook + allowlists + strict integrity |
| `features.gitleaks_ci` | `false` (default); `.github/workflows/secret-scan.yml` |
| `mcp_allowlist` | `["plugin-figma-figma"]` — used when `agent_security_hardening` is true |
| `mcp_policy` | Orchestration text; minimal MCP, disable after use |

Emitter infers `public_env_prefix` from `framework` when omitted.

## Maintainer upgrades

When upgrading the toolkit copy in a target repo:

1. Diff `templates/rules/frontend-security.mdc.template` and `templates/skills/frontend-security/`.
2. Merge into target harness files; run `.agent-scripts/sync-skills.sh` on `full` emit.
3. Re-copy `scripts/lib/secret-patterns.*`, `shell-guard.*`, `harness-integrity.*`, and hook scripts from toolkit.
4. Run `validate-target-harness.sh --strict`.

## MCP hook (`beforeMCPExecution`)

Cursor supports `beforeMCPExecution` hooks (schema version 1). When `agent_security_hardening` is enabled, emit adds `deny-unapproved-mcp` to `.cursor/hooks.json` with `failClosed: true`.

The hook reads MCP server id fields from stdin JSON (`server`, `mcpServer`, `serverName`) and allows only ids listed in `mcp-allowlist.json`. Exit code `2` blocks the MCP call.

Org-level Cursor MCP allowlists remain the primary control; the repo hook is defense in depth for compromised agent sessions.

## See also

- [TEAM_GOVERNANCE.md](TEAM_GOVERNANCE.md) — harness PR ownership, security-sensitive hook review
- [HARNESS_GROWTH.md](HARNESS_GROWTH.md) — failure-driven harness changes
- [PLACEHOLDERS.md](PLACEHOLDERS.md) — `{{PUBLIC_ENV_PREFIX}}`, `{{AUTH_STACK}}`
- [EMIT_FROM_INTAKE.md](EMIT_FROM_INTAKE.md) — feature flags
