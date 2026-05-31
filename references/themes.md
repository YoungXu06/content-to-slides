# Theme Presets

5 dark-background themes for portrait short-video slides. Each theme provides complete CSS custom properties consumed by the HTML template in [slide-design.md](slide-design.md).

## Table of Contents

- [Auto-Selection Rules](#auto-selection-rules)
- [Theme 1: Deep Ocean](#theme-1-deep-ocean)
- [Theme 2: Midnight Gold](#theme-2-midnight-gold)
- [Theme 3: Electric Dark](#theme-3-electric-dark)
- [Theme 4: Forest Night](#theme-4-forest-night)
- [Theme 5: Warm Dusk](#theme-5-warm-dusk)
- [Font Pairing Quick Reference](#font-pairing-quick-reference)

---

## Auto-Selection Rules

| Content Mood | Theme | Signal Words |
|-------------|-------|-------------|
| 科普 / 理性 / 技术研究 | Deep Ocean | 论文, 研究, 技术, AI, 数据, 实验, 模型, 算法 |
| 哲学 / 思维模型 / 策略 | Midnight Gold | 思维, 认知, 战略, 哲学, 智慧, 心理, 心智 |
| 犀利 / 争议 / 趋势预测 | Electric Dark | 颠覆, 争议, 未来, 反常识, 预测, 趋势 |
| 自然 / 健康 / 可持续 | Forest Night | 健康, 自然, 可持续, 环境, 生活, 运动 |
| 叙事 / 文化 / 人文情感 | Warm Dusk | 故事, 文化, 历史, 情感, 人文, 人生 |

Default: **Deep Ocean**（无明确信号时使用）

User can override with explicit request.

---

## Theme 1: Deep Ocean

- **Vibe**: Professional, analytical, trustworthy
- **Best for**: Tech articles, research papers, AI/data topics, product analysis
- **Font pairing**: Inter (heading) + Noto Sans SC (body)
- **Google Fonts**:

```
https://fonts.googleapis.com/css2?family=Inter:wght@500;600;700;800&family=Noto+Sans+SC:wght@500;600;700;800&display=swap
```

```css
:root {
  --bg: #0f1923;
  --bg-card: rgba(255, 255, 255, 0.05);
  --bg-card-hover: rgba(255, 255, 255, 0.08);
  --text-primary: #e8ecf1;
  --text-secondary: #c2ced9;
  --accent-1: #5ba4c4;  /* 柔和钢蓝 — 主强调 */
  --accent-2: #7bbfb4;  /* 灰绿 — 次强调 */
  --accent-3: #e2b55a;  /* 暖琥珀 — 高亮 */
  --accent-4: #a89bcf;  /* 淡紫 — 特殊 */
  --accent-5: #d4856a;  /* 赤陶 — 警示 */
  --accent-line: #5ba4c4;
  --divider: rgba(255, 255, 255, 0.07);
  --info-tip: #5ba4c4;
  --info-warning: #e2b55a;
  --info-insight: #a89bcf;
  --font-heading: 'Inter', 'Noto Sans SC', system-ui, sans-serif;
  --font-body: 'Noto Sans SC', 'Inter', system-ui, sans-serif;
}
```

---

## Theme 2: Midnight Gold

- **Vibe**: Elegant, contemplative, authoritative
- **Best for**: Philosophy, mindset, strategy, personal development, psychology
- **Font pairing**: Playfair Display (heading) + Noto Serif SC (body)
- **Google Fonts**:

```
https://fonts.googleapis.com/css2?family=Playfair+Display:wght@500;700;800&family=Noto+Serif+SC:wght@500;600;700;800&display=swap
```

```css
:root {
  --bg: #0d0b0f;
  --bg-card: rgba(255, 255, 255, 0.04);
  --bg-card-hover: rgba(255, 255, 255, 0.07);
  --text-primary: #ece8e2;
  --text-secondary: #d0c9be;
  --accent-1: #c49a4e;  /* 古铜金 — 主强调 */
  --accent-2: #d4b87a;  /* 浅麦 — 次强调 */
  --accent-3: #9b8abf;  /* 薰衣草 — 对比 */
  --accent-4: #c47a5a;  /* 陶土 — 高亮 */
  --accent-5: #7aab8e;  /* 灰绿 — 正面 */
  --accent-line: #c49a4e;
  --divider: rgba(255, 255, 255, 0.06);
  --info-tip: #c49a4e;
  --info-warning: #d4b87a;
  --info-insight: #9b8abf;
  --font-heading: 'Playfair Display', 'Noto Serif SC', Georgia, serif;
  --font-body: 'Noto Serif SC', 'Playfair Display', Georgia, serif;
}
```

---

## Theme 3: Electric Dark

- **Vibe**: Bold, energetic, provocative, modern
- **Best for**: Trends, controversial takes, startup/business, hot topics
- **Font pairing**: Space Grotesk (heading) + Noto Sans SC (body)
- **Google Fonts**:

```
https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700;800&family=Noto+Sans+SC:wght@500;600;700;800&display=swap
```

```css
:root {
  --bg: #13131d;
  --bg-card: rgba(255, 255, 255, 0.05);
  --bg-card-hover: rgba(255, 255, 255, 0.09);
  --text-primary: #eeeef5;
  --text-secondary: #c8c8dc;
  --accent-1: #7b7fe8;  /* 柔靛蓝 — 主强调 */
  --accent-2: #c77dab;  /* 玫瑰灰 — 次强调 */
  --accent-3: #8fc47a;  /* 灰绿 — 对比 */
  --accent-4: #6db5d4;  /* 灰蓝 — 高亮 */
  --accent-5: #d4a65a;  /* 琥珀 — 警示 */
  --accent-line: #7b7fe8;
  --divider: rgba(255, 255, 255, 0.07);
  --info-tip: #8fc47a;
  --info-warning: #d4a65a;
  --info-insight: #c77dab;
  --font-heading: 'Space Grotesk', 'Noto Sans SC', system-ui, sans-serif;
  --font-body: 'Noto Sans SC', 'Space Grotesk', system-ui, sans-serif;
}
```

---

## Theme 4: Forest Night

- **Vibe**: Calm, grounded, organic, trustworthy
- **Best for**: Nature, wellness, sustainability, health, mindfulness
- **Font pairing**: DM Sans (heading) + Noto Sans SC (body)
- **Google Fonts**:

```
https://fonts.googleapis.com/css2?family=DM+Sans:wght@500;600;700;800&family=Noto+Sans+SC:wght@500;600;700;800&display=swap
```

```css
:root {
  --bg: #0e1512;
  --bg-card: rgba(255, 255, 255, 0.04);
  --bg-card-hover: rgba(255, 255, 255, 0.07);
  --text-primary: #e0e8e4;
  --text-secondary: #c0cec5;
  --accent-1: #5dab8a;  /* 灰松绿 — 主强调 */
  --accent-2: #8bc4a0;  /* 浅薄荷 — 次强调 */
  --accent-3: #d4a85a;  /* 蜂蜜 — 对比 */
  --accent-4: #8fa4b8;  /* 雾蓝 — 柔和 */
  --accent-5: #c48a9b;  /* 干玫瑰 — 特殊 */
  --accent-line: #5dab8a;
  --divider: rgba(255, 255, 255, 0.06);
  --info-tip: #5dab8a;
  --info-warning: #d4a85a;
  --info-insight: #8bc4a0;
  --font-heading: 'DM Sans', 'Noto Sans SC', system-ui, sans-serif;
  --font-body: 'Noto Sans SC', 'DM Sans', system-ui, sans-serif;
}
```

---

## Theme 5: Warm Dusk

- **Vibe**: Warm, intimate, storytelling, humanistic
- **Best for**: Culture, history, personal essays, humanities, emotion-driven content
- **Font pairing**: Source Serif 4 (heading) + Noto Sans SC (body)
- **Google Fonts**:

```
https://fonts.googleapis.com/css2?family=Source+Serif+4:wght@500;600;700;800&family=Noto+Sans+SC:wght@500;600;700;800&display=swap
```

```css
:root {
  --bg: #181210;
  --bg-card: rgba(255, 255, 255, 0.04);
  --bg-card-hover: rgba(255, 255, 255, 0.07);
  --text-primary: #ede6df;
  --text-secondary: #d5cdc4;
  --accent-1: #c87a4e;  /* 赤陶橙 — 主强调 */
  --accent-2: #d4a65a;  /* 琥珀 — 次强调 */
  --accent-3: #c47a8a;  /* 玫瑰棕 — 对比 */
  --accent-4: #8b7abf;  /* 紫灰 — 特殊 */
  --accent-5: #6aab8e;  /* 灰绿 — 正面 */
  --accent-line: #c87a4e;
  --divider: rgba(255, 255, 255, 0.06);
  --info-tip: #c87a4e;
  --info-warning: #d4a65a;
  --info-insight: #c47a8a;
  --font-heading: 'Source Serif 4', 'Noto Sans SC', Georgia, serif;
  --font-body: 'Noto Sans SC', 'Source Serif 4', system-ui, sans-serif;
}
```

---

## Font Pairing Quick Reference

| Theme | Heading Font | Body Font | Style |
|-------|-------------|-----------|-------|
| Deep Ocean | Inter | Noto Sans SC | Sans / Sans |
| Midnight Gold | Playfair Display | Noto Serif SC | Serif / Serif |
| Electric Dark | Space Grotesk | Noto Sans SC | Grotesque / Sans |
| Forest Night | DM Sans | Noto Sans SC | Sans / Sans |
| Warm Dusk | Source Serif 4 | Noto Sans SC | Serif / Sans |

All fonts are from Google Fonts (free, no license issues).

Every theme includes Chinese font (`Noto Sans SC` or `Noto Serif SC`) to ensure CJK text renders correctly. Font stacks include system fallbacks (`PingFang SC`, `Microsoft YaHei`, `system-ui`) for offline/blocked scenarios.
