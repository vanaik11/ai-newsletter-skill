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

### Windows — one-click installer (recommended for colleagues)

Download [`windows/Setup AI Newsletter.bat`](windows/Setup%20AI%20Newsletter.bat), save it anywhere (Desktop is fine), and **double-click it**. The setup script will:

1. Confirm Claude Code is installed on your machine
2. Download the latest skill from this repo
3. Install it to `~/.claude/skills/ai-newsletter/`
4. Drop an `AI Newsletter.bat` launcher on your Desktop

When it finishes, **fully quit Claude Code** (system tray icon → Quit — *not* just close the window), then double-click the new `AI Newsletter.bat` on your Desktop. Type the trigger phrase when Claude opens. Done. See [Run it](#run-it) below.

Safe to re-run the setup any time to update the skill to the latest version from GitHub.

### Manual install (any OS — clone the repo)

If you'd rather see what's happening or you're on macOS / Linux:

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

### Option A — Interactive (any OS, recommended)

In any Claude Code session, say one of:

- *"run my AI newsletter, then open the HTML when done"*
- *"give me this week's AI digest"*
- *"what's new in AI this week"*
- *"use the ai-newsletter skill"*

Output lands in your current project folder as `ai-newsletter-YYYY-MM-DD.md` and `.html`. Adding *"then open the HTML when done"* asks the agent to launch your default browser at the end — handy on Windows/Mac.

Takes ~5 minutes end-to-end (parallel web fetches across your sources).

### Option B — Windows Desktop launcher

A double-click batch at [`windows/AI Newsletter.bat`](windows/AI%20Newsletter.bat) opens Claude Code in your `Documents\AI Newsletter\` folder. You then type the trigger phrase and walk away. This is the "polished manual" workflow — one extra phrase to type, but zero auth complexity.

**Install:**

```powershell
$desktop = [Environment]::GetFolderPath('Desktop')
Copy-Item .\windows\"AI Newsletter.bat" "$desktop\"
```

**Use:** Double-click `AI Newsletter.bat` on your desktop. Claude Code opens in the right folder. Type `run my AI newsletter, then open the HTML when done`. Walk away. Comes back to a newsletter in your browser.

**What it handles for you:**

- Finds the latest installed Claude Code version (resilient to self-updates)
- Resolves your *real* Documents folder via `[Environment]::GetFolderPath('MyDocuments')` — works correctly on OneDrive-redirected enterprise laptops where `%USERPROFILE%\Documents` is the wrong path
- Drops you into Claude Code with the correct working directory so output files land where you'd expect

### Option C — Fully headless / scheduled (advanced)

Running this fully unattended (no human typing the trigger phrase) requires either:

1. **An Anthropic API key** at [console.anthropic.com](https://console.anthropic.com) (~$1–2/month at weekly usage). The batch can then call `claude -p --bare` with `ANTHROPIC_API_KEY` set as an env var. Useful if you want Windows Task Scheduler to fire it Monday morning while you're still in bed.
2. **`/schedule`** (Claude's scheduled remote agents) — only works if your org permits it. Many enterprise installs have `allow_workflows: false` in `policy-limits.json` which blocks this path.

For most personal use, Option A or B is fine and free. Only reach for Option C if you genuinely want zero-touch Monday delivery and are OK with API billing.

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

## Troubleshooting

The four issues colleagues have actually hit, with fixes.

### Skill doesn't appear in Claude Code

You opened Claude Code before the skill was installed. Fully **quit and reopen** (system tray → Quit on Windows, ⌘Q on macOS — not just close the window). Confirm with: *"list my available skills"* — `ai-newsletter` should appear.

If a restart doesn't fix it, fall back to the manual PowerShell launch below.

### "Not logged in" error from the batch launcher

You're hitting headless mode (`claude -p`), which requires an Anthropic API key on Windows — OAuth tokens don't reach child processes. Use the interactive launcher (Option B above) or the manual PowerShell launch below instead. Both use your existing Claude Code subscription with no API key.

### A newsletter source returned nothing this week

Expected and safe. The skill notes the source as "unavailable" in the output and continues — it never fakes content. If a source stays flaky for two weeks running, edit `SKILL.md` and swap in an alternative.

### LinkedIn coverage feels thin

LinkedIn proper is auth-walled, so the skill uses web search for press coverage and X mirrors. For deeper coverage, add the person's X handle as an additional source in `SKILL.md`.

## Fallback: launch Claude Code manually from PowerShell

If the desktop launcher misbehaves or the skill doesn't appear after a restart, do it by hand. Open PowerShell and paste:

```powershell
# 1. Find the latest installed Claude Code (resilient to updates)
$ver = Get-ChildItem "$env:APPDATA\Claude\claude-code" -Directory `
    | Sort-Object Name -Descending | Select-Object -First 1
$claude = "$env:APPDATA\Claude\claude-code\$($ver.Name)\claude.exe"

# 2. Open it in your newsletter folder (creates if missing)
$outdir = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "AI Newsletter"
if (-not (Test-Path $outdir)) { New-Item -ItemType Directory -Path $outdir | Out-Null }
Set-Location $outdir
& $claude
```

3. **Sign in if Claude prompts you** — at the Claude prompt type `/login` and complete the browser flow. You stay signed in for the session.
4. **Run the skill** — type `run my AI newsletter, then open the HTML when done`. If the natural-language trigger doesn't fire, try `use the ai-newsletter skill`.

If `SKILL.md` isn't at `~/.claude/skills/ai-newsletter/`, you skipped install step 2 — go back and run the `Copy-Item`.

## Reduce permission prompts (optional)

Claude Code prompts before each tool use by default. To pre-authorize the tools this skill needs, add to `~/.claude/settings.json`:

```json
"permissions": {
  "allow": ["WebFetch", "WebSearch", "Read", "Write", "Edit", "Bash", "Glob", "Grep"]
}
```

After this, runs proceed silently — no per-tool prompts. Org-level policies (`policy-limits.json`) still override, so this only affects user-controlled permissions.

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
