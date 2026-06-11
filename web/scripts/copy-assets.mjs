import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const webRoot = path.join(__dirname, "..");
const toolkitRoot = path.join(webRoot, "..");
const dest = path.join(webRoot, "lib", "emit", "assets");

function copyRecursive(src, dst) {
  if (!fs.existsSync(src)) return;
  fs.mkdirSync(dst, { recursive: true });
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const from = path.join(src, entry.name);
    const to = path.join(dst, entry.name);
    if (entry.isDirectory()) copyRecursive(from, to);
    else fs.copyFileSync(from, to);
  }
}

fs.rmSync(dest, { recursive: true, force: true });
fs.mkdirSync(dest, { recursive: true });
copyRecursive(path.join(toolkitRoot, "templates"), path.join(dest, "templates"));
fs.copyFileSync(
  path.join(toolkitRoot, "manifest", "emit-manifest.json"),
  path.join(dest, "emit-manifest.json"),
);
fs.copyFileSync(
  path.join(toolkitRoot, "intake", "answers.schema.json"),
  path.join(dest, "answers.schema.json"),
);

let toolkitSha = "unknown";
try {
  const { execSync } = await import("node:child_process");
  toolkitSha = execSync("git rev-parse --short HEAD", {
    cwd: toolkitRoot,
    encoding: "utf8",
  }).trim();
} catch {
  /* optional */
}
fs.writeFileSync(path.join(dest, "toolkit-sha.txt"), toolkitSha);
console.log(`Copied emit assets to ${dest} (sha=${toolkitSha})`);
