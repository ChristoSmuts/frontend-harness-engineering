# Frontend security harness

How the toolkit reduces common agent security mistakes in bootstrapped frontend repos.

## What ships on bootstrap (P1)

| Artifact | Purpose |
|----------|---------|
| Rule `frontend-security` | Always-on bullets: no secrets in source, env prefixes, auth boundaries |
| Skill `frontend-security` | Depth for auth, env, cookies, dangerous APIs, automated checks |
| `scripts/lib/secret-patterns.*` | Shared patterns for validate + hooks |
| Hook `scan-secrets` (Cursor, default on) | Second `stop` hook; scans **git-changed** files for high-confidence literals |

Portable-only / Claude paths get the **rule + skill**; Cursor also gets hooks when `features.secret_scan_hook` is not `false`.

## What automated checks catch

- Stripe-like `sk_live_` / `sk_test_` literals
- AWS access key id prefix `AKIA…`
- PEM private key blocks
- Obvious hardcoded `password = "…"` / `api_key = "…"` assignments (8+ chars)

## What they do not catch

- Secrets only in unchanged files
- Encoded/obfuscated values
- Legitimate test fixtures that match patterns (rare; adjust or opt out)
- Organization-level threats (MCP exfil, prompt injection, dependency CVEs)

Use **Gitleaks** or similar in CI for production assurance. See enterprise notes in harness security reviews.

## Opt out

Intake / `answers.json`:

```json
"features": { "secret_scan_hook": false }
```

Teams on slow machines or noisy false positives can disable the hook while keeping the rule and skill.

## Intake fields

| Field | Example |
|-------|---------|
| `public_env_prefix` | `NEXT_PUBLIC_`, `VITE_` |
| `auth_stack` | `NextAuth`, `Clerk`, `none (follow existing patterns)` |
| `features.secret_scan_hook` | `true` (default) |

Emitter infers `public_env_prefix` from `framework` when omitted.

## Maintainer upgrades

When upgrading the toolkit copy in a target repo:

1. Diff `templates/rules/frontend-security.mdc.template` and `templates/skills/frontend-security/`.
2. Merge into target harness files; run `scripts/sync-skills.sh` on `full` emit.
3. Re-copy `scripts/lib/secret-patterns.*` and hook scripts from toolkit.
4. Run `validate-target-harness.sh --strict`.

## See also

- [TEAM_GOVERNANCE.md](TEAM_GOVERNANCE.md) — harness PR ownership
- [HARNESS_GROWTH.md](HARNESS_GROWTH.md) — failure-driven harness changes
- [PLACEHOLDERS.md](PLACEHOLDERS.md) — `{{PUBLIC_ENV_PREFIX}}`, `{{AUTH_STACK}}`
