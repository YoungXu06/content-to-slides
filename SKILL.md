---
name: content-to-slides
description: Turn an article or video link (or any long-form content) into a 5-10 page landscape (4:3) short-video-style slide deck + PDF + per-slide speaker script. Generates self-contained HTML slides with dark-theme design optimized for large readable text (no external skill dependency). Chinese-first, adapts to user language. Speaker script written in professional-but-accessible voice. Use when the user wants to "把这篇文章/这个视频做成 PPT 讲一下", "给我整理个 5-10 页的讲解", "帮我把这个链接的精髓做成讲稿 + slides + PDF", or pastes an article URL / YouTube / Bilibili / 播客链接 and asks for a quick-explainer deck. Triggers on URLs paired with phrases like "讲解"、"精髓"、"总结成 PPT"、"做成短视频脚本"、"slides + 讲稿"、"summarize into a deck"、"explainer deck".
---

# Content to Slides

把长内容变成一套 **横屏 4:3 暗色主题的 5–10 页讲解 slides + PDF + 每页口播讲稿**。全流程自闭环，不依赖任何外部 skill。

## What This Skill Delivers

1. `presentation.html` — 横屏 4:3 暗色主题 HTML slides（自主生成，单文件，点击翻页）
2. `output.pdf` — 4:3 横屏 1440×1080 PDF（用自带 scripts/export-pdf.sh，与 HTML 布局完全一致）
3. `script.md` — 每页对应的口播讲稿 + 末尾社媒帖文（50–100 字 + #标签），专业口吻，可直接录制和发布

## Core Principles

1. **抓精髓，不抓字面**：先用一句话回答"这玩意到底在讲什么"。所有内容围绕这句话展开。
2. **5-10 页硬约束**：少于 5 页没信息量，多于 10 页不是短视频节奏。不够精彩就砍。
3. **口播讲稿要像专业的活人**：气质定位：专业从业者给懂行朋友讲一件事。详见 [references/voice.md](references/voice.md)。
4. **自主生成 HTML**：直接生成 HTML，不委托任何外部 skill。组件库见 [references/slide-design.md](references/slide-design.md)，主题见 [references/themes.md](references/themes.md)。
5. **横屏 4:3 + 大字可读 + 点击翻页**：4:3 比例（比 16:9 纵向空间更多，文字更大），所有尺寸用 **vw/vh 单位**（不是固定 px，不是 clamp）。vw 确保比例在浏览器和 1440×1080 PDF 画布上完全一致。HTML 使用点击翻页（点击屏幕左侧 40% 上一页、右侧 60% 下一页），仅保留右上角水印式页码，无可见按钮，无底部页码指示器。
6. **🔴 中文优先硬规则**：Slides 和讲稿统一使用中文。即使原始内容是英文，slides 上的标题、bullet、卡片文字、标签等**全部翻译为中文**呈现。仅保留专有名词（人名、产品名、技术术语缩写如 LLM、RL、API）使用英文原文。讲稿同样为中文。用户明确要求英文输出时例外。

## End-to-End Workflow

```
Phase 1: 确认输入与目标
Phase 2: 抓取并深度解读原始内容
Phase 3: 设计 5-10 页讲解大纲 + 选组件
Phase 4: 自主生成 HTML slides
Phase 5: 导出 PDF
Phase 6: 生成每页口播讲稿
Phase 6.5: 生成社媒帖文（附在讲稿末尾）
Phase 7: 交付
```

---

## Phase 1: Confirm Input & Goal

用**一次** AskUserQuestion 收齐（用户已明确时可跳过）：

- 输入类型：文章 URL / 视频 URL / 长文 / markdown 文件 / GitHub 仓库链接
- 讲解受众：通俗向普通观众（默认）/ 向从业者 / 向学生
- 输出目录：默认 `./content-to-slides-output/<短标题-slug>/`

**不追问风格、不追问页数**。页数由内容密度决定，主题由内容自动匹配。

---

## Phase 2: Content Acquisition & Deep Understanding

先读 [references/ingestion.md](references/ingestion.md)，按链接类型选择抓取策略。

### YouTube 视频快速路径

如果输入是 YouTube 链接，**优先使用自动脚本下载字幕**：

