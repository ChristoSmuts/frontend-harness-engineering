---
name: nuxt
description: Implements pages, layouts, and server/client boundaries in Nuxt. Use when adding pages, layouts, composables, or when the user mentions Nuxt.
disable-model-invocation: true
---

# Nuxt

## Paths

- Pages/routes: `{{ROUTES_PATH}}`
- Components: `{{COMPONENTS_PATH}}`

## Conventions

- Match Nuxt version (2 vs 3) and directory layout already in the repo.
- Use `definePageMeta`, `useAsyncData`, and server routes only when the project already does.
- Keep auto-import conventions; do not duplicate composables that Nuxt provides.

## Files to avoid editing

{{FORBIDDEN_PATHS}}
