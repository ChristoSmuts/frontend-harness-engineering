---
name: data-fetching
description: Implements data fetching, caching, and API error/loading UI using this project's patterns (fetch, TanStack Query, tRPC, server actions). Use when wiring APIs, hooks, loaders, or cache invalidation.
disable-model-invocation: true
---

# Data fetching

## Source of truth

- API client / hooks location: `{{API_CLIENT_PATH}}`
- Pattern: **{{DATA_FETCHING_PATTERN}}**

## Conventions

- Reuse existing client helpers and types—do not duplicate fetch wrappers.
- Surface loading and error states consistently with existing UI (skeletons, toasts, error boundaries).
- Invalidate queries / revalidate per framework rules after mutations.

## Types

- Prefer generated or shared types from `{{TYPES_PATH}}` when available.

## Security

- No secrets in client bundles; use server routes or BFF for privileged calls.
- Load skill **`frontend-security`** for auth, env, or API key work.
- Cookie/session auth: use `httpOnly`/`Secure` where applicable; consider CSRF on mutating requests.
