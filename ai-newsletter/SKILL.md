---
name: ai-newsletter
description: Generate a personalized weekly AI newsletter — a TL;DR roundup of the most important AI news, launches, and commentary from the past 7 days. Aggregates from a fixed set of newsletters (The Rundown AI, Ben's Bites, AI Breakfast, Morning Brew AI), YouTube voices (Matt Wolfe, All-In Podcast), and LinkedIn thought leaders (Andrew Ng, Sam Altman, Andrej Karpathy), then writes a styled HTML file the user can read like a real newsletter. Use this skill whenever the user asks for an "AI newsletter", "weekly AI digest", "Monday AI roundup", "what's new in AI this week", "AI news summary", "catch me up on AI", their personal AI brief, or any variant — even casual phrasings like "give me the AI rundown". Also trigger when a scheduled/cron task invokes the slash command `/ai-newsletter` or similar phrasing.
---

# AI Newsletter Skill

Generate a personalized weekly AI newsletter for the user, covering the last 7 days. Output is a styled HTML file (plus a markdown source) saved to the project root.

## Sources

The user has curated this exact list — don't add or drop sources without being asked.

**Newsletters** (scrape their public web archives — most publish on the web):
- The Rundown AI — `https://www.therundown.ai/`
- Ben's Bites — `https://bensbites.com/` (and `https://bensbites.beehiiv.com/`)
- AI Breakfast — `https://aibreakfast.beehiiv.com/`
- Morning Brew (AI Edition) — `https://www.morningbrew.com/daily/issues` (filter for AI/Emerging Tech coverage)

**YouTube channels** (use web search to find recent videos; YouTube doesn't expose transcripts without auth, so summarize from titles + descriptions + any web coverage):
- Matt Wolfe — `https://www.youtube.com/@mreflow`
- All-In Podcast — `https://www.youtube.com/@allin`

**LinkedIn voices** (LinkedIn requires auth, so use web search for press/quotes/reshares — phrases like `"Andrew Ng" LinkedIn post site:linkedin.com OR site:x.com` work well):
- Andrew Ng
- Sam Altman
- Andrej Karpathy

## Procedure

Follow these steps in order. The whole run typically takes 5–10 minutes depending on how aggressively you parallelize web fetches.

### 1. Establish the window

Compute the 7-day window ending today. Use this exact format in your search queries: `"last 7 days"`, `"past week"`, or include the explicit date range. Store both bounds as `YYYY-MM-DD` — you'll need them for the filename and the newsletter header.

### 2. Fetch in parallel

Spawn parallel WebFetch and WebSearch calls — one batch per source category. **Do not** do these sequentially; that wastes 5+ minutes of wall time.

For each source, the goal is: 3–5 bullet points of substantive content from the last week. If a source is gated, returns nothing relevant, or errors out, **note that source as unavailable in the final output and keep going**. Never let one dead source block the rest.

Suggested queries:
- Newsletters: WebFetch the archive URL directly, then pick the most recent issue(s) within the window.
- YouTube: `WebSearch "Matt Wolfe" AI video site:youtube.com {date range}` and similar for All-In.
- LinkedIn voices: `WebSearch "Andrew Ng" AI {date range}` — supplement with Twitter/X mirrors since LinkedIn HTML is auth-walled.

### 3. Synthesize, don't just stitch

Read what you gathered. Identify:
- **The 3–5 biggest stories of the week** — events that multiple sources covered, or single events with clearly large impact (a major model release, a regulatory shift, a notable acquisition).
- **Notable launches / tools** — anything the user could actually try this week.
- **Commentary worth highlighting** — strong takes from the three LinkedIn voices, or thesis statements from the All-In crew.

Avoid filler. If a "story" amounts to "X company announced they're thinking about Y", cut it. The user is busy; respect that.

### 4. Write the markdown source

Save to `ai-newsletter-{end-date}.md` at the project root. Use this exact structure:

```markdown
# Your AI Weekly — {Mon DD, YYYY}

*Covering {start-date} → {end-date}*

## TL;DR
- bullet 1
- bullet 2
- ... (5–7 bullets total — the things that actually matter)

## Top Stories This Week
### {Story title}
2–3 sentences. Why it matters. [Source link](url).

(repeat for 3–5 stories)

## From Your Newsletters
**The Rundown AI** — top items this week, with links.
**Ben's Bites** — top items this week, with links.
**AI Breakfast** — top items this week, with links.
**Morning Brew (AI)** — top items this week, with links.

(For any unavailable source, write: `_Couldn't reach this week — will try again next run._`)

## From YouTube
**Matt Wolfe** — most-watched / most-relevant video, 2 sentences on the takeaway. [Link].
**All-In Podcast** — same.

## From the LinkedIn Voices
**Andrew Ng** — notable post/quote/thread. 1–2 sentences.
**Sam Altman** — same.
**Andrej Karpathy** — same.

## Tools & Launches Worth a Look
- Tool name — one-sentence pitch. [Link]
- ...

---
*Generated {timestamp}. Sources: see links above.*
```

### 5. Render the HTML

Use the bundled renderer — don't roll your own conversion. The interpreter command differs by OS, so try whichever fits:

```bash
# macOS / Linux
python3 {skill-dir}/scripts/render_html.py \
    ai-newsletter-{end-date}.md \
    {skill-dir}/assets/newsletter.html.template \
    ai-newsletter-{end-date}.html

# Windows
python {skill-dir}/scripts/render_html.py ai-newsletter-{end-date}.md {skill-dir}/assets/newsletter.html.template ai-newsletter-{end-date}.html
```

If the first attempt errors with "command not found", fall back to the other (`python` ↔ `python3`). The script needs only the Python standard library (`re`, `sys`, `pathlib`) — no pip deps. It handles the markdown subset this skill produces (headers, bullets, bold, italic, links, hr, paragraphs). If you need a feature it doesn't support (tables, code blocks), extend the script rather than reaching for a pip dependency — keeps the skill self-contained.

### 6. Tell the user where the file is

End the run with a short message: which file, the date range covered, and a one-line headline preview of the TL;DR. That's it — don't summarize the whole newsletter in chat; the file is the deliverable.

## Tone & Style

Write like a smart friend catching the user up over coffee, not like a press release. Short sentences. Strong verbs. Skip throat-clearing ("It's worth noting that..."). Numbers and proper nouns are great; vague hype-phrases ("revolutionary breakthrough", "game-changer") are not — replace them with what actually happened.

The user is technically literate and works in consulting/strategy. They want signal: who launched what, what changed in the policy landscape, what the people they follow are actually saying. Assume they already know what GPT and LLMs are.

## Resilience

- If web search returns nothing useful for a source, write `_Couldn't reach this week — will try again next run._` for that section and move on. Don't fabricate.
- If you can't determine a precise publication date for a source's most recent content, prefer including it (with a note) over omitting it — staleness is better than a dead section.
- If the HTML conversion fails, still save the `.md` — the markdown is the source of truth.

## Files in this skill

- `SKILL.md` — this file
- `assets/newsletter.html.template` — HTML wrapper for the rendered newsletter
- `scripts/render_html.py` — markdown → HTML renderer using the template
