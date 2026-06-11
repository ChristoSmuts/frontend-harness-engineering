import { describe, expect, test } from "bun:test";
import { substituteTokens } from "./substitute";

describe("substituteTokens", () => {
  test("replaces placeholders", () => {
    const out = substituteTokens("Hello {{NAME}}", { NAME: "World" });
    expect(out).toBe("Hello World\n");
  });

  test("expands multiline blocks", () => {
    const out = substituteTokens("{{HARNESS_PATHS}}", { HARNESS_PATHS: "__MULTILINE_FILE__" }, {
      HARNESS_PATHS: "- line one\n- line two\n",
    });
    expect(out).toContain("- line one");
  });
});