```bash
# 定位 skill 目录
SKILL_DIR=""
for p in "$HOME/.claude/skills/content-to-slides" \
         "$HOME/.claude-internal/skills/content-to-slides" \
         "$HOME/.codebuddy/skills/content-to-slides" \
         "$HOME/.config/skills/content-to-slides"; do
  [ -d "$p/scripts" ] && SKILL_DIR="$p" && break
done

# 下载字幕到输出目录
bash "$SKILL_DIR/scripts/fetch-youtube-transcript.sh" "<YouTube-URL>" "<输出目录>"
```

脚本成功后，用 Read 工具读取 `<输出目录>/transcript.txt` 获取完整字幕文本。脚本失败时按 ingestion.md 中的 fallback 策略处理。

### GitHub 仓库快速路径

如果输入是 GitHub 仓库链接（github.com/owner/repo），**优先使用自动脚本分析仓库**：

```bash
# 定位 skill 目录
SKILL_DIR=""
for p in "$HOME/.claude/skills/content-to-slides" \
         "$HOME/.claude-internal/skills/content-to-slides" \
         "$HOME/.codebuddy/skills/content-to-slides" \
         "$HOME/.config/skills/content-to-slides"; do
  [ -d "$p/scripts" ] && SKILL_DIR="$p" && break
done

# 分析仓库到输出目录
bash "$SKILL_DIR/scripts/fetch-github-repo.sh" "<GitHub-URL>" "<输出目录>"
```

脚本成功后，用 Read 工具读取 `<输出目录>/repo-analysis.md` 获取仓库分析内容。脚本失败时按 ingestion.md 中的 GitHub fallback 策略处理。

**GitHub 项目讲解重点**（项目概览方向）：
1. 这个项目**解决什么问题**？（从 README 开头提炼）
2. **核心架构和技术栈**是什么？（从目录结构 + 依赖推断）
3. **关键功能/特性**有哪些？（从 README features 章节提取）
4. **怎么用**？（安装和使用方式）
5. 项目的**独特价值/亮点**是什么？（对比同类项目的差异化）

**硬规则：绝不凭标题 + 描述幻想内容。** 抓不到实质文本就停下来要。

抓到内容后，读 [references/summarization.md](references/summarization.md) 做深度解读（用"5 问骨架法"，内部思考不输出给用户）。

---

## Phase 3: Slide Outline (5–10 pages)

### 短视频节奏模板

```
P1  钩子页     — 反常识 / 戳中的问题 / 惊人数字
P2  是什么     — 一句话定义核心概念
P3–P6 论点页   — 每页一个 key insight + 支撑
P7  反直觉点   — 最值钱的 insight，单独放大
P8  能改变什么 — 观众 takeaway / action
P9  收束/彩蛋   — 金句、出处（可选）
```

### 内容密度规则

- 标题页：tag + 标题（带彩色关键词）+ 副标题
- 内容页：1 标题 + 3–5 bullets（4:3 比例纵向空间更多，可容纳 5 条）
- 卡片页：最多 2 列
- 指标页：最多 3 个大数字
- 信息框：全宽，单列
- 金句页：居中单句
- 公式页：1 个核心公式 + 变量说明（不堆叠多个 display 公式）
- 行内公式：bullet/卡片/info box 中可嵌入 `$...$`，单条不超过 1 个公式

### 🔴 横向栏数硬上限：≤ 2 栏

卡片、metric、step 等横向并排内容**最多 2 列**。3 列仅允许用于小型数字指标。

### 选择组件

为每页指定组件类型（对应 [references/slide-design.md](references/slide-design.md) 中的 15 种组件）：

| 内容类型 | 推荐组件 |
|---------|---------|
| 开场钩子 | Title Slide |
| 概念解释 + 要点 | Content Slide |
| 两两对比 | Card Grid 或 VS Comparison |
| 数据/数字 | Metric Display |
| 提醒/警告 | Content Slide + Info Box |
| 引用金句 | Quote Block |
| 核心洞察 | Key Insight Slide |
| 结尾收束 | Closing Slide |
| 流程/阶段/演进 | Step Flow（步骤流） |
| 并列对照/正反面 | Split Text（双栏文本） |
| 带具象说明的要点 | Icon List（图标列表） |
| 中途强调数据/金句 | Highlight Banner（高亮横幅） |
| 论文核心公式 | Formula Slide（公式展示） |
| 公式逐项解读 | Formula + Explanation（公式双栏） |

