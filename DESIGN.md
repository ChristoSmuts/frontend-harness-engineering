# Harness Forge — Style Reference
> Architectural precision in agentic orchestration

**Theme:** Obsidian Forge

Harness Forge is built on a foundation of structural clarity and high-performance aesthetics. It uses a stark, high-contrast canvas that alternates between crisp Marble White editorial space and deep Obsidian Ink voids. Typography is oversized and architectural — a single custom display face (HelveticaNowDisplay) carries every voice, from a massive wordmark to technical body copy. A single Copper Clay accent (#bc7155) provides the only chromatic warmth, reserved for the most deliberate action moments and interactive highlights. Components are stripped to their bones: pill buttons, hairline dividers, generous white space, and almost no elevation. The experience is designed to feel like a premium engineering tool—precise, authoritative, and frictionless.

## GSAP Motion Principles
Motion in Harness Forge is not decorative; it is functional and directional.
- **Entrances:** Elements should slide in with a subtle "power4.out" ease, moving from the bottom or right to signal progress.
- **Transitions:** Step changes in the wizard use staggered reveals for content blocks to reduce cognitive load.
- **Feedback:** Micro-interactions (hover, click) use snappy, high-tension springs or "expo.out" eases.

## Tokens — Colors

| Name | Value | Token | Role |
|------|-------|-------|------|
| Obsidian Ink | `#000d10` | `--color-obsidian-ink` | Primary text, logo, borders, filled buttons, nav — a deep, structural near-black. |
| Copper Clay | `#bc7155` | `--color-copper-clay` | Accent fill for featured actions and decorative highlights. |
| Marble White | `#ffffff` | `--color-marble-white` | Primary canvas, text on dark sections. |
| Forge Slate | `#0f0f1c` | `--color-forge-slate` | Dark section backgrounds — deeper than Obsidian, providing a technical backdrop. |
| Ash Gray | `#8e8e95` | `--color-ash-gray` | Muted body text, secondary nav, hairline borders. |
| Bone | `#d5d3d4` | `--color-bone` | Warm light gray for subtle surface differentiation. |

## Tokens — Typography

### HelveticaNowDisplay
- **Substitute:** Inter (400, 700) with tight tracking
- **Weights:** 400, 700
- **Line height:** 0.80 (display), 1.10 (headings), 1.61 (body)
- **Letter spacing:** -0.02em for headings

## Components

### Harness Forge Wordmark
The 'Harness Forge' wordmark set in HelveticaNowDisplay weight 400 at 131–187px. The ® registered mark sits as a small superscript.

### Filled Pill Button
1000px border-radius, Obsidian Ink (#000d10) fill, white text, HelveticaNowDisplay weight 700.

### Hairline Fieldset
Groups related questions with a 1px Ash Gray (#8e8e95) divider.

## UX Best Practices
- **Junior-Friendly Language:** Avoid jargon where possible. Explain *why* a piece of information is needed.
- **Context First:** Always provide the "Mission Brief" before asking for technical details.
- **Dynamic Defaults:** Sensible defaults that update based on previous choices (e.g., package manager).
- **Transparency:** Show the user exactly what they are getting before they download.
- **Accessibility:** Ensure high contrast, keyboard navigability, and clear focus states.
