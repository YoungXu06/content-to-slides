# Content to Slides

> 把一篇文章 / 一个视频链接 / 一个 GitHub 仓库，一键变成 **横屏 4:3 暗色主题的 5–10 页讲解 slides + PDF + 每页口播讲稿**。

一个适配 Claude Code / Codex / CodeBuddy 等 Agent 环境的开源 **Skill**。全流程自闭环，不依赖任何外部 skill —— 自主生成单文件 HTML 翻页 slides，导出与布局完全一致的 PDF，并附带专业口吻的逐页口播讲稿和社媒帖文。

[English](./README.en.md) · [贡献指南](./CONTRIBUTING.md) · [LICENSE](./LICENSE)

---

## 它能产出什么

调用一次，得到三份开箱即用的交付物：

| 文件 | 说明 |
|------|------|
| `presentation.html` | 横屏 4:3 暗色主题 HTML slides，单文件，浏览器打开点击翻页 |
| `output.pdf` | 1440×1080 横屏 4:3 PDF，与 HTML 布局完全一致，可直接分享 / 录视频 |
| `script.md` | 每页对应的口播讲稿 + 末尾社媒帖文，专业口吻，可直接录制和发布 |

---

## 30 秒上手

把 skill 安装到 Agent 的 skills 目录后，直接对 Agent 说：

```
帮我把这篇文章做成 5-10 页的讲解 slides + 讲稿：<文章链接>
```

或者：

```
把这个视频的精髓总结成 PPT 讲一下：<YouTube / Bilibili 链接>
把这个 GitHub 项目做成项目讲解 deck：<github.com/owner/repo>
```

Agent 会自动：抓取内容 → 提炼精髓 → 设计大纲 → 生成 HTML → 导出 PDF → 写口播讲稿。

---

## 适合 / 不适合

**适合：**
- 把长文章、技术博客、论文、播客、视频快速做成短视频讲解脚本
- GitHub 项目的「项目概览」讲解 deck
- 需要「slides + 逐页讲稿」一起交付的内容创作场景

**不适合：**
- 需要复杂动画 / 转场的商业演示
- 严格遵循企业 VI 模板的正式汇报（本 skill 是暗色短视频风）
- 超过 10 页的长篇内容（设计上硬约束 5–10 页）

---

## 设计原则

1. **抓精髓，不抓字面** —— 先用一句话回答「这玩意到底在讲什么」，所有内容围绕它展开。
2. **5–10 页硬约束** —— 少于 5 页没信息量，多于 10 页不是短视频节奏。
3. **口播讲稿要像专业的活人** —— 气质定位：专业从业者给懂行朋友讲一件事，不是播音腔、不是自媒体腔。
4. **自主生成 HTML** —— 内置 15 种组件库 + 5 套暗色主题，不委托任何外部 skill。
5. **横屏 4:3 + 大字可读 + 点击翻页** —— 所有尺寸用 vw/vh 单位，保证浏览器和 PDF 上比例完全一致；无可见按钮，点击翻页。
6. **中文优先** —— Slides 和讲稿统一中文（专有名词保留英文），用户要求英文时例外。

---

## 安装

本 skill 是纯文件结构（`SKILL.md` + `references/` + `scripts/`），把整个目录放进 Agent 的 skills 搜索路径即可。

### 方式一：克隆到 skills 目录（推荐）

```bash
# Claude Code
git clone https://github.com/<your-name>/content-to-slides.git \
  ~/.claude/skills/content-to-slides

# CodeBuddy
git clone https://github.com/<your-name>/content-to-slides.git \
  ~/.codebuddy/skills/content-to-slides
```

### 方式二：直接放进项目内

把 `content-to-slides/` 目录拷贝到你项目的 skills 目录下，Agent 会自动发现并在匹配触发词时调用。

> SKILL.md 中的脚本会自动在以下路径查找 skill 目录：
> `~/.claude/skills`、`~/.claude-internal/skills`、`~/.codebuddy/skills`、`~/.config/skills`。

---

## 依赖

| 功能 | 依赖 | 安装 | 是否必需 |
|------|------|------|---------|
| 导出 PDF | Node.js + Playwright | 自动安装（首次运行较慢） | PDF 阶段必需 |
| YouTube 字幕 | Python3 + yt-dlp + youtube-transcript-api | 脚本自动安装 | 仅 YouTube 链接 |
| YouTube JS 挑战 | deno（可选） | `brew install deno` | 可选，提高成功率 |
| GitHub 分析 | gh CLI（首选）/ git（兜底） | `brew install gh` | 仅 GitHub 链接 |

