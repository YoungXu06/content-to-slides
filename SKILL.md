---
name: content-to-slides
description: Turn an article, video, GitHub repository or long-form content into a 5-10 page landscape 4:3 dark-theme HTML slide deck, PDF and per-slide speaker script. Chinese-first unless another language is requested. Load content, design and voice rules before generation; plan once, generate the deck and natural TTS-ready narration together, export once, then deliver without review-rewrite loops. Use for requests such as "把这篇文章/这个视频做成 PPT 讲一下", "给我整理个 5-10 页的讲解", "链接精髓做成讲稿 + slides + PDF", "做成短视频脚本", "summarize into a deck", or "explainer deck".
---

# Content to Slides

把长内容变成横屏 4:3、5–10 页的讲解素材包。自主生成，不委托外部生成或审阅 skill。

## 交付物

- `presentation.html`：单文件暗色 HTML slides，点击翻页，页面顺序固定。
- `output.pdf`：用自带脚本导出横屏 4:3 PDF，默认画布 1440×1080。
- `script.md`：与页面编号、标题和事实对应的逐页口播，加末尾社媒帖文。口播正文直接用于 TTS，其他结构不朗读。

## 执行协议：前置规划，单次输出，成功即交付

**以下协议覆盖参考文件中任何关于生成后自检、调整、润色、重写或重导出的建议。**

1. 所有内容、语言、布局和读法要求在生成最终文件之前加载并确定。
2. 完成一份共同的逐页规划，HTML 和讲稿使用同一份规划。规划可以调整，但不能先落盘最终 PPT/讲稿再回头修。
3. `presentation.html` 与 `script.md` 各生成一次，PDF 导出一次。成功后直接交付，不创建审阅或优化阶段。
4. 不回读成品找改进点，不跑禁词/格式 grep，不截图审美检查，不试播后润色，不调用评审 agent，不追加“检查 → 修改 → 再检查”的循环。
5. 导出脚本逐页截图是生成 PDF 的正常步骤，不是审稿；允许其状态输出和文件存在性检查，不据此开启内容返工。
6. 原始材料不足、运行依赖缺失或导出失败时，明确报告阻塞和已有产物，不伪报成功，不自动重写整套内容或无限重试。用户要求修复、修改或明确的执行错误处理不等于默认创作流程。

质量通过规划、保守容量和复用模板降低风险。单次输出是执行约束，不能将“已加载规则”表述成“保证成品绝无错误”。

## 核心原则

- 一条清楚的主线，每页回答一个具体问题；不靠固定九页套路、强制悬念或金句填页。
- 默认中文，包括页面文案、口播和标签；官方产品名、专名、必要缩写可以保留。用户指定其他语言时遵从。
- 讲稿是自然的解释，不是压缩摘要。保留主语、条件、因果和必要术语说明，避免电报式碎句。
- 客观不等于冷淡。可以自然使用“你”“我们”“如果”“但”“所以”“也就是说”，不限制次数；不训导听众，不煽动，不编造事实。
- 默认不使用“不是A，而是B”“真正的X是Y”“反直觉的是”“更狠的是”等否定—重定义或夸张包装：整篇最多 1 次，且有依据才用。具体语言原则和改写示例见 [references/voice.md](references/voice.md)，不重复扩展禁词表。
- 复用现有 15 种组件与 5 套主题。页面字体、间距和内容尺寸使用 vw/vh，禁止 `clamp()` 和固定 px 字号，不通过缩小正文塞入超量内容。
- 5–10 页是交付范围，不能为了凑页数补造事实；材料不足时在生成前说明。

## 工作流

```
Phase 1   确认输入、受众和输出目录
Phase 2   获取来源、加载规则、理解内容
Phase 3   建立共同的逐页规划
Phase 3.5 生成前一次确认并冻结规划
Phase 4   按共同规划生成讲稿、社媒帖文和 HTML
Phase 5   单次导出 PDF
Phase 7   直接交付
```

没有独立的生成后讲稿润色、HTML 验收或社媒审稿阶段。

## Phase 1: 确认目标

从请求中提取输入类型、受众、语言和目录。默认受众为聪明但非本专业的普通观众，目录为 `./content-to-slides-output/<短标题-slug>/`。

缺少必需输入时一次问清；默认值可用时直接继续。不额外追问主题、页数或审批大纲，除非用户要求。

## Phase 2: 获取与理解

### 先加载规则

生成之前读取：

1. [references/ingestion.md](references/ingestion.md)：按来源类型获取实质文本。
2. [references/summarization.md](references/summarization.md)：确定核心、支撑和证据边界。
3. [references/voice.md](references/voice.md)：自然口播、章节承接和 TTS 文本。
4. [references/slide-design.md](references/slide-design.md)：组件、字体、容量和完整 HTML 模板。
5. [references/themes.md](references/themes.md)：选定主题和字体。