### 🔴 布局多样性硬规则

- **禁止连续2页以上使用相同组件类型**（如连续3页都是Content Slide必须打破）
- **8页以上的deck必须使用 ≥5 种不同组件**
- **每3页bullet式内容页之后，必须插入1页视觉型组件**（Card Grid / Metric / Step Flow / Quote / Highlight Banner / Icon List）
- **Content Slide（纯bullet）整体占比不超过50%**——更多地使用Icon List、Step Flow、Split Text来替代纯bullet
- **布局节奏**：视觉丰富页（Card/Metric/Step/Banner）与文字页交替出现，避免视觉单调

### 输出大纲给用户

> "大纲如下，看着 OK 我直接往下做；想调的直接说。"

用户不说话就继续，**不要傻等**。

---

## Phase 4: Generate HTML Slides (SELF-CONTAINED)

### Step 4.1: Select Theme

读 [references/themes.md](references/themes.md)，按内容情绪自动选择：

| 内容情绪 | 主题 |
|---------|------|
| 科普 / 理性 / 技术 | Deep Ocean |
| 哲学 / 思维 / 策略 | Midnight Gold |
| 犀利 / 争议 / 趋势 | Electric Dark |
| 自然 / 健康 / 可持续 | Forest Night |
| 叙事 / 文化 / 人文 | Warm Dusk |

用户可显式指定覆盖。

### Step 4.2: Build HTML

读 [references/slide-design.md](references/slide-design.md) 获取完整组件库和 HTML 模板。

生成单文件 `presentation.html`：
1. HTML shell：viewport meta + Google Fonts link + KaTeX CDN（如有公式）
2. `<style>`：主题 CSS 变量 + 基础布局 + 所有组件样式 + 公式样式
3. `<body>`：每页一个 `.slide` div，使用组件库中的 HTML 结构
4. `<script>`：KaTeX auto-render 初始化 + 点击翻页（左 40% = 上一页，右 60% = 下一页）+ 键盘导航 + 触摸滑动

内容规则：
- 每个彩色关键词用 `<span class="accent-N">` 包裹
- 每页右上角页码（`<div class="page-num">01</div>`）
- 首 1-2 页加 category tag
- 标题下加 accent line
- 数学公式用 `$$...$$`（display）或 `$...$`（inline），KaTeX 自动渲染
- **如果 deck 不含任何数学公式，省略 KaTeX CDN 链接以减少加载时间**

### 🔴 Step 4.2.5: 布局节奏检查（生成HTML前必做）

生成前审视大纲中的组件序列：
- 是否有连续相同类型？→ 替换中间一页为其他组件
- 是否整体超过50%是Content Slide？→ 将部分bullet页改为Icon List / Split Text / Step Flow
- 是否有视觉"高峰-低谷"节奏？→ 视觉丰富页（Card/Metric/Step/Banner）与文字页交替出现
- 偏好用 **Icon List 替代纯 bullet**（更有视觉节奏）、用 **Step Flow 替代"首先其次最后"式列举**

### Step 4.3: Validate

生成后读 HTML 前 60 行确认：
- viewport meta tag 正确
- 主题 CSS 变量存在
- **字号用 vw 单位（不是固定 px，不是 clamp）**
- `.slide` 数量与大纲一致

### 🔴 Sizing Hard Rule

生成的 HTML 中，**所有 font-size、padding、gap、margin 必须使用 vw/vh 单位**。禁止固定 px（在 1440px PDF 画布上会显得不一致）、禁止 clamp()。vw 单位确保内容在任何屏幕尺寸和 PDF（1440×1080）上比例完全一致。

### 🔴 Navigation Hard Rule

**不要有任何可见的导航按钮。** 翻页通过以下方式实现：
- **点击**：屏幕左侧 40% = 上一页，右侧 60% = 下一页
- **键盘**：← → ↑ ↓ Space Home End
- **触摸滑动**：左/右滑动
- **页码**：仅保留右上角水印式大号页码（opacity 0.06），不显示底部页码指示器

