# Personal AI Newsletter — a Claude Code skill

A Claude Code skill that generates a personalized weekly AI newsletter from a curated list of sources. Reads from newsletters, YouTube channels, and named LinkedIn/X voices over a 7-day window, then writes a styled HTML file you can open in your browser.

Originally built for one person's Monday-morning AI catch-up; sharing here so colleagues can fork and point it at their own sources.

## What it produces

A clean, styled HTML newsletter with:

- **TL;DR** — 5–7 bullets on what actually mattered this week
- **Top Stories** — 3–5 deep-dive items with links
- **From Your Newsletters** — digests of each subscribed source
- **From YouTube** — top videos + takeaways
- **From the Voices You Follow** — notable posts/quotes
- **Tools & Launches Worth a Look** — actionable items

Sample output runs roughly 1,500 words. Tone: smart friend over coffee, not press release.

## Install

```powershell
# Clone the repo somewhere convenient
git clone <this-repo-url> ai-newsletter-skill
cd ai-newsletter-skill

# Copy the skill folder into your personal skills directory
# (Windows path shown — adjust for macOS/Linux: ~/.claude/skills/)
Copy-Item -Recurse ai-newsletter $env:USERPROFILE\.claude\skills\
```

Restart Claude Code (fully quit and reopen). The skill is then available in any project.

To verify it loaded, ask Claude in a fresh session: *"list my available skills"* — `ai-newsletter` should appear.

## Run it

In any Claude Code session, just say one of:

- *"run my AI newsletter"*
- *"give me this week's AI digest"*
- *"what's new in AI this week"*
- *"use the ai-newsletter skill"*

Output lands in your current project folder as `ai-newsletter-YYYY-MM-DD.md` and `.html`. Open the `.html` in any browser.

Takes ~5 minutes end-to-end depending on how aggressive the parallel web fetches are.

## Customize your sources

This is the whole point of forking. Open `ai-newsletter/SKILL.md` and edit the **Sources** section. The current default list is:

- Newsletters: The Rundown AI, Ben's Bites, AI Breakfast, Morning Brew (AI Edition)
- YouTube: Matt Wolfe, All-In Podcast
- LinkedIn voices: Andrew Ng, Sam Altman, Andrej Karpathy

Swap in your own — anything Claude can reach via WebFetch or WebSearch works. Keep the schema (name + URL/handle + a one-liner on why you follow them) and the rest of the skill will adapt.

A few patterns that work well:

- For **newsletters**, link the public archive URL, not the homepage. Beehiiv and Substack archives render reliably; some publisher sites don't.
- For **YouTube**, list channels by their `@handle` so search queries are unambiguous.
- For **LinkedIn**, write the person's name; the skill uses WebSearch to find press coverage and X mirrors since LinkedIn proper is auth-walled.

## Schedule it (optional)

If your org allows `/schedule` (scheduled remote agents), the procedure is documented in `ai-newsletter/SCHEDULED_PROMPT.md` — paste that into `/schedule` for Monday 8am delivery.

If `/schedule` is blocked by org policy, alternatives:

1. **Run it manually** Monday morning — takes a coffee's worth of time
2. **Windows Task Scheduler** — set up a recurring task that launches Claude Code headlessly with the prompt
3. **Standalone script** — call the Anthropic API directly with the procedure as a prompt; no Claude Code needed

## Files

| Path | Purpose |
|---|---|
| `ai-newsletter/SKILL.md` | Skill metadata + procedure |
| `ai-newsletter/assets/newsletter.html.template` | HTML wrapper for the rendered newsletter |
| `ai-newsletter/scripts/render_html.py` | Markdown → HTML renderer |

## Contributing

PRs welcome. The two things most worth contributing back:

1. **Better source fetchers** — if you find a clean way to pull a particular newsletter archive that the default WebFetch can't read, share it. Right now Ben's Bites and Morning Brew's archive pages are flaky.
2. **YouTube transcript access** — currently we summarize from titles + descriptions because transcripts are auth-walled. If you wire up the YouTube Data API or a transcript service, that'd be a real upgrade.

## License

Internal Deloitte use. Add a formal LICENSE file before publishing externally.
