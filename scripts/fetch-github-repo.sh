#!/usr/bin/env bash
# fetch-github-repo.sh — Analyze a GitHub repository for slide generation
#
# Usage:
#   bash scripts/fetch-github-repo.sh <github-url-or-owner/repo> [output-dir]
#
# Examples:
#   bash scripts/fetch-github-repo.sh "https://github.com/anthropics/claude-code"
#   bash scripts/fetch-github-repo.sh "anthropics/claude-code" ./output/
#   bash scripts/fetch-github-repo.sh "https://github.com/vercel/next.js" ./my-output/
#
# What this does:
#   1. Extracts owner/repo from URL
#   2. Uses gh CLI to fetch repo metadata, README, file tree, dependencies, recent commits
#   3. Falls back to git clone --depth 1 if gh CLI unavailable
#   4. Outputs structured markdown for slide generation
#
# Output:
#   <output-dir>/repo-analysis.md — Structured analysis with metadata + README + tree + deps
#
# Dependencies:
#   - gh (GitHub CLI) — preferred, must be authenticated
#   - git — fallback for shallow clone
set -euo pipefail

# ─── Colors ────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${CYAN}ℹ${NC} $*"; }
ok()    { echo -e "${GREEN}✓${NC} $*"; }
warn()  { echo -e "${YELLOW}⚠${NC} $*"; }
err()   { echo -e "${RED}✗${NC} $*" >&2; }

# ─── Input validation ─────────────────────────────────────

