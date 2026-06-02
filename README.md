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

Clone the repo, then copy the `ai-newsletter` folder into your Claude Code skills directory.

**macOS / Linux** (bash / zsh):

```bash
git clone <this-repo-url> ai-newsletter-skill
cd ai-newsletter-skill
mkdir -p ~/.claude/skills
cp -r ai-newsletter ~/.claude/skills/
```

**Windows** (PowerShell):

```powershell
git clone <this-repo-url> ai-newsletter-skill
cd ai-newsletter-skill
if (-not (Test-Path $env:USERPROFILE\.claude\skills)) { New-Item -ItemType Directory -Path $env:USERPROFILE\.claude\skills | Out-Null }
Copy-Item -Recurse ai-newsletter $env:USERPROFILE\.claude\skills\
```

Then **fully quit and reopen Claude Code** so the new session scans the skills directory. The skill is then available in any project on your machine.

### Prerequisites

- **Claude Code** installed and signed in
- **Python 3.8+** on PATH (the skill calls `python3` on macOS/Linux, `python` on Windows). Verify with `python3 --version` (macOS/Linux) or `python --version` (Windows).

To verify it loaded, ask Claude in a fresh session: *"list my available skills"* — `ai-newsletter` should appear.

## Run it

### Option A — Interactive (any OS)

In any Claude Code session, just say one of:

- *"run my AI newsletter"*
- *"give me this week's AI digest"*
- *"what's new in AI this week"*
- *"use the ai-newsletter skill"*

Output lands in your current project folder as `ai-newsletter-YYYY-MM-DD.md` and `.html`. Open the `.html` in any browser.

### Option B — One-click (Windows)

There's a Windows batch file at [`windows/Run AI Newsletter.bat`](windows/Run%20AI%20Newsletter.bat) that runs the whole thing headlessly and auto-opens the HTML in your browser when done. Useful when your org policy blocks `/schedule` or you just want a desktop shortcut.

**Install:**

```powershell
# Copy the batch to your Desktop (handles OneDrive Desktop redirection)
$desktop = [Environment]::GetFolderPath('Desktop')
Copy-Item .\windows\"Run AI Newsletter.bat" "$desktop\"
```

**Use:** Double-click `Run AI Newsletter.bat` on your desktop. It opens a console window, runs the skill (~5 min), then opens this week's newsletter in your default browser. Output saves to your real `Documents\AI Newsletter\` folder (correctly handles OneDrive-redirected Documents — common on enterprise machines).

**What it does under the hood:**

1. Auto-detects the latest installed Claude Code version (resilient to self-updates)
2. Uses `[Environment]::GetFolderPath('MyDocuments')` to find your real Documents folder, not the literal `%USERPROFILE%\Documents` (which is wrong on OneDrive-managed laptops)
3. Runs `claude -p` with a tight tool whitelist (`WebFetch WebSearch Read Write Bash Glob Grep Edit`) — no shell-of-shells access
4. Adds `~/.claude/skills/ai-newsletter` as a trusted directory so the bundled Python renderer can run
5. Opens today's HTML file (or the most recent if today's somehow isn't there)

If anything fails, the console pauses with a clear error message instead of disappearing.

### Option C — Schedule it (Windows)

To get a Monday-morning newsletter without lifting a finger, combine Option B with Windows Task Scheduler:

1. Win+R → `taskschd.msc` → Enter
2. Action → Create Basic Task
3. Name: `Weekly AI Newsletter`. Trigger: Weekly, Monday, 8:00 AM
4. Action: Start a program → Browse to `Run AI Newsletter.bat` on your desktop
5. Finish

Caveat: your laptop must be powered on at 8am Monday (or the task runs at next login).

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
