# Content to Slides

> Turn an article, a video link, or a GitHub repo into a **landscape 4:3 dark-theme 5–10 page explainer deck + PDF + per-slide speaker script** in one shot.

An open-source **Skill** for AI-agent environments (Claude Code / Codex / CodeBuddy). Fully self-contained — generates single-file clickable HTML slides, exports a pixel-consistent PDF, and writes a professional per-slide speaker script plus a social media post.

[中文说明](./README.md) · [Contributing](./CONTRIBUTING.md) · [LICENSE](./LICENSE)

---

## What you get

One invocation, three ready-to-use deliverables:

| File | Description |
|------|-------------|
| `presentation.html` | Landscape 4:3 dark-theme HTML slides, single file, click to flip pages |
| `output.pdf` | 1440×1080 landscape 4:3 PDF, layout identical to the HTML, ready to share / record |
| `script.md` | Per-slide speaker script + social media post, professional voice, ready to record |

---

## 30-second start

After installing the skill into your agent's skills directory, just ask:

```
Turn this article into a 5-10 page explainer deck + speaker script: <article URL>
```

or:

```
Summarize this video into a deck: <YouTube / Bilibili URL>
Make a project overview deck for this repo: <github.com/owner/repo>
```

The agent will automatically: fetch content → distill the essence → design an outline → generate HTML → export PDF → write the speaker script.

---

## Good for / Not for

**Good for:**
- Turning long articles, tech blogs, papers, podcasts, videos into short-video explainer scripts
- "Project overview" decks for GitHub repos
- Workflows that need slides **and** a per-slide script delivered together

**Not for:**
- Business presentations needing complex animations / transitions
- Formal reports bound to a corporate VI template (this skill is a dark short-video style)
- Content longer than 10 pages (5–10 page hard constraint by design)

---

## Design principles

1. **Capture the essence, not the wording** — answer "what is this really about" in one sentence first.
2. **5–10 page hard limit** — fewer than 5 has no substance, more than 10 isn't short-video pacing.
3. **The script must sound like a real expert** — a practitioner explaining one thing to a knowledgeable friend.
4. **Self-contained HTML** — 15 built-in components + 5 dark themes, no external skill dependency.
5. **Landscape 4:3 + large readable text + click-to-flip** — all sizes in vw/vh units so HTML and PDF match exactly; no visible buttons.
6. **Chinese-first** — slides and script default to Chinese (proper nouns stay English); opt into English on request.

---

## Install

This skill is a plain file structure (`SKILL.md` + `references/` + `scripts/`). Drop the directory into your agent's skills search path.

```bash
# Claude Code
git clone https://github.com/<your-name>/content-to-slides.git \
  ~/.claude/skills/content-to-slides

# CodeBuddy
git clone https://github.com/<your-name>/content-to-slides.git \
  ~/.codebuddy/skills/content-to-slides
```

The bundled scripts auto-discover the skill directory under
`~/.claude/skills`, `~/.claude-internal/skills`, `~/.codebuddy/skills`, `~/.config/skills`.

---

## Dependencies

| Feature | Requires | Install | Required? |
|---------|----------|---------|-----------|
| Export PDF | Node.js + Playwright | auto-installed (slow first run) | yes, for PDF phase |
| YouTube transcript | Python3 + yt-dlp + youtube-transcript-api | auto-installed by script | only for YouTube links |
| YouTube JS challenge | deno (optional) | `brew install deno` | optional, improves success rate |
| GitHub analysis | gh CLI (preferred) / git (fallback) | `brew install gh` | only for GitHub links |

Plain text content (articles / markdown) needs no extra dependencies.

---

## Workflow

```
Phase 1   Confirm input & goal
Phase 2   Fetch & deeply understand the source
Phase 3   Design a 5–10 page outline + pick components
Phase 4   Generate HTML slides (self-contained)
Phase 5   Export PDF
Phase 6   Write per-slide speaker script
Phase 6.5 Write social media post
Phase 7   Deliver
```

See [SKILL.md](./SKILL.md) for full details.

---

## Directory structure

```
content-to-slides/
├── SKILL.md                          # Main skill file: triggers, workflow, principles, failure modes
├── README.md                         # Chinese docs
├── README.en.md                      # English docs (this file)
├── CONTRIBUTING.md                   # Contribution guide
├── LICENSE                           # AGPL-3.0
├── .gitignore
├── references/                       # Layered knowledge base (read on demand)
│   ├── ingestion.md                  # Fetch strategies & fallbacks per link type
│   ├── summarization.md              # 5-question skeleton: distill core arguments
│   ├── slide-design.md               # 4:3 component library + layout rules + HTML template
│   ├── themes.md                     # 5 dark theme presets
│   └── voice.md                      # Speaker-script tone rules + banned words
└── scripts/                          # Executable tools
    ├── export-pdf.sh                 # PDF export (1440×1080 4:3)
    ├── fetch-youtube-transcript.sh   # Auto YouTube transcript download
    ├── fetch-github-repo.sh          # Auto GitHub repo analysis
    └── parse_transcript.py           # Subtitle parsing (VTT/SRT → plain text)
```

---

## Theme presets

| Mood | Theme |
|------|-------|
| Sci / rational / technical | Deep Ocean |
| Philosophy / strategy / mindset | Midnight Gold |
| Sharp / controversial / trend | Electric Dark |
| Nature / health / sustainability | Forest Night |
| Narrative / culture / humanities | Warm Dusk |

Themes auto-match the content mood; override explicitly in your request. See [references/themes.md](./references/themes.md).

---

## License

[AGPL-3.0](./LICENSE) © Content to Slides contributors