if [[ $# -lt 1 ]]; then
    err "Usage: bash scripts/fetch-github-repo.sh <github-url-or-owner/repo> [output-dir]"
    err ""
    err "Examples:"
    err "  bash scripts/fetch-github-repo.sh https://github.com/anthropics/claude-code"
    err "  bash scripts/fetch-github-repo.sh anthropics/claude-code ./output/"
    exit 1
fi

INPUT="$1"
OUTPUT_DIR="${2:-.}"

# ─── Parse owner/repo ─────────────────────────────────────

# Strip trailing slashes and .git suffix
INPUT="${INPUT%/}"
INPUT="${INPUT%.git}"

if [[ "$INPUT" =~ ^https?://github\.com/([^/]+)/([^/]+) ]]; then
    OWNER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
elif [[ "$INPUT" =~ ^([^/]+)/([^/]+)$ ]]; then
    OWNER="$1"
    # Split on /
    OWNER="${INPUT%%/*}"
    REPO="${INPUT##*/}"
else
    err "Cannot parse GitHub repo from: $INPUT"
    err "Expected format: https://github.com/owner/repo or owner/repo"
    exit 1
fi

FULL_REPO="${OWNER}/${REPO}"

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║     GitHub Repo Analyzer                  ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}"
echo ""
info "Repo: ${FULL_REPO}"

# ─── Prepare output ───────────────────────────────────────

mkdir -p "$OUTPUT_DIR"
OUTPUT_FILE="${OUTPUT_DIR}/repo-analysis.md"

# ─── Strategy 1: gh CLI ──────────────────────────────────

USE_GH=false
if command -v gh &>/dev/null; then
    if gh auth status &>/dev/null 2>&1; then
        USE_GH=true
        ok "gh CLI available and authenticated"
    else
        warn "gh CLI found but not authenticated — trying anyway for public repos"
        USE_GH=true
    fi
else
    warn "gh CLI not found — will try git clone fallback"
fi

if [[ "$USE_GH" == "true" ]]; then
    info "Fetching repo metadata..."

    # ── Metadata ──
    METADATA=$(gh api "repos/${FULL_REPO}" 2>/dev/null || echo "")

    if [[ -z "$METADATA" ]]; then
        warn "gh API failed for ${FULL_REPO} — falling back to git clone"
        USE_GH=false
    else
        DESCRIPTION=$(echo "$METADATA" | gh api --jq '.description // "N/A"' --input - 2>/dev/null || echo "N/A")
        STARS=$(echo "$METADATA" | gh api --jq '.stargazers_count // 0' --input - 2>/dev/null || echo "0")
        FORKS=$(echo "$METADATA" | gh api --jq '.forks_count // 0' --input - 2>/dev/null || echo "0")
        LANGUAGE=$(echo "$METADATA" | gh api --jq '.language // "N/A"' --input - 2>/dev/null || echo "N/A")
        LICENSE=$(echo "$METADATA" | gh api --jq '.license.spdx_id // "N/A"' --input - 2>/dev/null || echo "N/A")
        TOPICS=$(echo "$METADATA" | gh api --jq '[.topics[]?] | join(", ")' --input - 2>/dev/null || echo "")
        CREATED=$(echo "$METADATA" | gh api --jq '.created_at // "N/A"' --input - 2>/dev/null || echo "N/A")
        UPDATED=$(echo "$METADATA" | gh api --jq '.updated_at // "N/A"' --input - 2>/dev/null || echo "N/A")
        HOMEPAGE=$(echo "$METADATA" | gh api --jq '.homepage // ""' --input - 2>/dev/null || echo "")
        DEFAULT_BRANCH=$(echo "$METADATA" | gh api --jq '.default_branch // "main"' --input - 2>/dev/null || echo "main")

        ok "Metadata fetched (★${STARS} | ${LANGUAGE})"

        # ── README ──
        info "Fetching README..."
        README_CONTENT=""

        # Try gh api to get README
        README_RAW=$(gh api "repos/${FULL_REPO}/readme" 2>/dev/null || echo "")
        if [[ -n "$README_RAW" ]]; then
            # The content is base64 encoded
            README_B64=$(echo "$README_RAW" | gh api --jq '.content // ""' --input - 2>/dev/null || echo "")
            if [[ -n "$README_B64" ]]; then
                README_CONTENT=$(echo "$README_B64" | base64 -d 2>/dev/null || echo "")
            fi
        fi

        # Fallback: try raw download
        if [[ -z "$README_CONTENT" ]]; then
            for readme_name in README.md readme.md README.rst README README.txt; do
                README_CONTENT=$(gh api "repos/${FULL_REPO}/contents/${readme_name}" --jq '.content' 2>/dev/null | base64 -d 2>/dev/null || echo "")
                if [[ -n "$README_CONTENT" ]]; then break; fi
            done
        fi

        if [[ -n "$README_CONTENT" ]]; then
            # Truncate if too long (keep first 15000 chars for slides)
            if [[ ${#README_CONTENT} -gt 15000 ]]; then
                README_CONTENT="${README_CONTENT:0:15000}

... (README truncated at 15000 chars for slide generation)"
            fi
            ok "README fetched (${#README_CONTENT} chars)"
        else
            warn "README not found or empty"
        fi

        # ── File tree ──
        info "Fetching directory structure..."
        FILE_TREE=""
        TREE_RAW=$(gh api "repos/${FULL_REPO}/git/trees/${DEFAULT_BRANCH}?recursive=1" 2>/dev/null || echo "")
        if [[ -n "$TREE_RAW" ]]; then
            FILE_TREE=$(echo "$TREE_RAW" | gh api --jq '[.tree[]? | select(.type == "blob" or .type == "tree") | .path] | sort | .[:200] | .[]' --input - 2>/dev/null || echo "")
            TOTAL_FILES=$(echo "$TREE_RAW" | gh api --jq '[.tree[]? | select(.type == "blob")] | length' --input - 2>/dev/null || echo "0")
            ok "File tree fetched (${TOTAL_FILES} files)"
        else
            warn "Could not fetch file tree"
        fi

        # ── Dependency files ──
        info "Checking dependency/config files..."
        DEP_CONTENT=""
        DEP_FILES=("package.json" "Cargo.toml" "pyproject.toml" "go.mod" "requirements.txt" "Gemfile" "pom.xml" "build.gradle" "setup.py" "setup.cfg" "composer.json" "mix.exs" "deno.json")

        for dep_file in "${DEP_FILES[@]}"; do
            dep_raw=$(gh api "repos/${FULL_REPO}/contents/${dep_file}" --jq '.content' 2>/dev/null | base64 -d 2>/dev/null || echo "")
            if [[ -n "$dep_raw" ]]; then
                # Truncate large dep files
                if [[ ${#dep_raw} -gt 3000 ]]; then
                    dep_raw="${dep_raw:0:3000}
... (truncated)"
                fi
                DEP_CONTENT="${DEP_CONTENT}
### ${dep_file}

\`\`\`
${dep_raw}
\`\`\`
"
                ok "Found ${dep_file}"
            fi
        done

        if [[ -z "$DEP_CONTENT" ]]; then
            warn "No standard dependency files found"
            DEP_CONTENT="No standard dependency files (package.json, Cargo.toml, etc.) detected."
        fi

        # ── Recent commits ──
        info "Fetching recent commits..."
        COMMITS=""
        COMMITS_RAW=$(gh api "repos/${FULL_REPO}/commits?per_page=10" 2>/dev/null || echo "")
        if [[ -n "$COMMITS_RAW" ]]; then
            COMMITS=$(echo "$COMMITS_RAW" | gh api --jq '.[]? | "- \(.commit.message | split("\n")[0]) (\(.commit.author.date | .[0:10]))"' --input - 2>/dev/null || echo "")
            ok "Recent commits fetched"
        fi

        # ── Write output ──
        info "Assembling analysis..."

        cat > "$OUTPUT_FILE" << ANALYSIS_EOF
# GitHub 仓库分析: ${FULL_REPO}

## 基本信息

- **名称**: ${REPO}
- **全名**: ${FULL_REPO}
- **描述**: ${DESCRIPTION}
- **Stars**: ${STARS} | **Forks**: ${FORKS} | **主语言**: ${LANGUAGE}
- **License**: ${LICENSE}
- **Topics**: ${TOPICS:-无}
- **创建时间**: ${CREATED} | **最近更新**: ${UPDATED}
- **主页**: ${HOMEPAGE:-无}
- **GitHub**: https://github.com/${FULL_REPO}

---

## README

${README_CONTENT:-README 未找到或为空。}

---

## 目录结构

共 ${TOTAL_FILES:-未知} 个文件（显示前 200 个路径）：

\`\`\`
${FILE_TREE:-无法获取目录结构}
\`\`\`

---

## 依赖 / 技术栈

${DEP_CONTENT}

---

## 最近活动（最近 10 次提交）

${COMMITS:-无法获取提交记录}

ANALYSIS_EOF

        ok "Analysis written to: ${OUTPUT_FILE}"
    fi
fi

# ─── Strategy 2: git clone fallback ───────────────────────

if [[ "$USE_GH" == "false" ]]; then
    info "Trying git clone --depth 1..."

    TEMP_CLONE=$(mktemp -d)
    CLONE_URL="https://github.com/${FULL_REPO}.git"

    if git clone --depth 1 "$CLONE_URL" "$TEMP_CLONE/repo" 2>/dev/null; then
        ok "Shallow clone succeeded"
        CLONE_DIR="$TEMP_CLONE/repo"

        # ── README ──
        README_CONTENT=""
        for readme_name in README.md readme.md README.rst README README.txt; do
            if [[ -f "$CLONE_DIR/$readme_name" ]]; then
                README_CONTENT=$(head -c 15000 "$CLONE_DIR/$readme_name")
                break
            fi
        done

        # ── File tree (find, limited to 200 entries) ──
        FILE_TREE=$(cd "$CLONE_DIR" && find . -not -path './.git/*' -not -path './.git' | sort | head -200 | sed 's|^\./||')
        TOTAL_FILES=$(cd "$CLONE_DIR" && find . -not -path './.git/*' -not -path './.git' -type f | wc -l | tr -d ' ')

        # ── Dependencies ──
        DEP_CONTENT=""
        DEP_FILES=("package.json" "Cargo.toml" "pyproject.toml" "go.mod" "requirements.txt" "Gemfile" "pom.xml" "build.gradle" "setup.py" "setup.cfg" "composer.json" "mix.exs" "deno.json")
        for dep_file in "${DEP_FILES[@]}"; do
            if [[ -f "$CLONE_DIR/$dep_file" ]]; then
                dep_raw=$(head -c 3000 "$CLONE_DIR/$dep_file")
                DEP_CONTENT="${DEP_CONTENT}
### ${dep_file}

\`\`\`
${dep_raw}
\`\`\`
"
            fi
        done
        if [[ -z "$DEP_CONTENT" ]]; then
            DEP_CONTENT="No standard dependency files detected."
        fi

        # ── Recent commits ──
        COMMITS=$(cd "$CLONE_DIR" && git log --oneline -10 2>/dev/null || echo "N/A")

        # ── Write output ──
        cat > "$OUTPUT_FILE" << CLONE_EOF
# GitHub 仓库分析: ${FULL_REPO}

## 基本信息

- **名称**: ${REPO}
- **全名**: ${FULL_REPO}
- **GitHub**: https://github.com/${FULL_REPO}
- *(通过 git clone 获取，元数据有限)*

---

## README

${README_CONTENT:-README 未找到或为空。}

---

## 目录结构

共约 ${TOTAL_FILES} 个文件（显示前 200 个路径）：

\`\`\`
${FILE_TREE:-无法获取目录结构}
\`\`\`

---

## 依赖 / 技术栈

${DEP_CONTENT}

---

## 最近活动

\`\`\`
${COMMITS}
\`\`\`

CLONE_EOF

        ok "Analysis written to: ${OUTPUT_FILE}"

        # Cleanup
        rm -rf "$TEMP_CLONE"
    else
        # Clone also failed
        rm -rf "$TEMP_CLONE"
        err "git clone failed for ${FULL_REPO}"
        err ""
        err "Possible reasons:"
        err "  - Repository is private (need authentication)"
        err "  - Repository doesn't exist"
        err "  - Network issue"
        err ""
        err "Fallback: Use WebFetch on https://github.com/${FULL_REPO}"
        err "Or ask the user to provide the README / key files manually."

        # Write minimal output
        cat > "$OUTPUT_FILE" << FAIL_EOF
# GitHub 仓库分析: ${FULL_REPO}

## 基本信息

- **全名**: ${FULL_REPO}
- **GitHub**: https://github.com/${FULL_REPO}
- **状态**: 自动抓取失败，需要手动补充内容

---

## README

⚠ 无法自动获取。请使用 WebFetch 工具抓取 https://github.com/${FULL_REPO} 页面内容，
或请用户提供 README 或关键文件内容。

FAIL_EOF

        warn "Minimal output written — manual content needed"
    fi
fi

# ─── Summary ──────────────────────────────────────────────

echo ""
echo -e "${BOLD}════════════════════════════════════════════${NC}"
ok "GitHub repo analysis complete!"
echo ""
echo -e "  ${BOLD}Repo:${NC}   ${FULL_REPO}"
echo -e "  ${BOLD}Output:${NC} ${OUTPUT_FILE}"
if [[ -f "$OUTPUT_FILE" ]]; then
    FILE_SIZE=$(wc -c < "$OUTPUT_FILE" | tr -d ' ')
    echo -e "  ${BOLD}Size:${NC}   ${FILE_SIZE} bytes"
fi
echo ""
echo -e "${BOLD}════════════════════════════════════════════${NC}"
echo ""
