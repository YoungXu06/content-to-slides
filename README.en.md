# Content to Slides

> Turn an article, a video link, or a GitHub repo into a **landscape 4:3 5–10 page explainer deck + PDF + per-slide speaker script** in one shot, with **5 built-in theme templates** auto-matched to your content.

An open-source **Skill** for AI-agent environments (Claude Code / Codex / CodeBuddy). Fully self-contained — generates single-file clickable HTML slides, exports a pixel-consistent PDF, and writes a professional per-slide speaker script plus a social media post.

[中文说明](./README.md) · [Contributing](./CONTRIBUTING.md) · [LICENSE](./LICENSE)

---

## What problem it solves

Long content (articles, videos, repos) is information-dense yet **hard to save, archive, and share** — you forget it after reading, and it's too long to forward.

This skill turns it into a **save / archive / share-ready short-video asset pack**:

- **Archivable offline**: a single-file HTML + standard PDF, ready to store, no network service required.
- **Instantly shareable**: every page of the 1440×1080 PDF is a ready-made image — drop in chats, knowledge bases, or re-edit freely.
- **One step to a video**: read the per-slide speaker script aloud to record a short video, pair it with the social post, and publish to TikTok / YouTube / Bilibili / Xiaohongshu. Want to skip recording entirely? Hand the HTML/PDF + script to the sister project [**PPTalker**](https://github.com/YoungXu06/pptalker-skill) to auto-add AI voiceover + subtitles and render a finished video.

In one line: **turn "read-and-forget" long content into a "record-one-take-and-post" video asset.**

---

## What you get

One invocation, three ready-to-use deliverables:

| File | Description |
|------|-------------|
| `presentation.html` | Landscape 4:3 HTML slides (5 themes to choose from), single file, click to flip pages |
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
- Formal reports bound to a corporate VI template (this skill is a short-video explainer style; all 5 themes are highly readable refined dark palettes)
- Content longer than 10 pages (5–10 page hard constraint by design)

---

## Design principles

1. **Capture the essence, not the wording** — answer "what is this really about" in one sentence first.
2. **5–10 page hard limit** — fewer than 5 has no substance, more than 10 isn't short-video pacing.
3. **The script must sound like a real expert** — a practitioner explaining one thing to a knowledgeable friend.
4. **Self-contained HTML** — 15 built-in components + 5 distinct theme templates, no external skill dependency.
5. **Landscape 4:3 + large readable text + click-to-flip** — all sizes in vw/vh units so HTML and PDF match exactly; no visible buttons.
6. **Chinese-first** — slides and script default to Chinese (proper nouns stay English); opt into English on request.

---

## Install

This skill is a plain file structure (`SKILL.md` + `references/` + `scripts/`). Drop the directory into your agent's skills search path.

```bash
# Claude Code
git clone https://github.com/YoungXu06/content-to-slides.git \
  ~/.claude/skills/content-to-slides

# CodeBuddy
git clone https://github.com/YoungXu06/content-to-slides.git \
  ~/.codebuddy/skills/content-to-slides
```

The bundled scripts auto-discover the skill directory under
`~/.claude/skills`, `~/.codebuddy/skills`, `~/.config/skills`.

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
│   ├── themes.md                     # 5 theme template presets (palette / fonts / mood)
│   └── voice.md                      # Speaker-script tone rules + banned words
└── scripts/                          # Executable tools
    ├── export-pdf.sh                 # PDF export (1440×1080 4:3)
    ├── fetch-youtube-transcript.sh   # Auto YouTube transcript download
    ├── fetch-github-repo.sh          # Auto GitHub repo analysis
    └── parse_transcript.py           # Subtitle parsing (VTT/SRT → plain text)
```

---

## Theme templates

**5 built-in theme templates**, each with its own palette, font pairing, and mood, **auto-matched** to the content mood (override explicitly in your request):

| Theme | Mood | Palette | Fonts | Best for |
|-------|------|---------|-------|----------|
| **Deep Ocean** | Professional / analytical / trustworthy | Steel blue + sage | Inter + Noto Sans SC | Sci, tech, papers, AI / data |
| **Midnight Gold** | Elegant / contemplative / authoritative | Antique gold + lavender | Playfair Display + Noto Serif SC | Philosophy, mindset, strategy, psychology |
| **Electric Dark** | Bold / modern / provocative | Indigo + rose gray | Space Grotesk + Noto Sans SC | Trends, hot takes, business, hot topics |
| **Forest Night** | Calm / organic / grounded | Pine green + mint | DM Sans + Noto Sans SC | Nature, wellness, sustainability, mindfulness |
| **Warm Dusk** | Warm / intimate / narrative | Terracotta + amber | Source Serif 4 + Noto Sans SC | Culture, history, humanities, personal essays |

> All 5 themes use a highly readable refined dark background (optimized for short-video framing), but differ in color, typography, and mood — covering everything from rational tech to humanistic storytelling. Full CSS variables in [references/themes.md](./references/themes.md).

---

## Related project: turn slides into a narrated video 🔗

This project **produces slides from scratch**; to make those slides actually "speak", hand off to the sister project [**PPTalker**](https://github.com/YoungXu06/pptalker-skill):

```
   one link / one article / one repo
              │
   content-to-slides (this project)  ──►  HTML / PDF deck  +  per-slide script (script.md)
              │
   PPTalker                          ──►  narrated video with AI voiceover + subtitles
              │
        publish to TikTok / YouTube / Bilibili / Xiaohongshu / archive
```

[**PPTalker**](https://github.com/YoungXu06/pptalker-skill) takes this project's `presentation.html` / `output.pdf` directly as input, and the `script.md` can be reused as the per-slide notes — no screen recording, no lip-sync. It auto-adds AI voiceover and synced subtitles and renders a finished video, together forming a complete "content → slides → narrated video" pipeline.

---

## License

[AGPL-3.0](./LICENSE) © Content to Slides contributors
