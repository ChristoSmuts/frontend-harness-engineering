---
name: next-app-router
description: Implements pages, layouts, loading and error boundaries, and RSC/client boundaries in Next.js App Router. Use when adding routes, app directory files, server actions, metadata, or when the user mentions Next.js App Router.
disable-model-invocation: true
---

# Next.js App Router

## Paths

- App directory: `src/app`
- Default layout: `src/app/layout.tsx`

## Conventions

- **Server Components by default** — add `"use client"` only when hooks, browser APIs, or event handlers require it.
- Colocate `loading.tsx`, `error.tsx`, `not-found.tsx` with route segments when the repo already does.
- Use `metadata` / `generateMetadata` for SEO on static or server pages.
- Server Actions (if used): `src/app/actions/*.ts`

## Data

- Fetch on server when possible; pass serializable props to client children.
- Do not import server-only modules into client components.
- Use `NEXT_PUBLIC_*` only for client-safe env; server secrets stay server-side (see **`frontend-security`**).

## Files to avoid editing

``.next`, `dist`, `node_modules`` (e.g. `.next`, build output)