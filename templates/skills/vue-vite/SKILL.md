---
name: vue-vite
description: Implements Vue 3 SFCs, composables, and Vite conventions in this repo. Use when adding Vue components, routes, Pinia stores, or when the user mentions Vue or Vite without Nuxt.
disable-model-invocation: true
---

# Vue + Vite

## Paths

- Source: `{{ROUTES_PATH}}` / `src/` per project layout
- Components: `{{COMPONENTS_PATH}}`

## Conventions

- Prefer `<script setup lang="ts">` and Composition API.
- Colocate composables in `src/composables` when the repo does.
- Match existing router (vue-router) patterns before adding new navigation libraries.

## Do not edit

{{FORBIDDEN_PATHS}}
