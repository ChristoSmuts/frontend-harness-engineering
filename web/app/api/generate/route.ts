import { mergeWebAnswers, intakeAnswersSchema } from "@/lib/intake/schema";
import { emitHarness } from "@/lib/emit/emitHarness";
import { createZipBuffer } from "@/lib/emit/createZip";

export const runtime = "nodejs";

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const parsed = intakeAnswersSchema.safeParse({
      ...body,
      delivery_mode: "agent-only",
      source: "web",
    });
    if (!parsed.success) {
      return Response.json(
        { error: "Invalid answers", details: parsed.error.flatten() },
        { status: 400 },
      );
    }
    const answers = mergeWebAnswers(parsed.data);
    const files = emitHarness(answers);
    const zip = await createZipBuffer(files);
    const slug = answers.project_name.replace(/[^a-zA-Z0-9._-]+/g, "-").toLowerCase();
    return new Response(new Uint8Array(zip), {
      headers: {
        "Content-Type": "application/zip",
        "Content-Disposition": `attachment; filename="${slug}-harness.zip"`,
      },
    });
  } catch (err) {
    console.error(err);
    return Response.json({ error: "Failed to generate harness" }, { status: 500 });
  }
}
