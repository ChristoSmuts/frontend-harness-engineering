---
name: sveltekit
description: Implements routes, layouts, and load functions in SvelteKit. Use when adding routes, +page/+layout files, server hooks, or when the user mentions SvelteKit.
disable-model-invocation: true
---

# SvelteKit

## Paths

- Routes: `{{ROUTES_PATH}}`
- Lib/components: `{{COMPONENTS_PATH}}`

## Conventions

- Use `+page.svelte`, `+page.server.ts`, `+layout.svelte` colocation per existing routes.
- Prefer `load` / `actions` patterns already used in the repo; respect `ssr` settings in config.
- Match existing styling (Tailwind, scoped CSS) in sibling routes.

## Files to avoid editing

{{FORBIDDEN_PATHS}}
