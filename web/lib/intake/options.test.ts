import { describe, expect, test } from "bun:test";
import { joinDelimited, joinForbiddenPaths, splitDelimited } from "./options";

describe("splitDelimited", () => {
  test("splits comma-separated values", () => {
    expect(splitDelimited("Tailwind, CSS Modules")).toEqual(["Tailwind", "CSS Modules"]);
  });

  test("strips backticks from path tokens", () => {
    expect(splitDelimited("`.next`, `dist`, `node_modules`")).toEqual([
      ".next",
      "dist",
      "node_modules",
    ]);
  });
});

describe("joinDelimited", () => {
  test("joins values for intake strings", () => {
    expect(joinDelimited(["Next.js 15 App Router", "Vite + React"])).toBe(
      "Next.js 15 App Router, Vite + React",
    );
  });
});

describe("joinForbiddenPaths", () => {
  test("wraps paths in backticks", () => {
    expect(joinForbiddenPaths([".next", "dist"])).toBe("`.next`, `dist`");
  });
});