已经完整加载的规则复用，不反复读取宣誓“熟记”。具体来源所需内容可继续获取，但不要生成到一半才补读声音或布局规则。

### 自动获取路径

用实际加载的 skill 目录作为 `<skill-dir>`。若环境未提供目录，在生成前定位一次并复用：

```bash
SKILL_DIR=""
for p in "$HOME/.claude/skills/content-to-slides" \
         "$HOME/.claude-internal/skills/content-to-slides" \
         "$HOME/.codebuddy/skills/content-to-slides" \
         "$HOME/.config/skills/content-to-slides"; do
  [ -d "$p/scripts" ] && SKILL_DIR="$p" && break
done
```

YouTube：

```bash
bash "<skill-dir>/scripts/fetch-youtube-transcript.sh" "<YouTube-URL>" "<输出目录>"
```

成功后读取输出目录的 `transcript.txt`；失败按 ingestion.md 的 fallback 处理。

GitHub：

```bash
bash "<skill-dir>/scripts/fetch-github-repo.sh" "<GitHub-URL>" "<输出目录>"
```

成功后读取 `repo-analysis.md`；失败按 ingestion.md 的 fallback 处理。讲项目时优先说明问题、架构、功能、使用方式和有证据的差异，不把 README 宣传词当成比较结果。

**没有实质文本就停止并索要材料，不凭标题、摘要或项目名称编内容。** 在本阶段确认事实、假设、结论与限制；疑点不能留到生成后再修改。

## Phase 3: 共同的逐页规划

内部建立一份页级表，不单独创建规划文档，不先写成品。每页确定：

| 字段 | 生成前要决定的事 |
|------|------------------|
| 编号与标题 | 页序、一个明确问题、中文可见标题 |
| 来源与结论 | 支撑事实、出处、适用范围；未知事项不补造 |
| 屏幕文字 | 要显示的最终标题、条目、数字、标签及必要出处 |
| 讲稿内容 | 谁在做什么、为什么、术语如何解释；不只是照读条目 |
| 页间关系 | 与前页的因果、例子、步骤、比较或范围联系；不强制造因果 |
| 组件与容量 | 选定现有组件、栏数、条目数和预计行数 |
| TTS 读法 | 名称、数字、单位、公式的口语表达，保留准确含义 |

常见理解顺序：场景或问题 → 必要概念 → 机制与依据 → 例子或结果 → 限制与结论。按材料选择 5–10 页，不强制单列“关键判断”“行动”“金句”页。

### 前置容量预算

以下限制只约束 slides 可见文字，**不能把讲稿压成同样的短标签**。复杂解释留给口播。

- 每页一个主组件；标题最多两行。普通标题优先一行，首尾页允许有意留白。
- 内容页默认 3–4 条，每条最多两行；采用 5 条时每条只放一行，不同时叠加长信息框。
- 卡片页两列、最多四张，每张短标题加两行以内说明；长说明在规划阶段移到讲稿。
- 流程最多四步，超过两步用两列网格按编号阅读；不横排三四张文字卡片。
- 数字指标默认两个；仅短数字和短标签允许三个，不附长段描述。
- 信息框全宽单列。公式页最多一个 display 公式及简短变量说明，讲稿解释意义。
- 使用组件库的既定字号、行高和间距。预留约两行正文的垂直余量，不填满每个角落；`overflow: hidden` 不能作为容量控制手段。
- 全篇纯 bullet 页占比不超过 50%，连续相同主组件最多两页，8 页以上至少五种组件。提前选型，不为追求多样性制造新论点。

## Phase 3.5: 一次确认，冻结规划

**只针对尚未生成的规划做一次前置确认：**

1. 来源足以支持核心内容，事实、可能性与条件没有混淆。
2. 页序符合听众的理解顺序，术语有解释，过渡有实际内容。
3. 屏幕文案已按容量预算取舍；页数、主题、组件及编号已经确定。
4. 讲稿按自然解释展开；不为减字删除必要主语、连接词和范围限定。
5. 讲稿没有把「否定—重定义」当骨架：通篇“不是A，而是B”“真正的X是Y”这类句式不超过 1 次，
   其余段落用具体事实正面说明（规则见 [references/voice.md](references/voice.md) 4.1）。
6. HTML 模板、TTS 读法、脚本路径和导出模式已确定。只有明确的小文件要求时，首次导出就选择 `--compact`。

若未满足，在此阶段补全规划或报告材料阻塞。满足后简短说明页数和主线，直接生成，不反复确认、不将整份规则输出给用户。

## Phase 4: 按共同规划生成

### 4.1 讲稿与社媒帖文

先依据共同规划写完整的 `script.md`，使讲解自然展开；HTML 使用同一份规划的页面文案。不要另建“短句版”“润色版”，不再从生成好的 PPT 临时提炼第二套讲稿。

