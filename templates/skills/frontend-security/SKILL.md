---
name: frontend-security
description: Applies this repo's frontend security rules for secrets, env vars, auth, and client/server boundaries. Use for login flows, API keys, env configuration, cookies/sessions, or any security-sensitive UI or API change.
disable-model-invocation: true
---

# Frontend security

## Secrets and environment

- Only **`.env.example`** (or documented samples) belong in git—not `.env`, `.env.local`, or production values.
- Server-only values stay in server env or secrets manager; never import them into `"use client"` modules.
- Client-safe vars use prefix **`{{PUBLIC_ENV_PREFIX}}`** only (e.g. public API base URLs, feature flags).
- If a secret may have leaked, tell the user to rotate it—do not commit fixes that leave the old value in history.

## Auth (this project)

- Stack: **{{AUTH_STACK}}**
- Reuse existing login/session helpers under `{{API_CLIENT_PATH}}`—do not invent parallel auth.
- Cookie-based auth: use `SameSite`, `Secure`, and `httpOnly` where applicable; note CSRF for mutating cookie sessions.
- OAuth/OIDC: redirect URIs and client IDs from env; never embed client secrets in the browser.

## Client vs server

- Default: fetch and mutate privileged data on the server (RSC, server actions, API routes, BFF).
- Do not pass non-serializable or secret-bearing objects to client children.
- For Vite: only `{{PUBLIC_ENV_PREFIX}}*` in client code; for Next: `NEXT_PUBLIC_*` vs server-only env.

## Dangerous patterns (avoid)

- `eval`, dynamic `Function`, unsanitized `dangerouslySetInnerHTML`
- Loading third-party scripts without user approval
- Disabling certificate checks or security headers
- New auth/crypto npm packages without aligning with the team's stack

## Automated checks (not exhaustive)

- Cursor **stop** hook `scan-secrets` scans **git-changed** files for high-confidence literals (`sk_live_`, `AKIA…`, private key blocks, obvious hardcoded `password`/`api_key` assignments).
- `validate-target-harness` flags tracked `.env` files and secret-like literals in harness docs.
- These catch common agent mistakes—not a replacement for **Gitleaks**, secret scanning in CI, or security review.

## Related skills

- `data-fetching` — API clients, cookies, privileged calls
- `forms-validation` — login/signup forms (no passwords in logs or client debug output)
