---
name: vite-react
description: Works with Vite + React structure, routing, and env conventions in this repo. Use when adding pages, routes, Vite config, or client-side React features outside Next.js.
disable-model-invocation: true
---

# Vite + React

## Paths

- Entry: `{{VITE_ENTRY}}`
- Pages/routes: `{{ROUTES_PATH}}`
- Components: `{{COMPONENTS_PATH}}`

## Conventions

- Env vars: `VITE_*` prefix only in client code; never expose secrets.
- Auth, API keys, env: load skill **`frontend-security`** before changing client or env configuration.
- Lazy-load route chunks when the repo already uses `React.lazy` + router patterns.
- Match existing router (React Router / TanStack Router / file-based) — inspect before adding routes.

## Build

```bash
{{BUILD_CMD}}
```

Do not commit `dist/` artifacts.
