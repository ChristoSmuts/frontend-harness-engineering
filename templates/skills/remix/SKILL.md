---
name: remix
description: Implements routes, loaders, actions, and nested routing in Remix. Use when adding routes, loaders/actions, forms, or when the user mentions Remix.
disable-model-invocation: true
---

# Remix

## Paths

- App routes: `{{ROUTES_PATH}}`
- Components: `{{COMPONENTS_PATH}}`

## Conventions

- Colocate `loader`, `action`, and route modules per existing repo patterns.
- Use `Form` / `useFetcher` when the repo already does; match error boundaries in sibling routes.
- Do not mix server-only imports into client route modules.

## Data

- `{{DATA_FETCHING_PATTERN}}` — follow existing loaders and client caches.

## Files to avoid editing

{{FORBIDDEN_PATHS}}
