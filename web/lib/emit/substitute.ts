export function substituteTokens(
  content: string,
  map: Record<string, string>,
  multiline?: Record<string, string>,
): string {
  let out = content.replace(/\r/g, "");
  for (const [key, val] of Object.entries(map)) {
    let value = val;
    if (value === "__MULTILINE_FILE__" && multiline?.HARNESS_PATHS) {
      value = multiline.HARNESS_PATHS;
    }
    if (value === "__MULTILINE_SHELL__" && multiline?.SHELL_CONVENTIONS_BLOCK) {
      value = multiline.SHELL_CONVENTIONS_BLOCK;
    }
    value = value.replace(/\\n/g, "\n");
    const token = `{{${key}}}`;
    out = out.split(token).join(value);
  }
  if (out.length > 0 && !out.endsWith("\n")) out += "\n";
  return out;
}

export function stripMdcFrontmatter(content: string): string {
  const lines = content.replace(/\r/g, "").split("\n");
  if (lines[0] !== "---") return content;
  let dashes = 0;
  const body: string[] = [];
  for (const line of lines) {
    if (line === "---" && dashes < 2) {
      dashes++;
      continue;
    }
    if (dashes >= 2) body.push(line);
  }
  return body.join("\n");
}
