# Content Ingestion Strategies

各类输入链接/文件的抓取策略与 fallback。**核心原则：宁可停下问用户，也不要凭想象补内容。**

## Table of Contents

- [文章 / 博客 / 论文网页](#文章--博客--论文网页)
- [YouTube 视频](#youtube-视频)
- [Bilibili 视频](#bilibili-视频)
- [播客 (Apple Podcasts, Spotify, 小宇宙)](#播客)
- [Twitter/X / 知乎 / 公众号](#twitterx--知乎--公众号)
- [PDF 论文](#pdf-论文)
- [GitHub 仓库](#github-仓库)
- [已有文件（md / txt / docx）](#已有文件)
- [什么时候必须停下问用户](#什么时候必须停下问用户)

---

## 文章 / 博客 / 论文网页

```text
Tool: WebFetch
Prompt 模板:
  "Extract the full article text. Also return:
   - Title
   - Author(s)
   - Publish date (if visible)
   - 3 most memorable or quotable sentences verbatim
   Preserve code blocks, lists, and key headings. Skip nav/ads/comments/footer."
```

### 失败情况

- 403 / Cloudflare 拦截：告知用户"这个网站挡住了自动抓取，请把正文贴过来"
- 需要登录（Medium paywall、部分 Substack）：同上
- 动态渲染的 SPA（内容靠 JS 渲染）：WebFetch 可能拿到空壳。如果 WebFetch 返回的文本明显过短（< 500 字）或看起来像导航骨架，停下问用户

---

## YouTube 视频

### 优先策略：自动脚本下载字幕

```bash
# 定位 skill 目录
SKILL_DIR=""
for p in "$HOME/.claude-internal/skills/content-to-slides" \
         "$HOME/.claude/skills/content-to-slides"; do
  [ -d "$p/scripts" ] && SKILL_DIR="$p" && break
done

# 执行字幕下载（输出到指定目录）
bash "$SKILL_DIR/scripts/fetch-youtube-transcript.sh" "<YouTube-URL>" "<输出目录>"
```

脚本会自动：
1. 提取视频 ID
2. 使用 **yt-dlp** 下载字幕（优先手动字幕，其次自动生成字幕）
3. 若 yt-dlp 失败，**fallback 到 youtube-transcript-api**
4. 解析字幕为纯文本，输出 `<输出目录>/transcript.txt`

输出文件格式：
```text
# Video Metadata
Title: <视频标题>
Channel: <频道名>
Duration: <时长>
Upload Date: <上传日期>
Language: <字幕语言>
Video URL: <链接>

# Transcript

<纯文本字幕内容，按段落分隔>
```

### Fallback 策略

```text
策略 2 (WebFetch): 如果脚本失败（如视频无字幕），尝试 WebFetch 抓取页面描述和 shownotes
策略 3 (用户协助): 提示用户打开视频下方的 "Show transcript"，复制粘贴
```

### 脚本依赖

首次使用时会自动安装（pip3 install）：
- `yt-dlp` — 命令行视频工具，支持下载字幕
- `youtube-transcript-api` — Python 库，直接调用 YouTube 字幕 API

### 失败时停下的情况

- 脚本输出 `transcript.txt` 但字符数 < 500：可能字幕不完整，需确认
- 脚本报错退出（视频无字幕/私密/年龄限制）：走用户协助
- 网络超时：重试一次后走用户协助

**不要**凭视频标题 + 描述 + 频道名拼凑内容。这是幻觉温床。

---

## Bilibili 视频

B 站通常抓不到逐字稿，优先走用户协助：

> "B 站的字幕需要登录才能拿到完整版。你可以：
> 1. 打开视频后点右下角字幕按钮，复制 AI 字幕文本贴给我；或
> 2. 用 bilibili-subtitle 等第三方工具导出字幕后发给我；或
> 3. 直接把这个视频的核心观点/要点用一两段话描述给我，我按你的描述来做。"

拿到字幕后再继续。不要因为"链接在这就假装看过了"。

---

## 播客

Apple Podcasts / Spotify / 小宇宙 / 喜马拉雅 —— 播客普遍没有公开逐字稿。

```text
策略 1: WebFetch 链接页，抽取节目介绍、嘉宾、核心话题、shownotes（如果有）
策略 2: 如果 shownotes 详实，可以直接基于 shownotes 做解读（但要在交付时注明"基于节目简介 + shownotes 制作"）
策略 3: 如果只有标题和一句介绍，停下问用户要转录稿 / AI 摘要 / 核心观点
```

---

## Twitter/X / 知乎 / 公众号

- **X/Twitter 长推文**：WebFetch 可抓，注意要完整抓取 thread 而不只是首推
- **知乎回答**：WebFetch 通常可以，paywall 答案除外
- **微信公众号**：经常挡抓取。挡了就让用户粘贴原文

---

## PDF 论文

```text
如果用户给了 PDF 本地路径:
  → 用 Read 工具直接读 PDF（注意大 PDF 要分页读：Read 的 pages 参数）
如果是 arxiv.org/abs/... 或 arxiv.org/pdf/... URL:
  → WebFetch abstract 页拿 title/authors/abstract
  → 如果需要正文，让用户下载 PDF 后本地读
```

长论文（>10 页）优先读 Abstract + Introduction + Conclusion + 各节首段，不要全文读完。本 skill 只需要"精髓"，不需要细节。

---

## GitHub 仓库

```text
Tool: fetch-github-repo.sh + gh CLI / git clone
输出: <输出目录>/repo-analysis.md
```

### Strategy 1: 自动脚本（推荐）

```bash
bash "$SKILL_DIR/scripts/fetch-github-repo.sh" "<GitHub-URL>" "<输出目录>"
```

使用 `gh` CLI 获取仓库元数据（stars/forks/language/topics）、README 全文、目录结构（前 200 文件）、依赖文件（package.json / Cargo.toml / pyproject.toml 等）和最近 10 次 commit。

需要 gh 已安装且已认证。对公开仓库，gh 未认证时脚本自动 fallback 到 Strategy 2。

### Strategy 2: 浅克隆（自动 fallback）

如果 gh CLI 不可用或 API 调用失败，脚本自动执行 `git clone --depth 1`，然后本地读取 README 和关键文件。

无需手动操作——脚本内部已实现 fallback 链。

### Strategy 3: WebFetch + 用户协助

如果克隆也失败（私有仓库 / 网络问题），脚本输出最小化文件并提示：

1. 用 WebFetch 抓取 `https://github.com/<owner>/<repo>` 页面获取基础描述
2. 请用户提供 README 内容或本地克隆路径

### 失败阈值

- README < 200 字符 → 警告用户项目文档不足，确认是否仅基于有限信息继续
- 无法获取任何文件内容 → 停下来，请用户提供本地克隆路径或粘贴 README
- 和其他内容类型一样：**绝不凭仓库名和描述幻想项目功能**

### 讲解重点（项目概览方向）

分析 repo-analysis.md 内容时，优先回答以下问题：

1. 这个项目**解决什么问题**？（从 README 开头提炼）
2. **核心架构和技术栈**是什么？（从目录结构 + 依赖推断）
3. **关键功能/特性**有哪些？（从 README features 章节提取）
4. **怎么用**？（安装和使用方式）
5. 项目的**独特价值/亮点**是什么？（对比同类项目的差异化）

---

## 已有文件

```text
Read <path>
```

Markdown / txt / docx 直接读。超过 2000 行的长文用 offset/limit 分段读；先读头尾定位结构，再读中段补细节。

---

## 什么时候必须停下问用户

出现下面任一情况，**立刻停下**，告知用户情况并索要材料，不要开始 Phase 3：

1. WebFetch 返回的正文 < 500 字但用户明显期待一篇长文/长视频
2. 拿到的内容看起来是导航骨架、错误页、登录墙
3. 视频类链接没有拿到任何字幕 / 转录 / 详实 shownotes
4. 内容明显只是标题 + 一句介绍
5. 抓到的语种与预期不符（比如预期中文文章却抓出一堆 JS 变量名）

**停下时的话术模板**（直接、不卑微）：

> "这个链接我这边只抓到 [实际情况]，做不出有信息量的讲解。你可以：
> 1. 把正文/字幕/转录稿贴过来；或
> 2. 用一段话告诉我核心观点，我按你的概括来做。"