```markdown
# 讲稿：<标题>

> 共 N 页 · 预估口播时长约 X 分钟

## Slide 1 · <页标题>

<完整口播纯文本段落>

---

## Slide 2 · <页标题>

<与上页自然接续的口播纯文本段落>

---

## 社媒帖文

<一段正文，参考 50–100 字>

#标签1 #标签2 #标签3
```

按 voice.md 生成：普通页约 100–180 字为参考，不设短句硬阈值和代词配额。篇幅不足时减少次要分支，不删逻辑。首尾可以正常收束，不要求每页结尾留疑问。

**写的时候就不要用否定—重定义句式。** 每页落笔前确认：本页要讲的事实是什么，直接用
陈述讲出来；不要先设想「别人以为……其实……」再转折。这是写作约束，不是生成后的检查
环节——写完不回读、不扫描、不改写，按单次输出协议交付。

只把 `Slide N` 下的口播正文作为该页的 TTS 输入，标题、总时长、分隔线、社媒帖文及标签都不朗读。

### 4.2 HTML

复用已经加载的完整模板和组件 CSS，一次写出 `presentation.html`：

- head 包含 charset、viewport、主题字体；有公式时加入 KaTeX 及自动渲染，没有公式就省略。
- 主题变量与组件 CSS 内联；每页一个 `.slide`，编号、标题与共同规划一致。
- 每页右上角水印式页码，前一两页可有 category tag；用 accent 色区分关键词。
- 字体与内容间距使用 vw/vh；字体回退保留中文系统字体。不要另创需要调试的新布局系统。
- 点击左侧 40% 上一页、右侧 60% 下一页，支持方向键、Space、Home、End 和触摸滑动；没有可见按钮及底部页码条。
- 数学式使用 KaTeX 的 display 或 inline 写法，密度遵守规划。

写完即进入导出，**不回读 HTML、截图巡视、调整字号、增删页、重新写稿或安排验收任务**。

## Phase 5: 单次导出 PDF

```bash
bash "<skill-dir>/scripts/export-pdf.sh" "<输出目录>/presentation.html" "<输出目录>/output.pdf"
```

已在规划中选择 compact 时，在首次调用末尾加 `--compact`，画布为 1024×768。不因审美或文件体积自动重跑；报告实际尺寸即可。

截图、等待字体和公式加载、合并 PDF 都是导出动作，不作内容评审。成功后进入交付；失败时说明错误及已生成的 HTML/讲稿，不自动推倒重写，也不把失败输出称为完成。

## Phase 7: 直接交付

列出实际生成文件的绝对路径、页数、导出模式和讲稿预估时长，再给一句话核心。没有生成或导出失败的文件如实说明。

不要附加“我再检查一下”“最后优化一轮”“质量审核通过”等没有必要或没有依据的步骤及声明。

## Supporting Files

| 文件 | 用途 | 读取时机 |
|------|------|----------|
| [references/ingestion.md](references/ingestion.md) | 来源获取与 fallback | Phase 2 |
| [references/summarization.md](references/summarization.md) | 核心、证据和逐页推理 | Phase 2 |
| [references/voice.md](references/voice.md) | 自然口播、亲和性、承接、TTS | Phase 2，生成前加载 |
| [references/slide-design.md](references/slide-design.md) | 15 种组件与模板、前置容量 | Phase 2，生成前加载 |
| [references/themes.md](references/themes.md) | 5 套主题与字体 | Phase 2，生成前确定 |
| [scripts/fetch-youtube-transcript.sh](scripts/fetch-youtube-transcript.sh) | 下载 YouTube 字幕 | Phase 2 按来源调用 |
| [scripts/fetch-github-repo.sh](scripts/fetch-github-repo.sh) | 获取仓库分析 | Phase 2 按来源调用 |
| [scripts/parse_transcript.py](scripts/parse_transcript.py) | VTT/SRT 转文本 | 获取脚本调用 |
| [scripts/export-pdf.sh](scripts/export-pdf.sh) | 截图合成 PDF，不审稿 | Phase 5 单次调用 |
| [scripts/check_voice.py](scripts/check_voice.py) | 统计否定—重定义句式用量 | 仅人工抽查 / 排障，不进入默认流程 |

## 排障边界

此节仅在用户报告问题或出现明确运行错误时使用，不是每次创作的默认检查清单。

- 来源抓取失败：按 ingestion.md 获取文本，仍失败则索要材料。
- 正文拥挤：下次规划减少屏幕文字，解释留给讲稿；不采用生成后反复缩字号的方法。
- 讲稿生硬：在规划时保留场景、主语、条件和连接，参考 voice.md 的用户示例；不追加短句压缩或润色循环。
- 公式或字体加载失败：如实说明运行问题，用户要求修复后再处理。
- 导出失败：保留已生成产物、报告失败，不自动开启“检查—重写—重导出”。
