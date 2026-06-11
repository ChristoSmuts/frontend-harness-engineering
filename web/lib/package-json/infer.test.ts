import { describe, expect, test } from "bun:test";
import { inferFromPackageJson } from "./infer";

describe("inferFromPackageJson", () => {
  test("infers Next.js project fields", () => {
    const pkg = JSON.stringify({
      name: "acme-web",
      packageManager: "bun@1.3.0",
      dependencies: { next: "^15.0.0", react: "^19.0.0" },
      devDependencies: { "@biomejs/biome": "^1.9.0", typescript: "^5.0.0" },
      scripts: { lint: "biome check --write ." },
    });
    const { values, inferred } = inferFromPackageJson(pkg);
    expect(values.project_name).toBe("acme-web");
    expect(values.framework).toContain("Next.js");
    expect(values.package_manager).toBe("bun");
    expect(inferred).toContain("project_name");
    expect(inferred).toContain("framework");
  });

  test("returns empty on invalid JSON", () => {
    const result = inferFromPackageJson("not json");
    expect(result.inferred).toEqual([]);
  });
});
