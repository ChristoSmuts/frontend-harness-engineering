import { expect, test, describe } from "bun:test";
import { generateHarnessZip } from "../lib/zip";
import JSZip from "jszip";

describe("Zip Generation", () => {
  test("should create a zip with correct files", async () => {
    const files = [
      {
        name: ".cursor/rules",
        content: "Rule 1",
        description: "Test description",
        type: "AI-generated" as const,
        supportBadges: ["Cursor"],
      },
      {
        name: "agent-skills/test.md",
        content: "Skill 1",
        description: "Skill description",
        type: "From skills.sh" as const,
        supportBadges: ["Universal"],
      },
    ];

    const blob = await generateHarnessZip(files);
    expect(blob).toBeInstanceOf(Blob);

    const arrayBuffer = await blob.arrayBuffer();
    const zip = await JSZip.loadAsync(arrayBuffer);
    expect(Object.keys(zip.files)).toContain(".cursor/rules");
    expect(Object.keys(zip.files)).toContain("agent-skills/test.md");

    const content = await zip.file(".cursor/rules")?.async("text");
    expect(content).toBe("Rule 1");
  });
});
