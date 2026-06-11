import fs from "node:fs";
import path from "node:path";
import type { IntakeAnswers } from "@/lib/intake/types";
import { assetsRoot } from "./paths";
import { featureEnabled } from "./buildAnswersMap";

interface ManifestSkill {
  name: string;
  template: string;
  always?: boolean;
  feature?: string;
  framework_match?: string;
}

interface EmitManifest {
  skills: ManifestSkill[];
}

function frameworkMatches(framework: string, pattern: string): boolean {
  if (pattern === "other") return /^other$/i.test(framework);
  return new RegExp(pattern, "i").test(framework);
}

export function selectSkills(answers: IntakeAnswers): ManifestSkill[] {
  const manifestPath = path.join(assetsRoot(), "emit-manifest.json");
  const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8")) as EmitManifest;
  const selected: ManifestSkill[] = [];
  let frameworkEmitted = false;

  for (const skill of manifest.skills) {
    let include = false;
    if (skill.always) include = true;
    if (skill.feature && featureEnabled(answers, skill.feature)) include = true;
    if (skill.framework_match) {
      if (frameworkMatches(answers.framework, skill.framework_match)) {
        if (skill.framework_match !== "other") {
          if (!frameworkEmitted) {
            include = true;
            frameworkEmitted = true;
          } else {
            include = false;
          }
        } else if (!frameworkEmitted) {
          include = true;
        }
      }
    }
    if (include) selected.push(skill);
  }
  return selected;
}
