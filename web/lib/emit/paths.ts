import path from "node:path";

export function assetsRoot(): string {
  return path.join(process.cwd(), "lib", "emit", "assets");
}

export function templatePath(rel: string): string {
  return path.join(assetsRoot(), rel.startsWith("templates/") ? rel : `templates/${rel}`);
}