文章 / 长文 / markdown 等纯文本内容不需要额外依赖。

---

## 工作流

```
Phase 1  确认输入与目标
Phase 2  抓取并深度解读原始内容
Phase 3  设计 5–10 页讲解大纲 + 选组件
Phase 4  自主生成 HTML slides
Phase 5  导出 PDF
Phase 6  生成每页口播讲稿
Phase 6.5 生成社媒帖文
Phase 7  交付
```

完整细节见 [SKILL.md](./SKILL.md)。

---

## 目录结构

```
content-to-slides/
├── SKILL.md                          # Skill 主文件：触发词、工作流、原则、常见错误
├── README.md                         # 中文说明（本文件）
├── README.en.md                      # 英文说明
├── CONTRIBUTING.md                   # 贡献指南
├── LICENSE                           # AGPL-3.0
├── .gitignore
├── references/                       # 分层知识库（Agent 按需读取）
│   ├── ingestion.md                  # 各类链接抓取策略与 fallback
│   ├── summarization.md              # 5 问骨架法：提炼核心论点
│   ├── slide-design.md               # 4:3 横屏组件库 + 排版规则 + HTML 模板
│   ├── themes.md                     # 5 套暗色主题预设
│   └── voice.md                      # 口播讲稿语气规则 + 禁用词
└── scripts/                          # 可执行工具
    ├── export-pdf.sh                 # PDF 导出（1440×1080 4:3）
    ├── fetch-youtube-transcript.sh   # YouTube 字幕自动下载
    ├── fetch-github-repo.sh          # GitHub 仓库自动分析
    └── parse_transcript.py           # 字幕解析（VTT/SRT → 纯文本）
```

---

## 主题预设

| 内容情绪 | 主题 |
|---------|------|
| 科普 / 理性 / 技术 | Deep Ocean |
| 哲学 / 思维 / 策略 | Midnight Gold |
| 犀利 / 争议 / 趋势 | Electric Dark |
| 自然 / 健康 / 可持续 | Forest Night |
| 叙事 / 文化 / 人文 | Warm Dusk |

主题按内容情绪自动匹配，也可在请求中显式指定覆盖。详见 [references/themes.md](./references/themes.md)。

---

## 组件库

内置 15 种 4:3 组件：Title Slide、Content Slide、Card Grid、VS Comparison、Metric Display、Info Box、Quote Block、Key Insight、Closing Slide、Step Flow、Split Text、Icon List、Highlight Banner、Formula Slide、Formula + Explanation。

布局多样性硬规则：禁止连续 2 页以上同类型组件，8 页以上必须用 ≥5 种组件。详见 [references/slide-design.md](./references/slide-design.md)。

---

## 示例请求

```
把这篇文章做成讲解 PPT + 讲稿：https://example.com/some-article
给我整理个 5-10 页的讲解，受众是从业者：<链接>
把这个视频的精髓做成短视频脚本：https://youtu.be/xxxxxxxxxxx
帮我把这个项目做成项目讲解 deck：https://github.com/owner/repo
```

---

## 常见问题

**Q：生成的 PDF 文字太小 / 和 HTML 不一致？**
A：检查是否用了固定 px 或 clamp —— 必须全部用 vw 单位。export-pdf.sh 固定 1440×1080。

**Q：视频抓不到字幕？**
A：先确认视频开启了字幕；安装 deno 可提高 yt-dlp 成功率；仍失败时手动复制视频下方「显示字幕」的文本粘贴给 Agent。

**Q：能输出英文吗？**
A：可以，在请求中明确说「输出英文」即可，默认是中文优先。

更多失败模式与修正见 [SKILL.md](./SKILL.md) 末尾的「Common Failure Modes」表。

---

## 贡献

欢迎提交组件、主题、抓取策略改进。请先读 [CONTRIBUTING.md](./CONTRIBUTING.md)。

核心约定：组件改动同步更新 `slide-design.md`；新增主题在 `themes.md` 注册；脚本保持跨 macOS / Linux 兼容。

---

## License

[AGPL-3.0](./LICENSE) © Content to Slides contributors
