import archiver from "archiver";
import { PassThrough } from "node:stream";

export async function createZipBuffer(files: Map<string, string>): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    const passthrough = new PassThrough();
    const chunks: Buffer[] = [];
    passthrough.on("data", (chunk: Buffer) => chunks.push(chunk));
    passthrough.on("end", () => resolve(Buffer.concat(chunks)));
    passthrough.on("error", reject);

    const archive = archiver("zip", { zlib: { level: 9 } });
    archive.on("error", reject);
    archive.pipe(passthrough);

    for (const [rel, content] of files) {
      archive.append(content, { name: rel });
    }
    archive.finalize();
  });
}
