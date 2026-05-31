# Landscape 4:3 Slide Design System

Design system for landscape 4:3 slides. Read [themes.md](themes.md) for color themes.

## Table of Contents

- [Design Philosophy](#design-philosophy)
- [Viewport & Layout](#viewport--layout)
- [Typography](#typography)
- [Color Rules](#color-rules)
- [Component Library](#component-library)
- [Page Number](#page-number)
- [Animations](#animations)
- [Complete HTML Template](#complete-html-template)

---

## Design Philosophy

- **Landscape 4:3** — more vertical space than 16:9, text appears proportionally larger
- **Dark backgrounds** — standard for video slides, reduces eye strain
- **Maximum text readability** — large vw-based font sizes, generous spacing
- **Rich visual hierarchy** — colored text, cards, layout variety
- **Click-to-navigate** — minimal UI, no visible buttons; click left/right halves to navigate
- **Scale-invariant** — vw/vh units ensure same proportions on any screen size and in PDF

---

## Viewport & Layout

| Property | Value |
|----------|-------|
| Aspect ratio | 4:3 (landscape) |
| PDF export | 1440×1080 |
| Compact export | 1024×768 |
| Slide padding | 5vh top/bottom, 5vw left/right |
| Content width | ~90vw |
| Orientation | Landscape only |

### 🔴 Scaling Strategy: Use vw units, NOT fixed px

All spacing, font sizes, and component dimensions use **vw (viewport-width) units**. This ensures content fills the same proportion of the screen whether rendered in a browser at any size or in Playwright at 1440px for PDF export. Fixed px values are prohibited.

Conversion reference (based on 1440px PDF canvas):
- 1vw = 14.4px on PDF canvas
- Example: `3.5vw` = 50px on PDF → proportionally identical at any viewport size

Rules:
- Each slide = full viewport height, **no scrolling within a slide**
- All styles inline in single HTML file — all units in vw/vh
- Max 2 columns for cards/metrics (3 allowed only for small number metrics)
- Single column for info boxes and text blocks
- Content must fill at least 70% of slide area — if too sparse, add detail or merge with adjacent slide
- Content must not overflow — if it does, split into two slides

---

## Typography

### Font Sizes (vw units — scale-invariant)

All font sizes in vw so they scale proportionally at any viewport width.

| Element | vw | ≈ px @1440 | ≈ px @844 (phone landscape) | Weight |
|---------|-----|-----------|-----|--------|
| Main title h1 | 4.5vw | 65 | 38 | 800 |
| Section title h2 | 3.5vw | 50 | 30 | 800 |
| Card title h3 | 2.6vw | 37 | 22 | 700 |
| Body text p, li | 2.4vw | 35 | 20 | 600 |
| Subtitle | 2.3vw | 33 | 19 | 500 |
| Tags / meta | 1.6vw | 23 | 14 | 700 |
| Large metrics | 7vw | 101 | 59 | 800 |
| Metric labels | 1.6vw | 23 | 14 | 700 |
| VS badge | 2.2vw | 32 | 19 | 700 |

### Line Heights

- Titles: 1.25
- Body: 1.55
- Metrics: 1.0
- Tags: 1.0

### 🔴 Absolute Prohibition

**Never use `clamp()` for font sizes.** Use **vw units** so proportions are identical at any viewport size. Fixed `px` values are also prohibited — they cause size mismatches between browser preview and PDF export.

---

## Color Rules

### Text Emphasis

- Max **3 different accent colors per slide** (avoid rainbow chaos)
- Wrap key phrases in `<span class="accent-N">` (N = 1–5)
- Primary text: `var(--text-primary)` — near-white on dark
- Secondary text: `var(--text-secondary)` — muted gray
- Accent colors from theme: `var(--accent-1)` through `var(--accent-5)`

### Background Layers

- Slide: `var(--bg)` — deepest dark
- Cards: `var(--bg-card)` — semi-transparent, lighter
- Info boxes: `var(--bg-card)` with colored left border

---

## Component Library

### 1. Title Slide

Opening slide — hook + title + positioning.

```html
<div class="slide slide-title active" data-slide="0">
  <div class="page-num">01</div>
  <div class="slide-content">
    <div class="tag"><span class="tag-bar"></span>CATEGORY · AUTHOR</div>
    <h1>Title line one,<br><span class="accent-1">colored keyword,</span><br>rest of title?</h1>
    <div class="accent-line"></div>
    <p class="subtitle">One-line subtitle or hook description</p>
  </div>
</div>
```

### 2. Content Slide

Title + bullet points — the workhorse. Max 5 bullets for 4:3 (more vertical space).

```html
<div class="slide" data-slide="1">
  <div class="page-num">02</div>
  <div class="slide-content">
    <div class="tag"><span class="tag-bar"></span>SECTION NAME</div>
    <h2>Section <span class="accent-1">Title</span></h2>
    <ul class="bullet-list">
      <li><span class="bullet-marker"></span><strong>Bold lead</strong> — explanation text that follows the key point.</li>
      <li><span class="bullet-marker"></span>Second point with <span class="accent-2">colored emphasis</span> on key phrase.</li>
      <li><span class="bullet-marker"></span>Third point, concise and clear.</li>
    </ul>
  </div>
</div>
```

### 3. Card Grid (2-Column)

Side-by-side comparison or grouped info. Max 2 cards per row. Stack 2+2 for 4 cards.

```html
<div class="slide" data-slide="2">
  <div class="page-num">03</div>
  <div class="slide-content">
    <h2>Card Grid <span class="accent-1">Title</span></h2>
    <div class="card-grid">
      <div class="card">
        <h3>Card Title</h3>
        <p>Card description text, concise. Two to three lines max.</p>
      </div>
      <div class="card">
        <h3>Card Title</h3>
        <p>Card description text, concise. Two to three lines max.</p>
      </div>
    </div>
  </div>
</div>
```

### 4. VS Comparison

Two-option head-to-head with VS bridge.

```html
<div class="slide" data-slide="3">
  <div class="page-num">04</div>
  <div class="slide-content">
    <h2>VS Comparison <span class="accent-1">Title</span></h2>
    <div class="vs-row">
      <div class="vs-card vs-left">
        <div class="vs-icon">👤</div>
        <h3 class="accent-5">Option A</h3>
        <p>Description text</p>
      </div>
      <div class="vs-badge">VS</div>
      <div class="vs-card vs-right">
        <div class="vs-icon">🏢</div>
        <h3 class="accent-1">Option B</h3>
        <p>Description text</p>
      </div>
    </div>
  </div>
</div>
```

### 5. Metric Display

Large numbers with labels. Up to 3 metrics, connected by operators.

```html
<div class="slide" data-slide="4">
  <div class="page-num">05</div>
  <div class="slide-content">
    <div class="tag"><span class="tag-bar"></span>METRIC LABEL</div>
    <h2>Metric <span class="accent-1">Title</span></h2>
    <div class="metric-row">
      <div class="metric">
        <div class="metric-label accent-3">Label A</div>
        <div class="metric-value">5</div>
        <div class="metric-desc">Description</div>
      </div>
      <div class="metric-op">×</div>
      <div class="metric">
        <div class="metric-label accent-1">Label B</div>
        <div class="metric-value accent-1">50</div>
        <div class="metric-desc">Description</div>
      </div>
      <div class="metric-op">×</div>
      <div class="metric">
        <div class="metric-label accent-5">Label C</div>
        <div class="metric-value accent-5">500</div>
        <div class="metric-desc">Description</div>
      </div>
    </div>
  </div>
</div>
```

### 6. Info Box

Alert-style callout with icon and colored left border. Always full-width.

```html
<div class="info-box tip">
  <div class="info-icon">⚡</div>
  <div class="info-content">
    <div class="info-title">Tip title here</div>
    <p>Detail text with <span class="accent-1">colored keywords</span> for emphasis.</p>
  </div>
</div>

<div class="info-box warning">
  <div class="info-icon">⚠</div>
  <div class="info-content">
    <div class="info-title">Warning title</div>
    <p>Detail text here.</p>
  </div>
</div>
```

Info boxes go inside `.slide-content`, below other elements. Multiple info boxes can stack vertically with gap.

### 7. Quote Block

Highlighted quote with attribution.

```html
<div class="slide" data-slide="5">
  <div class="page-num">06</div>
  <div class="slide-content slide-center">
    <div class="quote-block">
      <div class="quote-line"></div>
      <p class="quote-text">The quoted text goes here, ideally under three lines.</p>
      <div class="quote-attr">— Author Name</div>
    </div>
  </div>
</div>
```

### 8. Key Insight Slide

Single powerful statement, centered for maximum impact.

```html
<div class="slide" data-slide="6">
  <div class="page-num">07</div>
  <div class="slide-content slide-center">
    <h2 class="insight-text">The single powerful<br><span class="accent-1">insight statement</span><br>that stops scrolling.</h2>
  </div>
</div>
```

### 9. Closing Slide

Final slide — quote + takeaway + CTA.

```html
<div class="slide" data-slide="7">
  <div class="page-num">08</div>
  <div class="slide-content">
    <div class="quote-block">
      <div class="quote-line"></div>
      <p class="quote-text">Closing quote text.</p>
      <div class="quote-attr">— Author</div>
    </div>
    <div class="closing-takeaway">
      <p>Takeaway sentence with <span class="accent-1">colored emphasis</span>.</p>
    </div>
    <div class="closing-cta">
      <p>Call to action text. <span class="accent-1">Start here.</span></p>
    </div>
  </div>
</div>
```

### 10. Step Flow

Horizontal numbered steps for processes, stages, evolution. Max 3–4 steps.

```html
<div class="slide" data-slide="8">
  <div class="page-num">09</div>
  <div class="slide-content">
    <h2>Step Flow <span class="accent-1">Title</span></h2>
    <div class="step-flow">
      <div class="step">
        <div class="step-num accent-1">01</div>
        <h3>Step Title</h3>
        <p>Step description text, concise.</p>
      </div>
      <div class="step-arrow">→</div>
      <div class="step">
        <div class="step-num accent-2">02</div>
        <h3>Step Title</h3>
        <p>Step description text, concise.</p>
      </div>
      <div class="step-arrow">→</div>
      <div class="step">
        <div class="step-num accent-4">03</div>
        <h3>Step Title</h3>
        <p>Step description text, concise.</p>
      </div>
    </div>
  </div>
</div>
```

### 11. Split Text

Two balanced text columns with divider. For parallel comparisons, before/after, pros/cons.

```html
<div class="slide" data-slide="9">
  <div class="page-num">10</div>
  <div class="slide-content">
    <h2>Split Text <span class="accent-1">Title</span></h2>
    <div class="split-text">
      <div class="split-col">
        <h3 class="accent-1">Left Column</h3>
        <p>Left side content, 2-3 lines of description text.</p>
      </div>
      <div class="split-divider"></div>
      <div class="split-col">
        <h3 class="accent-2">Right Column</h3>
        <p>Right side content, 2-3 lines of description text.</p>
      </div>
    </div>
  </div>
</div>
```

### 12. Icon List

Vertical list with emoji/icon badges. More visual than plain bullets. 3–4 items.

```html
<div class="slide" data-slide="10">
  <div class="page-num">11</div>
  <div class="slide-content">
    <h2>Icon List <span class="accent-1">Title</span></h2>
    <div class="icon-list">
      <div class="icon-item">
        <div class="icon-badge">🎯</div>
        <div class="icon-text">
          <h3>Item Title</h3>
          <p>Item description text, one to two lines.</p>
        </div>
      </div>
      <div class="icon-item">
        <div class="icon-badge">⚡</div>
        <div class="icon-text">
          <h3>Item Title</h3>
          <p>Item description text, one to two lines.</p>
        </div>
      </div>
      <div class="icon-item">
        <div class="icon-badge">🔗</div>
        <div class="icon-text">
          <h3>Item Title</h3>
          <p>Item description text, one to two lines.</p>
        </div>
      </div>
    </div>
  </div>
</div>
```

### 13. Highlight Banner

Full-width centered large number/quote for mid-deck emphasis. More compact than Key Insight.

```html
<div class="slide" data-slide="11">
  <div class="page-num">12</div>
  <div class="slide-content slide-center">
    <div class="highlight-banner">
      <div class="banner-label accent-1">Key Metric</div>
      <div class="banner-value">42%</div>
      <div class="banner-desc">of startups fail because they build something nobody wants</div>
    </div>
  </div>
</div>
```

### 14. Formula Slide

Centered equation display with label and explanation. For showcasing a paper's key equation. Uses KaTeX for LaTeX rendering (CDN-loaded, no external images).

```html
<div class="slide" data-slide="12">
  <div class="page-num">13</div>
  <div class="slide-content slide-center">
    <h2>公式标题 <span class="accent-1">关键词</span></h2>
    <div class="formula-block">
      <div class="formula-label">Loss Function</div>
      <div class="formula-display">$$\mathcal{L} = -\mathbb{E}_{x \sim p_{data}} [\log D(x)] - \mathbb{E}_{z \sim p_z} [\log(1 - D(G(z)))]$$</div>
      <div class="formula-note">其中 $D$ 为判别器，$G$ 为生成器，$z$ 为噪声输入</div>
    </div>
  </div>
</div>
```

Content rules:
- One core equation per Formula Slide — never stack multiple display equations
- `formula-label` is short uppercase tag (e.g., "OBJECTIVE", "LOSS FUNCTION", "UPDATE RULE")
- `formula-note` explains key symbols in plain language
- Inline math `$...$` can appear in the note for symbol references

### 15. Formula + Explanation

Split layout: formula on one side, symbol breakdown on the other. For teaching what each term means.

```html
<div class="slide" data-slide="13">
  <div class="page-num">14</div>
  <div class="slide-content">
    <h2>公式 <span class="accent-1">拆解</span></h2>
    <div class="split-text">
      <div class="split-col split-col-formula">
        <div class="formula-block">
          <div class="formula-label">Attention</div>
          <div class="formula-display">$$\text{Attn}(Q,K,V) = \text{softmax}\!\left(\frac{QK^T}{\sqrt{d_k}}\right)V$$</div>
        </div>
      </div>
      <div class="split-divider"></div>
      <div class="split-col">
        <h3 class="accent-2">符号含义</h3>
        <p>$Q, K, V$ — 查询、键、值矩阵</p>
        <p>$d_k$ — 键向量维度，缩放防梯度消失</p>
        <p>softmax — 归一化注意力权重至概率分布</p>
      </div>
    </div>
  </div>
</div>
```

Content rules:
- Left column: formula block (centered vertically)
- Right column: 3–5 lines of symbol explanations, each line can use inline `$...$`
- Keep explanations concise — this is a visual reference, not a textbook

### Inline Math in Any Component

Any component (Content Slide, Icon List, Card Grid, etc.) can include inline math using `$...$` delimiters. Examples:

- Bullet: `<li><span class="bullet-marker"></span>损失函数采用 $\ell_2$ 正则化，权重衰减系数 $\lambda = 0.01$</li>`
- Card: `<p>梯度更新规则 $\theta \leftarrow \theta - \alpha \nabla_\theta \mathcal{L}$</p>`
- Info box: `<p>当 $n \to \infty$ 时收敛率为 $O(1/\sqrt{n})$</p>`

Rules:
- Max 1 inline formula per bullet/paragraph — keep readability
- Inline math font size inherits from parent element
- For complex multi-line equations, use Formula Slide instead

---

## Page Number

Large, semi-transparent number in top-right corner. Present on every slide.

---

## Animations

Subtle fade-in on slide entry. Keep minimal for video-frame usage.

---

## Complete HTML Template

Full base structure. Claude fills in `{{THEME_VARS}}`, `{{GOOGLE_FONTS_URL}}`, `{{TITLE}}`, and each slide's HTML.

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
<title>{{TITLE}}</title>
<link href="{{GOOGLE_FONTS_URL}}" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.css">
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.js"></script>
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/contrib/auto-render.min.js"></script>
<style>
/* === Reset === */
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
html { font-size: 16px; -webkit-font-smoothing: antialiased; -moz-osx-font-smoothing: grayscale; }

/* === Theme === */
:root {
  {{THEME_VARS}}
}

/* === Base Layout (4:3 landscape, all units in vw/vh) === */
body { background: var(--bg); color: var(--text-primary); font-family: var(--font-body); overflow: hidden; width: 100vw; height: 100vh; cursor: pointer; user-select: none; }

.slide { width: 100vw; height: 100vh; position: absolute; top: 0; left: 0; display: none; flex-direction: column; overflow: hidden; }
.slide.active { display: flex; }

.slide-content { flex: 1; display: flex; flex-direction: column; justify-content: center; padding: 5vh 5vw 5vh; gap: 2.5vh; overflow: hidden; }
.slide-center { align-items: center; text-align: center; }

/* === Page Number (watermark style) === */
.page-num { position: absolute; top: 3vh; right: 5vw; font-size: 8vw; font-weight: 800; opacity: 0.06; color: var(--text-primary); line-height: 1; font-family: var(--font-heading); pointer-events: none; }

/* === Page Indicator — REMOVED, only top-right watermark page number is used === */

/* === Category Tag === */
.tag { display: inline-flex; align-items: center; gap: 1vw; font-size: 1.6vw; font-weight: 700; letter-spacing: 0.3vw; text-transform: uppercase; color: var(--accent-1); }
.tag-bar { display: inline-block; width: 0.4vw; height: 2vw; background: var(--accent-1); border-radius: 0.2vw; }

/* === Accent Line === */
.accent-line { width: 5vw; height: 0.4vw; background: var(--accent-line); border-radius: 0.2vw; }

/* === Titles === */
h1 { font-family: var(--font-heading); font-size: 4.5vw; font-weight: 800; line-height: 1.25; }
h2 { font-family: var(--font-heading); font-size: 3.5vw; font-weight: 800; line-height: 1.25; }
h3 { font-family: var(--font-heading); font-size: 2.6vw; font-weight: 700; line-height: 1.3; }

/* === Body Text === */
p, li { font-size: 2.4vw; line-height: 1.5; color: var(--text-secondary); font-weight: 600; }
.subtitle { font-size: 2.3vw; color: var(--text-secondary); line-height: 1.5; font-weight: 500; }
strong { color: var(--text-primary); font-weight: 700; }

/* === Accent Colors === */
.accent-1 { color: var(--accent-1); }
.accent-2 { color: var(--accent-2); }
.accent-3 { color: var(--accent-3); }
.accent-4 { color: var(--accent-4); }
.accent-5 { color: var(--accent-5); }

/* === Bullet List === */
.bullet-list { list-style: none; display: flex; flex-direction: column; gap: 2vh; }
.bullet-list li { display: flex; align-items: flex-start; gap: 1.2vw; font-size: 2.4vw; line-height: 1.5; font-weight: 600; }
.bullet-marker { display: inline-block; flex-shrink: 0; width: 0.7vw; height: 0.7vw; margin-top: 1.2vw; background: var(--accent-1); border-radius: 50%; }

/* === Card Grid === */
.card-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 2vw; }
.card { background: var(--bg-card); border: 1px solid var(--divider); border-radius: 1.5vw; padding: 2.5vw; }
.card h3 { margin-bottom: 1vw; color: var(--accent-1); }
.card p { font-size: 2.1vw; line-height: 1.45; font-weight: 500; }

/* === VS Comparison === */
.vs-row { display: flex; align-items: stretch; gap: 2vw; }
.vs-card { flex: 1; background: var(--bg-card); border-radius: 1.5vw; padding: 2.5vw; text-align: center; border: 1px solid var(--divider); }
.vs-left { border-color: rgba(224,122,95,0.25); }
.vs-right { border-color: rgba(212,160,84,0.25); }
.vs-icon { font-size: 4vw; margin-bottom: 1vw; }
.vs-card h3 { font-size: 2.4vw; margin-bottom: 1vw; }
.vs-card p { font-size: 2.1vw; line-height: 1.45; font-weight: 500; }
.vs-badge { font-size: 2.2vw; font-weight: 700; color: var(--text-secondary); flex-shrink: 0; display: flex; align-items: center; }

/* === Metric Display === */
.metric-row { display: flex; align-items: center; justify-content: center; gap: 1.5vw; }
.metric { flex: 1; background: var(--bg-card); border: 1px solid var(--divider); border-radius: 1.5vw; padding: 2vw 1.5vw; text-align: center; }
.metric-label { font-size: 1.6vw; font-weight: 700; text-transform: uppercase; letter-spacing: 0.15vw; margin-bottom: 0.5vw; }
.metric-value { font-size: 7vw; font-weight: 800; line-height: 1; color: var(--text-primary); font-family: var(--font-heading); }
.metric-desc { font-size: 1.8vw; color: var(--text-secondary); margin-top: 0.5vw; line-height: 1.3; font-weight: 500; }
.metric-op { font-size: 3vw; font-weight: 700; color: var(--text-secondary); flex-shrink: 0; }

/* === Info Box === */
.info-box { display: flex; gap: 1.5vw; background: var(--bg-card); border-radius: 1.2vw; padding: 2vw 2.5vw; border-left: 0.4vw solid var(--info-tip); }
.info-box.warning { border-left-color: var(--info-warning); }
.info-box.warning .info-title { color: var(--info-warning); }
.info-box.insight { border-left-color: var(--info-insight); }
.info-box.insight .info-title { color: var(--info-insight); }
.info-icon { font-size: 2.4vw; flex-shrink: 0; line-height: 1.3; }
.info-title { font-size: 2.1vw; font-weight: 700; color: var(--info-tip); margin-bottom: 0.5vw; }
.info-content p { font-size: 2.1vw; line-height: 1.45; font-weight: 500; }

/* === Quote Block === */
.quote-block { max-width: 100%; }
.quote-line { width: 5vw; height: 0.4vw; background: var(--accent-line); border-radius: 0.2vw; margin-bottom: 3vh; }
.slide-center .quote-line { margin-left: auto; margin-right: auto; }
.quote-text { font-family: var(--font-heading); font-size: 3vw; font-weight: 500; font-style: italic; line-height: 1.5; color: var(--text-primary); }
.quote-attr { font-size: 1.8vw; color: var(--text-secondary); margin-top: 2vh; font-weight: 500; }

/* === Key Insight === */
.insight-text { font-size: 3.8vw; line-height: 1.35; max-width: 80vw; }

/* === Closing === */
.closing-takeaway { margin-top: 2vh; padding-top: 2vh; border-top: 1px solid var(--divider); }
.closing-takeaway p { color: var(--text-primary); font-weight: 600; }
.closing-cta { margin-top: 1.5vh; }
.closing-cta p { font-size: 2.1vw; font-weight: 500; }

/* === Step Flow === */
.step-flow { display: flex; align-items: flex-start; gap: 1.5vw; }
.step { flex: 1; background: var(--bg-card); border: 1px solid var(--divider); border-radius: 1.2vw; padding: 2vw; }
.step-num { font-size: 3.5vw; font-weight: 800; font-family: var(--font-heading); margin-bottom: 1vh; }
.step h3 { font-size: 2.2vw; margin-bottom: 0.8vh; }
.step p { font-size: 2vw; line-height: 1.45; font-weight: 500; }
.step-arrow { font-size: 2.5vw; color: var(--text-secondary); display: flex; align-items: center; padding-top: 2vw; font-weight: 700; }

/* === Split Text === */
.split-text { display: flex; gap: 2vw; align-items: flex-start; }
.split-col { flex: 1; }
.split-col h3 { font-size: 2.4vw; margin-bottom: 1.2vh; }
.split-col p { font-size: 2.2vw; line-height: 1.45; font-weight: 500; }
.split-divider { width: 0.2vw; background: var(--divider); align-self: stretch; border-radius: 0.1vw; }

/* === Icon List === */
.icon-list { display: flex; flex-direction: column; gap: 2.5vh; }
.icon-item { display: flex; align-items: flex-start; gap: 1.5vw; }
.icon-badge { font-size: 3vw; flex-shrink: 0; width: 4vw; text-align: center; }
.icon-text h3 { font-size: 2.2vw; margin-bottom: 0.5vh; }
.icon-text p { font-size: 2.1vw; line-height: 1.45; font-weight: 500; }

/* === Highlight Banner === */
.highlight-banner { text-align: center; padding: 4vh 3vw; background: var(--bg-card); border-radius: 1.5vw; border: 1px solid var(--divider); }
.banner-label { font-size: 1.6vw; font-weight: 700; text-transform: uppercase; letter-spacing: 0.2vw; margin-bottom: 1vh; }
.banner-value { font-size: 8vw; font-weight: 800; font-family: var(--font-heading); color: var(--text-primary); line-height: 1.1; }
.banner-desc { font-size: 2.2vw; color: var(--text-secondary); margin-top: 1vh; font-weight: 500; }

/* === Formula (KaTeX) === */
.katex { color: var(--text-primary); }
.katex-display { margin: 2.5vh 0; }
.katex-display > .katex { font-size: 3.8vw; }
.katex:not(.katex-display *) { font-size: 2.6vw; }
.formula-block { background: var(--bg-card); border: 1px solid var(--divider); border-radius: 1.5vw; padding: 3vw 3.5vw; text-align: center; }
.formula-label { font-size: 1.6vw; font-weight: 700; color: var(--accent-1); text-transform: uppercase; letter-spacing: 0.15vw; margin-bottom: 1.5vh; }
.formula-display { margin: 2vh 0; }
.formula-note { font-size: 2vw; color: var(--text-secondary); margin-top: 2vh; font-weight: 500; line-height: 1.5; }
.split-col-formula { display: flex; align-items: center; justify-content: center; }

/* === Animations === */
@keyframes fadeInUp { from { opacity: 0; transform: translateY(2vh); } to { opacity: 1; transform: translateY(0); } }
.slide.active .slide-content > * { animation: fadeInUp 0.4s ease-out both; }
.slide.active .slide-content > *:nth-child(1) { animation-delay: 0.05s; }
.slide.active .slide-content > *:nth-child(2) { animation-delay: 0.12s; }
.slide.active .slide-content > *:nth-child(3) { animation-delay: 0.19s; }
.slide.active .slide-content > *:nth-child(4) { animation-delay: 0.26s; }
.slide.active .slide-content > *:nth-child(5) { animation-delay: 0.33s; }
.slide.active .slide-content > *:nth-child(6) { animation-delay: 0.40s; }

@media (prefers-reduced-motion: reduce) { .slide.active .slide-content > * { animation: none; opacity: 1; } }
</style>
</head>
<body>

<!-- Slides go here: one .slide div per page -->
{{SLIDES_HTML}}

<script>
(function(){
  // KaTeX auto-render: process all $...$ and $$...$$ math delimiters
  if(typeof renderMathInElement !== 'undefined'){
    renderMathInElement(document.body, {
      delimiters: [
        {left: '$$', right: '$$', display: true},
        {left: '$', right: '$', display: false}
      ],
      throwOnError: false
    });
  } else {
    // KaTeX loaded with defer, wait for it
    document.addEventListener('DOMContentLoaded', function(){
      if(typeof renderMathInElement !== 'undefined'){
        renderMathInElement(document.body, {
          delimiters: [{left:'$$',right:'$$',display:true},{left:'$',right:'$',display:false}],
          throwOnError: false
        });
      }
    });
  }

  const slides = document.querySelectorAll('.slide');
  const total = slides.length;
  let current = 0;

  function goTo(n){
    if(n<0||n>=total||n===current)return;
    slides[current].classList.remove('active');
    current=n;
    slides[current].classList.add('active');
  }

  // Keyboard navigation
  document.addEventListener('keydown',e=>{
    if(e.key==='ArrowRight'||e.key==='ArrowDown'||e.key===' '){e.preventDefault();goTo(current+1);}
    else if(e.key==='ArrowLeft'||e.key==='ArrowUp'){e.preventDefault();goTo(current-1);}
    else if(e.key==='Home'){goTo(0);}
    else if(e.key==='End'){goTo(total-1);}
  });

  // Click navigation: left 40% = prev, right 60% = next
  document.addEventListener('click',e=>{
    if(e.target.closest('a,button,input,select,textarea'))return;
    const x = e.clientX / window.innerWidth;
    if(x < 0.4){ goTo(current-1); } else { goTo(current+1); }
  });

  // Touch swipe navigation (left/right for landscape)
  let tX=0;
  document.addEventListener('touchstart',e=>{tX=e.changedTouches[0].screenX;},{passive:true});
  document.addEventListener('touchend',e=>{
    const dx=e.changedTouches[0].screenX-tX;
    if(Math.abs(dx)>50){dx<0?goTo(current+1):goTo(current-1);}
  },{passive:true});
})();
</script>
</body>
</html>
```

### Template Usage Notes

When generating a presentation:
1. Copy the entire template
2. Replace `{{TITLE}}` with presentation title
3. Replace `{{GOOGLE_FONTS_URL}}` with the Google Fonts link from the chosen theme
4. Replace `{{THEME_VARS}}` with the CSS `:root` block from the chosen theme
5. Replace `{{SLIDES_HTML}}` with slide divs, using components from this library
6. First slide must have class `active` (e.g., `<div class="slide active" data-slide="0">`)
7. Each slide gets a sequential `data-slide` attribute starting from 0
8. Page numbers: `01`, `02`, ..., formatted with leading zero for single digits

### KaTeX Math Usage Notes

- KaTeX is loaded via CDN (CSS + JS + auto-render extension) — no local files needed
- Use `$$...$$` for display-mode equations (centered, large)
- Use `$...$` for inline math within text
- LaTeX syntax supported: `\frac{}{}`, `\mathbb{}`, `\sum`, `\int`, Greek letters, etc.
- Auto-render processes the entire document on load — works in any component
- In HTML, use `&lt;` for `<` and `&gt;` for `>` inside math if needed (KaTeX handles most cases)
- **PDF compatibility**: KaTeX renders to pure HTML/CSS (no Canvas/SVG images), so Playwright captures it correctly. The export script's `waitUntil: 'networkidle'` ensures CDN resources load before screenshot.
- If presentation has **no math content**, KaTeX CDN links can be omitted to reduce load time

### Navigation Behavior

- **Click**: left 40% of screen = previous slide, right 60% = next slide
- **Keyboard**: Arrow keys (←/→/↑/↓), Space (next), Home/End
- **Touch**: swipe left = next, swipe right = previous
- **Page number**: only the top-right watermark-style number (opacity 0.06), no bottom-right indicator
- **No visible buttons** — clean, minimal interface