---

## Phase 5: Export PDF

用本 skill 自带的 `scripts/export-pdf.sh`（1440×1080 横屏 4:3）：

```bash
bash <skill-dir>/scripts/export-pdf.sh <输出目录>/presentation.html <输出目录>/output.pdf
```

`<skill-dir>` 的定位：
```bash
SKILL_DIR=""
for p in "$HOME/.claude/skills/content-to-slides" \
         "$HOME/.claude-internal/skills/content-to-slides" \
         "$HOME/.codebuddy/skills/content-to-slides" \
         "$HOME/.config/skills/content-to-slides"; do
  [ -d "$p/scripts" ] && SKILL_DIR="$p" && break
done
```

PDF 超过 10MB 时用 `--compact` 重跑。

---

## Phase 6: Generate Speaker Script (script.md)

**写之前必须读** [references/voice.md](references/voice.md)。

### 输出格式

```markdown
# 讲稿：<presentation 标题>

> 共 N 页 · 预估口播时长 约 X 分钟

## Slide 1 · <页标题>

<口播正文，纯文本>

---

## Slide 2 · <页标题>

<...>

---

## 社媒帖文

<50–100 字一段话，末尾加 #标签1 #标签2 #标签3 ...>
```

### 🔴 纯文本硬规则

讲稿正文（每个 H2 下面）**必须是纯文本**。禁止：
- `**加粗**` / `*斜体*` / `` `代码` `` / `- 列表` / `[链接](url)` / `> 引用块` / emoji

只允许：H1、H2 标题、`>` 总时长行、`---` 分隔线。

要强调？靠语序、留白、断句。

### 三条硬禁令

❌ "这一页我将..." / "下面我们来看看..." / "接下来请看..."
❌ "大家好，欢迎来到..." / "谢谢大家" / "感谢聆听"
❌ 把 slide 上的 bullet 原封不动念一遍

### 必须具备的质感

✅ 气质：专业从业者给懂行朋友讲一件事
✅ 钩子：靠具体事实或判断抓人，不靠夸张情绪
✅ 观点：有判断有依据，可以锐不能煽动
✅ "我"全篇 ≤ 2 次，感叹号 ≤ 2 个
✅ 禁词：不出现"讲真/说白了/最骚的/炸裂/封神/绝了/yyds"

### 长度

每页 80–180 字，钩子页可 30–50 字，关键论点页可到 200 字。宁可短不可水。

### 写完必做自检

1. 随机挑一页读出来，像不像短视频口播？
2. 第一页第一句够不够钩人？
3. 哪页讲稿和 slide 字面重复？改成延伸/打比方/补原因
4. 扫禁用词，出现即删
5. 跑正则扫描：

