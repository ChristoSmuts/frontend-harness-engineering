import { Band } from "@/components/Band";
import { HarnessWizard } from "@/components/HarnessWizard";

export default function Home() {
  return (
    <main>
      <HarnessWizard />
      <Band tone="dark">
        <p className="max-w-[480px] text-[var(--text-body)] leading-[1.61] text-bone">
          Every download contains agent-readable files — rules, skills, and orchestration tailored
          to your stack. Drop the zip into any frontend repo and your coding agents start with the
          right context on day one.
        </p>
      </Band>
    </main>
  );
}
