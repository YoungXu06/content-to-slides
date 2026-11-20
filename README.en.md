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

The agent will automatically: fetch source and load rules → build a shared page plan → generate narration and HTML once → export PDF once → deliver directly.

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
3. **Objective, natural, non-preachy narration** — explain facts in complete spoken sentences. The negation-then-redefinition family ("not A but B", "what X really is, is Y") is capped at one use per script; everywhere else, state the fact directly. Skip hype packaging ("counterintuitively", "what's worse is"). Remove tangents, not subjects, conditions or causal connections.
4. **Written for TTS, with natural continuity** — slides and narration share a page plan following the listener's understanding. Allow useful pronouns and connective words; no pronoun quotas, rigid short-sentence limits or mandatory hooks on every slide.
5. **Plan first, generate once, deliver on success** — decide content, capacity and spoken forms before writing. Generate HTML and script once and export PDF once. No artifact rereading, banned-word scans, screenshot review or rewrite loops. Report execution failures honestly instead of regenerating automatically.
6. **Self-contained HTML** — 15 built-in components + 5 distinct theme templates, no external skill dependency.
7. **Landscape 4:3 + large readable text + click-to-flip** — all sizes in vw/vh units so HTML and PDF match exactly; no visible buttons.
8. **Chinese-first** — slides and script default to Chinese (proper nouns stay English); opt into English on request.

---

## Install

This skill is a plain file structure (`SKILL.md` + `references/` + `scripts/`). Drop the directory into your agent's skills search path.

```bash
# Codex
git clone https://github.com/YoungXu06/content-to-slides.git \
  ~/.codex/skills/content-to-slides

# Claude Code
git clone https://github.com/YoungXu06/content-to-slides.git \
  ~/.claude/skills/content-to-slides

# CodeBuddy
git clone https://github.com/YoungXu06/content-to-slides.git \
  ~/.codebuddy/skills/content-to-slides
```

> The directory name is up to you, but it must contain `SKILL.md`. Update with
> `git -C <dir> pull`.

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
Phase 2   Fetch source, load rules, understand content
Phase 3   Build a shared page plan (content, narration, components, capacity)
Phase 3.5 Confirm once before generation and lock the plan
Phase 4   Generate narration, social post and HTML from the shared plan
Phase 5   Export PDF once
Phase 7   Deliver directly
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
│   └── voice.md                      # Writing contract + AI-tics blacklist + objectivity + continuity
└── scripts/                          # Executable tools
    ├── export-pdf.sh                 # PDF export (1440×1080 4:3)
    ├── fetch-youtube-transcript.sh   # Auto YouTube transcript download
    ├── fetch-github-repo.sh          # Auto GitHub repo analysis
    ├── parse_transcript.py           # Subtitle parsing (VTT/SRT → plain text)
    └── check_voice.py                # Audit template phrasing (not in the default flow)
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

## Component library

15 built-in 4:3 components: Title Slide, Content Slide, Card Grid, VS Comparison, Metric Display, Info Box, Quote Block, Key Insight, Closing Slide, Step Flow, Split Text, Icon List, Highlight Banner, Formula Slide, Formula + Explanation.

Hard layout rule: never run more than 2 consecutive pages of the same component, and use at least 5 different components for decks of 8+ pages. Details in [references/slide-design.md](./references/slide-design.md).

---

## Example requests

```
Turn this article into an explainer deck + script: https://example.com/some-article
Build a 5-10 page explainer for practitioners: <link>
Turn the essence of this video into a short-video script: https://youtu.be/xxxxxxxxxxx
Make a project overview deck for this repo: https://github.com/owner/repo
```

---

## FAQ

**Q: The PDF text is too small / differs from the HTML.**
A: Check for fixed `px` or `clamp()` — everything must use `vw` units. `export-pdf.sh` renders at a fixed 1440×1080.

**Q: No transcript found for the video.**
A: Confirm subtitles are enabled on the video; installing `deno` improves `yt-dlp` success. If it still fails, copy the text from the video's "show transcript" panel and paste it to the agent.

**Q: Can it output English?**
A: Yes — say "output in English" in your request. Chinese is the default.

More failure modes and fixes are in the "Common Failure Modes" table at the end of [SKILL.md](./SKILL.md).

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

After this skill finishes, tell your agent:

```
Make a video from content-to-slides-output/<project>/presentation.html,
using script.md in the same folder as the notes, Chinese voiceover
```

You get back the PPTalker watch page. It is private by default — only you can
watch it while signed in. To share, publish the video from that page.

---

## License

[AGPL-3.0](./LICENSE) © Content to Slides contributors
