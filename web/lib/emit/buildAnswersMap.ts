import fs from "node:fs";
import path from "node:path";
import type { IntakeAnswers } from "@/lib/intake/types";
import { assetsRoot } from "./paths";

function toolSelected(answers: IntakeAnswers, needle: string): boolean {
  return answers.tools_in_use.some((t) => new RegExp(needle, "i").test(t));
}

function featureEnabled(answers: IntakeAnswers, key: string): boolean {
  const features = answers.features ?? {};
  if (key === "harness_self_improve") {
    return (features as Record<string, boolean | undefined>).harness_self_improve !== false;
  }
  return Boolean((features as Record<string, boolean | undefined>)[key]);
}

export function buildHarnessPathsBlock(answers: IntakeAnswers): string {
  const { emit_strategy, harness_owner, canonical_skills_dir, delivery_mode } = answers;
  const agentOnly = delivery_mode === "agent-only";
  const lines: string[] = [];

  if (agentOnly) {
    lines.push(
      `- **Emit strategy:** ${emit_strategy} · **Delivery:** agent-only · **Harness owner:** ${harness_owner}`,
    );
    lines.push(
      emit_strategy === "full"
        ? `- **Canonical skills:** \`${canonical_skills_dir}\` — edit here; mirrors pre-copied at emit`
        : `- **Canonical skills:** \`${canonical_skills_dir}\` — edit skills in place`,
    );
    lines.push("- **Shared entry:** `AGENTS.md` (this file)");
  } else {
    lines.push(
      `- **Emit strategy:** ${emit_strategy} · **Harness owner:** ${harness_owner} · **Platform primary:** ${answers.platform_primary}`,
    );
    lines.push(`- **Canonical skills:** \`${canonical_skills_dir}\``);
    lines.push("- **Harness scripts:** `.agent-scripts/` — validate/sync");
    lines.push("- **Shared entry:** `AGENTS.md` (this file)");
  }

  const hasCursor = toolSelected(answers, "cursor");
  const hasClaude = toolSelected(answers, "claude");
  const hasCodex = toolSelected(answers, "codex");
  const hasGemini = toolSelected(answers, "gemini");

  if (emit_strategy === "cursor-only") {
    lines.push("- **Orchestration:** `.cursor/ORCHESTRATION.md`");
    lines.push(
      agentOnly
        ? `- **Cursor:** rules \`.cursor/rules/\`, skills \`${canonical_skills_dir}\``
        : `- **Cursor:** rules \`.cursor/rules/\`, hooks \`.cursor/hooks.json\`, skills \`${canonical_skills_dir}\``,
    );
  } else {
    if (hasCursor) {
      lines.push("- **Orchestration:** `agents/ORCHESTRATION.md` · Cursor: `.cursor/ORCHESTRATION.md`");
      lines.push(
        agentOnly
          ? "- **Cursor:** rules `.cursor/rules/`, skills `.cursor/skills/` (mirror)"
          : "- **Cursor:** rules `.cursor/rules/`, skills `.cursor/skills/` (mirror), hooks `.cursor/hooks.json`",
      );
    } else {
      lines.push("- **Orchestration:** `agents/ORCHESTRATION.md`");
    }
    if (hasClaude) lines.push("- **Claude Code:** `CLAUDE.md`, rules `.claude/rules/`, skills `.claude/skills/` (mirror)");
    if (hasCodex) lines.push(`- **Codex CLI:** skills \`${canonical_skills_dir}\` (canonical)`);
    if (hasGemini) lines.push(`- **Gemini CLI:** skills \`${canonical_skills_dir}\` (canonical)`);
  }

  return lines.join("\n") + "\n";
}

function buildShellConventionsBlock(answers: IntakeAnswers): string {
  if (answers.delivery_mode === "agent-only") {
    const p = path.join(assetsRoot(), "templates/fragments/SHELL_CONVENTIONS.agent-only.md");
    if (fs.existsSync(p)) return fs.readFileSync(p, "utf8").trim();
    return "follow project shell conventions; run lint/typecheck commands in this file before claiming done";
  }
  const platform = answers.platform_primary === "windows" ? "windows" : "unix";
  const fragment = path.join(assetsRoot(), `templates/fragments/SHELL_CONVENTIONS.${platform}.md`);
  const fallback = path.join(assetsRoot(), "templates/fragments/SHELL_CONVENTIONS.unix.md");
  const file = fs.existsSync(fragment) ? fragment : fallback;
  return fs.readFileSync(file, "utf8").replace(/\{\{HARNESS_SCRIPTS_DIR\}\}/g, ".agent-scripts");
}

