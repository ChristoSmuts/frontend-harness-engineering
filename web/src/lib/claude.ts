import Anthropic from "@anthropic-ai/sdk";

export interface ProjectData {
  files: Array<{ name: string; content: string }>;
  description: string;
  rawText: string;
}

export interface HarnessFile {
  name: string;
  content: string;
  description: string;
  type: "AI-generated" | "From skills.sh" | "Default included";
  supportBadges: string[];
  installs?: number;
  url?: string;
}

export interface AnalysisResult {
  stack: {
    framework?: string;
    uiLibrary?: string;
    styling?: string;
    testing?: string;
    backend?: string;
    auth?: string;
    db?: string;
    projectType?: string;
  };
  harnessFiles: HarnessFile[];
}

const SYSTEM_PROMPT = `You are HarnessForge AI, a senior software architect specializing in AI agent orchestration.
Your task is to analyze a project's tech stack and generate a comprehensive harness: rules, skills, and memory files that constrain and guide AI coding agents (like Cursor, Cline, Copilot) to produce correct, safe, and idiomatic output for that specific project.

### HARNESS CATEGORIES
- Frontend/UI (components, patterns)
- Design System (Tailwind, shadcn, etc.)
- Security (auth, data handling)
- Backend (API, DB, ORM)
- Testing & Accessibility

### OUTPUT FORMAT
You must respond with a JSON object containing:
1. "stack": Summary of detected technologies.
2. "harnessFiles": An array of file objects. Each file should have:
   - "name": Path/name (e.g., ".cursor/rules", "agent-skills/ui-patterns.md")
   - "content": Full markdown or config content.
   - "description": Plain-English explanation of what it constrains/enables.
   - "supportBadges": List of tools that support it (e.g., ["Cursor", "Cline", "Copilot"]).
   - "type": Always "AI-generated" for your files.

### QUALITY GUIDELINES
- Reference ACTUAL libraries detected.
- Call out known footguns for the detected stack.
- Enforce project conventions.
- Use direct, imperative senior-briefing prose.
- Be precise. No generic boilerplate.

Return ONLY the JSON object. No other text.`;

export async function analyzeProject(
  data: ProjectData,
  apiKey: string,
  onUpdate?: (partialResult: Partial<AnalysisResult>) => void
): Promise<AnalysisResult> {
  const anthropic = new Anthropic({
    apiKey,
    dangerouslyAllowBrowser: true,
  });

  const prompt = `Analyze this project and generate a harness.

MANIFEST FILES:
${data.files.map((f) => `--- ${f.name} ---\n${f.content}`).join("\n\n")}

PROJECT DESCRIPTION:
${data.description}

ADDITIONAL CONTEXT/CODE:
${data.rawText}

GENERATE THE HARNESS JSON:`;

  let fullContent = "";

  const stream = anthropic.messages.stream({
    model: "claude-sonnet-4-20250514",
    max_tokens: 4000,
    system: SYSTEM_PROMPT,
    messages: [{ role: "user", content: prompt }],
  });

  for await (const event of stream) {
    if (event.type === "content_block_delta" && event.delta.type === "text_delta") {
      fullContent += event.delta.text;
    }
  }

  try {
    const jsonMatch = fullContent.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      return JSON.parse(jsonMatch[0]) as AnalysisResult;
    }
    throw new Error("No valid JSON found in response");
  } catch (e) {
    console.error("Failed to parse Claude response:", fullContent);
    throw new Error("Failed to analyze project. Please try again.");
  }
}
