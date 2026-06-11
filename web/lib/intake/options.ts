export const PACKAGE_MANAGER_OPTIONS = ["pnpm", "npm", "yarn", "bun"] as const;

export const FRAMEWORK_OPTIONS = [
  "Next.js 15 App Router",
  "Next.js 14 App Router",
  "Vite + React",
  "Remix",
  "Nuxt 3",
  "SvelteKit",
  "Astro",
  "Vue + Vite",
  "Angular",
  "React Native",
  "Expo",
] as const;

export const STYLING_OPTIONS = [
  "Tailwind CSS",
  "Tailwind",
  "CSS Modules",
  "Styled Components",
  "Emotion",
  "Sass / SCSS",
  "Vanilla CSS",
  "UnoCSS",
] as const;

export const UI_LIBRARY_OPTIONS = [
  "shadcn/ui",
  "Radix UI",
  "MUI",
  "Chakra UI",
  "Ant Design",
  "Headless UI",
  "Mantine",
  "None",
] as const;

export const TOOL_OPTIONS = [
  "Cursor",
  "Claude Code",
  "Codex CLI",
  "Gemini CLI",
  "other",
] as const;

export const EMIT_STRATEGY_OPTIONS = [
  { value: "full", label: "Full — rules for every tool you use" },
  { value: "portable-only", label: "Portable — CLI agents and shared skills only" },
  { value: "cursor-only", label: "Cursor — Cursor-specific rules and skills" },
] as const;

export const FORBIDDEN_PATH_OPTIONS = [
  ".next",
  "dist",
  "node_modules",
  "build",
  ".turbo",
  "coverage",
  ".vercel",
] as const;

/** Split comma-separated intake strings into chip values (strips optional backticks). */
export function splitDelimited(value: string | undefined): string[] {
  if (!value?.trim()) return [];
  return value
    .split(/,\s*/)
    .map((part) => part.replace(/^`+|`+$/g, "").trim())
    .filter(Boolean);
}

/** Join chip values for string intake fields. */
export function joinDelimited(values: string[]): string {
  return values.join(", ");
}

/** Format path tokens the way the harness expects (backtick-wrapped). */
export function joinForbiddenPaths(values: string[]): string {
  return values.map((v) => `\`${v.replace(/^`+|`+$/g, "")}\``).join(", ");
}
