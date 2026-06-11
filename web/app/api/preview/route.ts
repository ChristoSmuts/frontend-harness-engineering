import { mergeWebAnswers, intakeAnswersSchema } from "@/lib/intake/schema";
import { previewFilePaths } from "@/lib/emit/emitHarness";

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
      return Response.json({ error: "Invalid answers", paths: [] }, { status: 400 });
    }
    const answers = mergeWebAnswers(parsed.data);
    return Response.json({ paths: previewFilePaths(answers) });
  } catch {
    return Response.json({ paths: [] }, { status: 500 });
  }
}