```bash
grep -nE '\*\*|__|`|^[[:space:]]*[-*+][[:space:]]|^[[:space:]]*[0-9]+\.[[:space:]]|\[.+\]\(' script.md
```

6. 跑中英/中数间距扫描（正文中中文与英文/数字之间不加空格）：

```bash
grep -nP '[\x{4e00}-\x{9fff}] [A-Za-z0-9]|[A-Za-z0-9] [\x{4e00}-\x{9fff}]' script.md
```

H1/H2 标题行和文件顶部 `>` 总时长行除外，其余命中即删空格。

---

## Phase 6.5: Generate Social Media Post (社媒帖文)

在 `script.md` 末尾最后一个 `---` 分隔线后，追加一个 `## 社媒帖文` 段落。

**写之前必须读** [references/voice.md](references/voice.md) 中的"社媒帖文语气指南"。

### 格式

```markdown
---

## 社媒帖文

<50–100 字一段话><空一行>
#标签1 #标签2 #标签3 #标签4
```

### 硬规则

- **50–100 字**，一段话，不分行、不用列表
- 用一个**核心事实或反直觉判断**开头（不是"你知道吗"式开场）
- 末尾另起一行，3–5 个 `#标签`，标签用中文（专有名词保留英文）
- 帖文遵循讲稿的纯文本规则：无 Markdown 修饰、无 emoji
- 语气参照 voice.md 社媒帖文指南

### 写完自检

7. 数字数：帖文正文（不含标签行）50–100 字？
8. 标签 3–5 个？每个以 `#` 开头？
9. 有没有出现"点赞收藏 / 关注不迷路 / 三连"等卖关注式引导？有则删

---

## Phase 7: Deliver

```
搞定 ✅

📂 输出目录: <绝对路径>
 ├─ presentation.html   （浏览器打开，点击翻页，横屏 4:3）
 ├─ output.pdf          （X 页，Y MB，横屏 1440×1080，与 HTML 布局一致）
 └─ script.md           （X 页口播讲稿 + 社媒帖文，总时长约 Z 分钟）

🎯 一句话精髓：
<Phase 2 提炼的一句话核心>
```

---

## Supporting Files

| File | Purpose | When to Read |
|------|---------|--------------|
| [references/ingestion.md](references/ingestion.md) | 各类链接抓取策略与 fallback | Phase 2 抓内容时 |
| [references/summarization.md](references/summarization.md) | 5问骨架法：提炼核心论点 | Phase 2 解读前 |
| [references/slide-design.md](references/slide-design.md) | 4:3 横屏组件库 + 排版规则 + HTML 模板 | Phase 4 生成 HTML 时 |
| [references/themes.md](references/themes.md) | 5 个暗色主题预设 + 选择规则 | Phase 4 选主题时 |
| [references/voice.md](references/voice.md) | 口播讲稿语气规则 + 禁用词 | Phase 6 写讲稿前 |
| [scripts/fetch-youtube-transcript.sh](scripts/fetch-youtube-transcript.sh) | YouTube 字幕自动下载（yt-dlp + youtube-transcript-api） | Phase 2 YouTube 链接时 |
| [scripts/fetch-github-repo.sh](scripts/fetch-github-repo.sh) | GitHub 仓库自动分析（gh CLI + git clone fallback） | Phase 2 GitHub 链接时 |
| [scripts/parse_transcript.py](scripts/parse_transcript.py) | 字幕文件解析（VTT/SRT → 纯文本） | 由 fetch-youtube-transcript.sh 调用 |
| [scripts/export-pdf.sh](scripts/export-pdf.sh) | PDF 导出（1440×1080 4:3） | Phase 5 导出时 |

---

## Quick Reference: Common Failure Modes

| 症状 | 修正 |
|------|------|
| 字看不清 / PDF 内容太小 | 检查是否用了固定 px 或 clamp — **必须用 vw 单位**，确保比例一致 |
| PDF 和 HTML 布局不一致 | 确认所有尺寸用 vw/vh（不是固定 px），export-pdf.sh 用 1440×1080 |
| 组件样式缺失 | 重读 references/slide-design.md，确认所有 CSS 内联 |
| HTML 出现可见翻页按钮 | 删除按钮，改为点击翻页（左 40% 上一页、右 60% 下一页） |
| 视频抓不到字幕但已开始编内容 | 停下，让用户贴字幕；Phase 2 禁止幻想 |
| 生成了 12+ 页 | 砍到 10 页内；"论点去重合并"而非"缩每页字数" |
| 布局单调 / 全是bullet | 检查布局多样性规则——用 Icon List / Step Flow / Split Text 替代纯 Content Slide |
| 讲稿像播音腔/自媒体腔 | 回去读 references/voice.md 重写 |
| 讲稿和 slides 字面重复 | 讲稿要延伸/补原因/打比方，不是朗读 |
| 讲稿正文出现 Markdown 修饰 | 立即删掉；只保留 H1/H2/总时长行/分隔线 |
| PDF > 20MB | 用 `--compact` flag 重跑 |
| 公式在 PDF 中未渲染 / 显示原始 LaTeX | 确认 KaTeX CDN 链接已加入 `<head>`，export-pdf.sh 会等 networkidle 确保 JS 执行完毕 |
| 公式太小看不清 | 确认用 `$$...$$` display 模式（非 inline），检查 `.katex-display > .katex` 字号为 3.8vw |
| 一页堆了多个 display 公式导致溢出 | 每页最多 1 个 display 公式，拆分为多页或改用 inline math |