function buildShellAgentsLine(answers: IntakeAnswers): string {
  if (answers.delivery_mode === "agent-only") {
    return "follow project shell conventions; run lint/typecheck commands in this file before claiming done";
  }
  const platform = answers.platform_primary;
  const emit = answers.emit_strategy;
  if (toolSelected(answers, "cursor") && emit !== "portable-only") {
    return platform === "windows"
      ? "use PowerShell 7 syntax for Shell commands — see Cursor rule `shell-conventions`"
      : "use bash/sh syntax for Shell commands — see Cursor rule `shell-conventions`";
  }
  return platform === "windows" ? "use PowerShell 7 syntax for Shell commands" : "use bash/sh syntax for Shell commands";
}

function publicEnvPrefix(answers: IntakeAnswers): string {
  if (answers.public_env_prefix) return answers.public_env_prefix;
  const fw = answers.framework.toLowerCase();
  if (/next|remix|nuxt|sveltekit|astro/.test(fw)) return "NEXT_PUBLIC_";
  if (/vite|vue/.test(fw)) return "VITE_";
  return "NEXT_PUBLIC_";
}

export function buildAnswersMap(answers: IntakeAnswers, toolkitSha: string): {
  map: Record<string, string>;
  multiline: Record<string, string>;
} {
  const agentOnly = answers.delivery_mode === "agent-only";
  const harnessPaths = buildHarnessPathsBlock(answers);
  const shellBlock = buildShellConventionsBlock(answers);

  let cursorHarnessLine = "";
  if (!agentOnly && toolSelected(answers, "cursor") && answers.emit_strategy !== "portable-only") {
    cursorHarnessLine =
      "- **Cursor:** on stop, hooks run verify scripts; fix all reported errors before finishing";
  }

  let harnessValidateBlock = "";
  if (!agentOnly) {
    harnessValidateBlock =
      "- **Validate harness:** `bash .agent-scripts/validate-target-harness.sh` (Linux/macOS) or `pwsh -File .agent-scripts/validate-target-harness.ps1` (Windows); use `--strict` in CI";
  }

  const map: Record<string, string> = {};
  for (const [k, v] of Object.entries(answers)) {
    if (v !== null && typeof v !== "object") {
      map[k.toUpperCase()] = String(v);
    }
  }

  map.UNIT_TEST_SINGLE_CMD =
    answers.unit_test_single_cmd ?? "N/A — no unit test runner configured";
  map.EMIT_STRATEGY = answers.emit_strategy;
  map.CANONICAL_SKILLS_DIR = answers.canonical_skills_dir;
  map.SKILLS_DIR = answers.canonical_skills_dir;
  map.HARNESS_SCRIPTS_DIR = ".agent-scripts";
  map.PLATFORM_PRIMARY = answers.platform_primary;
  map.TOOLKIT_SHA = toolkitSha;
  map.BOOTSTRAP_DATE = answers.bootstrap_date ?? new Date().toISOString().slice(0, 10);
  map.FRAMEWORK = answers.framework;
  map.CURSOR_HARNESS_LINE = cursorHarnessLine;
  map.HARNESS_VALIDATE_BLOCK = harnessValidateBlock;
  map.DELIVERY_MODE = answers.delivery_mode;
  map.PUBLIC_ENV_PREFIX = publicEnvPrefix(answers);
  map.AUTH_STACK = answers.auth_stack ?? "none (follow existing patterns)";
  map.SHELL_AGENTS_LINE = buildShellAgentsLine(answers);
  map.COMPONENTS_JSON_PATH = "components.json";
  map.TOKENS_PATH = "src/app/globals.css";
  map.SHADCN_ADD_CMD = "pnpm dlx shadcn@latest add";
  map.PATH_ALIAS = "@/";
  map.UI_RULE_GLOBS = "**/components/**, **/app/**";
  map.UI_LIBRARY_SPECIFIC_RULES = "- Use existing primitives before adding new UI patterns.";
  map.CODEX_HOOKS_BLOCK = "# Codex hooks disabled in agent-only delivery";

  const multiline = {
    HARNESS_PATHS: harnessPaths,
    SHELL_CONVENTIONS_BLOCK: shellBlock,
  };

  map.HARNESS_PATHS = "__MULTILINE_FILE__";
  map.SHELL_CONVENTIONS_BLOCK = "__MULTILINE_SHELL__";

  return { map, multiline };
}

export { toolSelected, featureEnabled };
