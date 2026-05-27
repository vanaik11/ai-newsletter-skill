"""Render the newsletter .md into the styled .html template.

Usage:
    python render_html.py <input.md> <template.html> <output.html>

Intentionally minimal — covers the markdown subset the skill emits
(h1/h2/h3, bold, italic, links, bullets, hr, paragraphs). Not a general
markdown parser; if the skill starts emitting tables or code blocks,
extend this rather than reaching for a dependency.
"""
import re
import sys
from pathlib import Path


def inline(text: str) -> str:
    text = text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    text = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", r'<a href="\2">\1</a>', text)
    text = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", text)
    text = re.sub(r"(?<!\*)\*([^*]+)\*(?!\*)", r"<em>\1</em>", text)
    return text


def md_to_html(md: str) -> tuple[str, str, str]:
    """Returns (title, date_range, body_html). Title and date_range are
    pulled from the first h1 and the first italic line beneath it."""
    title = ""
    date_range = ""
    body_lines: list[str] = []
    in_list = False

    lines = md.splitlines()
    i = 0
    while i < len(lines):
        line = lines[i].rstrip()

        if not title and line.startswith("# "):
            title = inline(line[2:].strip())
            i += 1
            continue

        if not date_range and line.startswith("*") and line.endswith("*") and not line.startswith("**"):
            date_range = inline(line.strip("*").strip())
            i += 1
            continue

        if line.startswith("### "):
            if in_list:
                body_lines.append("</ul>")
                in_list = False
            body_lines.append(f"<h3>{inline(line[4:].strip())}</h3>")
        elif line.startswith("## "):
            if in_list:
                body_lines.append("</ul>")
                in_list = False
            body_lines.append(f"<h2>{inline(line[3:].strip())}</h2>")
        elif line.startswith("- "):
            if not in_list:
                body_lines.append("<ul>")
                in_list = True
            body_lines.append(f"<li>{inline(line[2:].strip())}</li>")
        elif line.strip() == "---":
            if in_list:
                body_lines.append("</ul>")
                in_list = False
            body_lines.append("<hr>")
        elif line.strip() == "":
            if in_list:
                body_lines.append("</ul>")
                in_list = False
        else:
            if in_list:
                body_lines.append("</ul>")
                in_list = False
            body_lines.append(f"<p>{inline(line)}</p>")
        i += 1

    if in_list:
        body_lines.append("</ul>")

    return title, date_range, "\n".join(body_lines)


def main() -> None:
    if len(sys.argv) != 4:
        print("usage: render_html.py <input.md> <template.html> <output.html>", file=sys.stderr)
        sys.exit(2)
    md_path, tmpl_path, out_path = (Path(p) for p in sys.argv[1:])
    md = md_path.read_text(encoding="utf-8")
    tmpl = tmpl_path.read_text(encoding="utf-8")
    title, date_range, body_html = md_to_html(md)
    rendered = (
        tmpl.replace("{{TITLE}}", title or "Your AI Weekly")
        .replace("{{DATE_RANGE}}", date_range or "")
        .replace("{{BODY_HTML}}", body_html)
    )
    out_path.write_text(rendered, encoding="utf-8")
    print(f"wrote {out_path}")


if __name__ == "__main__":
    main()
