# Scheduled Agent Prompt — Weekly AI Newsletter

Paste this into `/schedule` once the claude.ai connection is working again.

## Settings

- **Name:** Weekly AI Newsletter
- **Cron:** `0 8 * * 1`  (Monday, 8:00 AM)
- **Timezone:** `America/New_York`

## Prompt body (paste verbatim)

```
Generate this week's personalized AI newsletter for me, covering the past 7 days from today.

SOURCES (use exactly these — do not substitute):
- Newsletters (WebFetch the public archives): The Rundown AI (therundown.ai), Ben's Bites (bensbites.com / bensbites.beehiiv.com), AI Breakfast (aibreakfast.beehiiv.com), Morning Brew AI Edition (morningbrew.com)
- YouTube (WebSearch): Matt Wolfe (@mreflow), All-In Podcast (@allin)
- LinkedIn voices (WebSearch — LinkedIn proper is auth-walled, so use press coverage / X mirrors): Andrew Ng, Sam Altman, Andrej Karpathy

PROCEDURE:
1. Compute the 7-day window ending today as YYYY-MM-DD bounds.
2. Fire all source WebFetch / WebSearch calls IN PARALLEL — never sequentially.
3. If a source is unreachable, note "Couldn't reach this week" and continue. Never fabricate.
4. Synthesize into the structure below. Cut filler — no "X company announced they're thinking about Y".

OUTPUT STRUCTURE (markdown):
# Your AI Weekly — {Mon DD, YYYY}
*Covering {start} → {end}*

## TL;DR
- 5–7 bullets, the things that actually matter this week

## Top Stories This Week
### {Story title}
2–3 sentences. Why it matters. [Source](url).
(repeat 3–5 times)

## From Your Newsletters
**The Rundown AI** — top items, with links.
**Ben's Bites** — top items, with links.
**AI Breakfast** — top items, with links.
**Morning Brew (AI)** — top items, with links.

## From YouTube
**Matt Wolfe** — most-relevant video + 2-sentence takeaway. [Link]
**All-In Podcast** — same.

## From the LinkedIn Voices
**Andrew Ng** — notable post/quote. 1–2 sentences.
**Sam Altman** — same.
**Andrej Karpathy** — same.

## Tools & Launches Worth a Look
- Bullet list, one line each, with links.

TONE: Smart-friend-over-coffee. Short sentences, strong verbs, concrete numbers/names. No hype-phrases ("game-changer", "revolutionary"). Assume baseline AI literacy — I work in consulting/strategy and follow the field closely.

DELIVERY: Reply with (1) the 5–7 bullet TL;DR inline at the top so I can read it on my phone, then (2) the full rendered newsletter body underneath in markdown.
```
