# 贡献指南 · Contributing

感谢你为 **Content to Slides** 做贡献！本 skill 的本质是一套结构化的 Agent 指令 + 知识库 + 工具脚本，贡献时请保持「Agent 可读、自闭环、跨平台」三个特性。

---

## 项目结构与职责

| 路径 | 职责 | 改动时注意 |
|------|------|-----------|
| `SKILL.md` | 主入口：触发词、工作流、硬规则 | 改流程必须同步更新对应 Phase 和「Common Failure Modes」表 |
| `references/slide-design.md` | 组件库 + HTML 模板 | 新增/改组件必须在此定义完整 CSS，不能让其他文档引用未定义的类 |
| `references/themes.md` | 主题预设 | 新增主题需在此注册全部 CSS 变量 |
| `references/voice.md` | 讲稿语气规则 | 改禁用词 / 语气时同步 SKILL.md Phase 6 的自检清单 |
| `references/ingestion.md` | 抓取策略 | 新增链接类型需给出抓取 + fallback 双策略 |
| `references/summarization.md` | 提炼方法论 | — |
| `scripts/*.sh` `*.py` | 可执行工具 | 必须兼容 macOS 与 Linux；依赖缺失要有清晰报错或自动安装 |

---

## 提交前自检

### 1. 组件 / 主题改动
- 新增组件：在 `slide-design.md` 同时补齐 HTML 结构 **和** 全部 CSS 类，并在 SKILL.md Phase 3 的「内容类型 → 推荐组件」表中登记。
- 新增主题：在 `themes.md` 注册全套 CSS 变量，并在 SKILL.md Phase 4「内容情绪 → 主题」表中登记。
- 不要让 `SKILL.md` / `themes.md` 引用 `slide-design.md` 中不存在的类。

### 2. 脚本改动
- 用 `bash -n script.sh` 做语法检查。
- 保持 `set -euo pipefail`，临时目录用 `trap` 清理。
- 依赖查找走 `BASH_SOURCE` 相对定位，不要写死绝对路径。
- 跨平台：`uname` 区分 Darwin / Linux 分支。

### 3. 硬规则一致性
本 skill 有若干「🔴 硬规则」（vw 单位、≤2 栏、5–10 页、讲稿纯文本、布局多样性）。任何改动不得削弱这些规则；如确需调整，请在 PR 描述里说明理由。

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
