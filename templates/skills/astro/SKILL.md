---
name: astro
description: Implements pages, layouts, and islands in Astro. Use when adding routes, Astro components, client islands, or when the user mentions Astro.
disable-model-invocation: true
---

# Astro

## Paths

- Pages: `{{ROUTES_PATH}}`
- Components: `{{COMPONENTS_PATH}}`

## Conventions

- Default to static/server components; add `client:*` directives only when interactivity is required.
- Match content collections and i18n patterns if the repo uses them.
- Keep framework islands (React/Vue/Svelte) consistent with existing integration config.

## Files to avoid editing

{{FORBIDDEN_PATHS}}
