# 贡献指南 · Contributing

感谢你为 **Content to Slides** 做贡献！本 skill 的本质是一套结构化的 Agent 指令 + 知识库 + 工具脚本，贡献时请保持「Agent 可读、自闭环、跨平台」三个特性。

---

## 项目结构与职责

| 路径 | 职责 | 改动时注意 |
|------|------|-----------|
| `SKILL.md` | 主入口：触发词、工作流、单次输出协议 | 改流程同步对应 Phase、中英文 README 及排障边界 |
| `references/slide-design.md` | 组件库 + HTML 模板 + 前置容量 | 新增/改组件同时定义 CSS 与容量规则，不引入默认截图审阅循环 |
| `references/themes.md` | 主题预设 | 新增主题需在此注册全部 CSS 变量 |
| `references/voice.md` | 自然口播、客观视角、章节承接、TTS | 语言细则集中在此，SKILL.md 只保留原则；不重复扩展禁词表或加入字数、代词硬配额 |
| `references/ingestion.md` | 抓取策略 | 新增链接类型需给出抓取 + fallback 双策略 |
| `references/summarization.md` | 提炼方法论 | — |
| `scripts/*.sh` `*.py` | 可执行工具 | 必须兼容 macOS 与 Linux；依赖缺失要有清晰报错或自动安装 |

---

## 提交前自检

这里是维护 Skill 的开发验证，不是每次生成 PPT 后的审阅流程，不得将这些测试追加到创作工作流。

### 1. 组件 / 主题改动
- 新增组件：在 `slide-design.md` 同时补齐 HTML、CSS 和前置容量预算，与 SKILL.md Phase 3 的选型规则一致。
- 新增主题：在 `themes.md` 注册全套 CSS 变量，仍在 Phase 2 选定，不新增生成后换主题步骤。
- 不要让 `SKILL.md` / `themes.md` 引用 `slide-design.md` 中不存在的类。

### 2. 脚本改动
- 用 `bash -n script.sh` 做语法检查。
- 保持 `set -euo pipefail`，临时目录用 `trap` 清理。
- 依赖查找走 `BASH_SOURCE` 相对定位，不要写死绝对路径。
- 跨平台：`uname` 区分 Darwin / Linux 分支。

### 3. 硬规则一致性
保持 5–10 页、讲稿纯文本、布局多样性和 vw/vh 内容尺寸。文字卡片与流程最多两列，只有短数字指标允许三列；零值 reset、无单位行高和 1px 装饰边框例外与模板一致。质量约束在生成前落实，不追加成品审阅返工循环。自然讲稿保留主语、条件、连接和必要解释，不设单句字数或代词次数硬门槛。

---

## 提交流程

1. Fork 并新建分支：`git checkout -b feat/your-feature`
2. 改动后本地用一个真实链接跑一遍完整工作流（HTML + PDF + 讲稿）验证。
3. 提交信息用约定式格式：`feat: ...` / `fix: ...` / `docs: ...` / `refactor: ...`
4. 发起 PR，描述：改了什么、为什么、如何验证。

---

## 报告问题

提 Issue 时请附上：输入链接类型、期望产出、实际产出、复现步骤，以及（如涉及 PDF/抓取）相关脚本的终端输出。

---

Thanks for contributing! 让长内容更好地被讲出来。
