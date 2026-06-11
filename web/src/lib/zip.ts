import JSZip from "jszip";
import { HarnessFile } from "./claude";

export async function generateHarnessZip(files: HarnessFile[]): Promise<Blob> {
  const zip = new JSZip();

  files.forEach((file) => {
    // Harness files might have paths (e.g. .cursor/rules), jszip handles folders
    zip.file(file.name, file.content);
  });

  return await zip.generateAsync({ type: "blob" });
}

export function downloadBlob(blob: Blob, filename: string) {
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(url);
}
