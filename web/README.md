# Frontend Harness Generator (web)

Next.js questionnaire that emits an **agent-only** harness zip. Deployed from the `web/` directory on Vercel.

## Local development

```bash
cd web
bun install
bun run dev
```

`prebuild` / `dev` copies `../templates`, `../manifest/emit-manifest.json`, and `../intake/answers.schema.json` into `lib/emit/assets/`.

## Vercel

Set **Root Directory** to `web` in project settings (or use the repo `vercel.json` with root `web`).

## API

- `POST /api/preview` — JSON intake answers → `{ paths: string[] }`
- `POST /api/generate` — JSON intake answers → zip download

Both force `delivery_mode: agent-only`.
