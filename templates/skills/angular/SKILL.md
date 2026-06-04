---
name: angular
description: Implements Angular components, modules or standalone APIs, and RxJS patterns in this repo. Use when editing .component.ts files, routes, or when the user mentions Angular.
disable-model-invocation: true
---

# Angular

## Paths

- App root: `{{ROUTES_PATH}}` (often `src/app`)
- Shared UI: `{{COMPONENTS_PATH}}`

## Conventions

- Prefer standalone components when the repo already uses them.
- Use existing services and `HttpClient` patterns; do not introduce a second HTTP layer.
- Keep change detection strategy consistent with neighboring components.

## Do not edit

{{FORBIDDEN_PATHS}}
