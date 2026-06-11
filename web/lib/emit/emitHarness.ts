import fs from "node:fs";
import path from "node:path";
import type { IntakeAnswers } from "@/lib/intake/types";
import { assetsRoot, templatePath } from "./paths";
import { buildAnswersMap, toolSelected, featureEnabled } from "./buildAnswersMap";
import { selectSkills } from "./selectSkills";
import { substituteTokens, stripMdcFrontmatter } from "./substitute";
import { buildHarnessNextSteps } from "./nextSteps";

function readTemplate(rel: string): string {
  const p = rel.startsWith("templates/") ? path.join(assetsRoot(), rel) : templatePath(rel);
  return fs.readFileSync(p, "utf8");
}

function emitSubstitute(
  files: Map<string, string>,
  templateRel: string,
  dest: string,
  map: Record<string, string>,
  multiline: Record<string, string>,
): void {
  const content = substituteTokens(readTemplate(templateRel), map, multiline);
  files.set(dest.replace(/\\/g, "/"), content);
}

function copyLiteral(files: Map<string, string>, srcRel: string, dest: string): void {
  const rel = srcRel.startsWith("templates/") ? srcRel : `templates/${srcRel}`;
  const p = path.join(assetsRoot(), rel);
  files.set(dest, fs.readFileSync(p, "utf8"));
}

function mirrorSkills(
  files: Map<string, string>,
  canonicalPrefix: string,
  mirrorPrefix: string,
): void {
  for (const [rel] of files) {
    if (rel.startsWith(canonicalPrefix) && rel.endsWith("/SKILL.md")) {
      const name = rel.split("/").slice(-2, -1)[0];
      const mirrorRel = `${mirrorPrefix}${name}/SKILL.md`;
      files.set(mirrorRel, files.get(rel)!);
    }
  }
}

export function emitHarness(answers: IntakeAnswers): Map<string, string> {
  const files = new Map<string, string>();
  const shaPath = path.join(assetsRoot(), "toolkit-sha.txt");
  const toolkitSha = fs.existsSync(shaPath)
    ? fs.readFileSync(shaPath, "utf8").trim()
    : "web";
  const { map, multiline } = buildAnswersMap(
    { ...answers, toolkit_sha: toolkitSha },
    toolkitSha,
  );

  const emitStrategy = answers.emit_strategy;
  const agentOnly = answers.delivery_mode === "agent-only";
  const canonical =
    emitStrategy === "cursor-only" ? ".cursor/skills/" : answers.canonical_skills_dir;

  emitSubstitute(files, "AGENTS.md.template", "AGENTS.md", map, multiline);
  emitSubstitute(files, "HARNESS_CHANGELOG.md.template", "HARNESS_CHANGELOG.md", map, multiline);

  if (emitStrategy !== "cursor-only") {
    emitSubstitute(
      files,
      "ORCHESTRATION.shared.md.template",
      "agents/ORCHESTRATION.md",
      map,
      multiline,
    );
  }

  if (featureEnabled(answers, "harness_self_improve")) {
    const ledgerDest =
      emitStrategy === "cursor-only"
        ? ".cursor/harness/failure-ledger.json"
        : ".agents/harness/failure-ledger.json";
    emitSubstitute(
      files,
      "harness/failure-ledger.json.template",
      ledgerDest,
      map,
      multiline,
    );
  }

  if (toolSelected(answers, "cursor") && emitStrategy !== "portable-only") {
    if (emitStrategy === "cursor-only") {
      emitSubstitute(
        files,
        "ORCHESTRATION.shared.md.template",
        ".cursor/ORCHESTRATION.md",
        map,
        multiline,
      );
    } else if (files.has("agents/ORCHESTRATION.md")) {
      files.set(".cursor/ORCHESTRATION.md", files.get("agents/ORCHESTRATION.md")!);
    }
  }

  if (toolSelected(answers, "claude") && (emitStrategy === "full" || emitStrategy === "portable-only")) {
    emitSubstitute(files, "CLAUDE.md.template", "CLAUDE.md", map, multiline);
  }

  if (toolSelected(answers, "gemini")) {
    emitSubstitute(files, "GEMINI.md.template", "GEMINI.md", map, multiline);
  }

  if (featureEnabled(answers, "agent_security_hardening")) {
    const harnessDir = emitStrategy === "cursor-only" ? ".cursor/harness" : ".agents/harness";
    copyLiteral(files, "templates/harness/allowed-domains.txt.template", `${harnessDir}/allowed-domains.txt`);
    if (answers.mcp_allowlist?.length) {
      files.set(`${harnessDir}/mcp-allowlist.json`, JSON.stringify(answers.mcp_allowlist, null, 2) + "\n");
    } else {
      copyLiteral(files, "templates/harness/mcp-allowlist.json.template", `${harnessDir}/mcp-allowlist.json`);
    }
  }

  if (toolSelected(answers, "cursor") && emitStrategy !== "portable-only") {
    for (const rule of [
      "frontend-core",
      "frontend-security",
      "shell-conventions",
      "typescript-react",
      "ui-components",
    ]) {
      emitSubstitute(
        files,
        `rules/${rule}.mdc.template`,
        `.cursor/rules/${rule}.mdc`,
        map,
        multiline,
      );
    }
  }

  if (toolSelected(answers, "claude") && (emitStrategy === "full" || emitStrategy === "portable-only")) {
    for (const rule of [
      "frontend-core",
      "frontend-security",
      "shell-conventions",
      "typescript-react",
      "ui-components",
    ]) {
      const raw = substituteTokens(
        stripMdcFrontmatter(readTemplate(`rules/${rule}.mdc.template`)),
        map,
        multiline,
      );
      files.set(`.claude/rules/${rule}.md`, raw);
    }
    if (files.has("agents/ORCHESTRATION.md")) {
      files.set(".claude/ORCHESTRATION.md", files.get("agents/ORCHESTRATION.md")!);
    }
  }

  const skills = selectSkills(answers);
  const canonicalPrefix = canonical.replace(/\/$/, "") + "/";
  for (const skill of skills) {
    const dest = `${canonicalPrefix}${skill.name}/SKILL.md`;
    emitSubstitute(files, skill.template.replace(/^templates\//, ""), dest, map, multiline);
  }

  if (emitStrategy === "full" && agentOnly) {
    if (toolSelected(answers, "cursor")) {
      mirrorSkills(files, canonicalPrefix, ".cursor/skills/");
    }
    if (toolSelected(answers, "claude")) {
      mirrorSkills(files, canonicalPrefix, ".claude/skills/");
    }
  }

  files.set("HARNESS_NEXT_STEPS.md", buildHarnessNextSteps(answers.project_name));

  return files;
}

export function previewFilePaths(answers: IntakeAnswers): string[] {
  return [...emitHarness(answers).keys()].sort();
}
