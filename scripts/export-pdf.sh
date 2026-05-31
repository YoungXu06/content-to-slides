#!/usr/bin/env bash
# export-pdf.sh — Export landscape HTML slides to PDF (4:3 aspect ratio)
#
# Usage:
#   bash scripts/export-pdf.sh <path-to-html> [output.pdf] [--compact]
#
# Examples:
#   bash scripts/export-pdf.sh ./presentation.html
#   bash scripts/export-pdf.sh ./presentation.html ./output.pdf
#   bash scripts/export-pdf.sh ./presentation.html --compact
#
# What this does:
#   1. Starts a local server to serve the HTML (fonts need HTTP)
#   2. Uses Playwright to screenshot each slide at 1440x1080 (4:3 landscape)
#   3. Combines all screenshots into a single PDF
#   4. Cleans up the server and temp files
#
# Output is landscape 4:3 — optimized for maximum text readability.
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

# ─── Parse flags ──────────────────────────────────────────

# Default: 1440x1080 (4:3 landscape — maximum text readability)
# Compact: 1024x768 (4:3 landscape — smaller file size)
VIEWPORT_W=1440
VIEWPORT_H=1080
COMPACT=false

POSITIONAL=()
for arg in "$@"; do
    case $arg in
        --compact)
            COMPACT=true
            VIEWPORT_W=1024
            VIEWPORT_H=768
            ;;
        *)
            POSITIONAL+=("$arg")
            ;;
    esac
done
set -- "${POSITIONAL[@]}"

# ─── Input validation ─────────────────────────────────────

if [[ $# -lt 1 ]]; then
    err "Usage: bash scripts/export-pdf.sh <path-to-html> [output.pdf] [--compact]"
    err ""
    err "Examples:"
    err "  bash scripts/export-pdf.sh ./presentation.html"
    err "  bash scripts/export-pdf.sh ./presentation.html ./slides.pdf"
    err "  bash scripts/export-pdf.sh ./presentation.html --compact   # smaller file"
    exit 1
fi

INPUT_HTML="$1"
if [[ ! -f "$INPUT_HTML" ]]; then
    err "File not found: $INPUT_HTML"
    exit 1
fi

# Resolve to absolute path
INPUT_HTML=$(cd "$(dirname "$INPUT_HTML")" && pwd)/$(basename "$INPUT_HTML")

# Output PDF path
if [[ $# -ge 2 ]]; then
    OUTPUT_PDF="$2"
else
    OUTPUT_PDF="$(dirname "$INPUT_HTML")/$(basename "$INPUT_HTML" .html).pdf"
fi

# Resolve output to absolute path
OUTPUT_DIR=$(dirname "$OUTPUT_PDF")
mkdir -p "$OUTPUT_DIR"
OUTPUT_PDF="$(cd "$OUTPUT_DIR" && pwd)/$(basename "$OUTPUT_PDF")"

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║     Export Slides to PDF (4:3)            ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}"
echo ""

# ─── Step 1: Check dependencies ───────────────────────────

info "Checking dependencies..."

if ! command -v npx &>/dev/null; then
    err "Node.js is required but not installed."
    err "  macOS:   brew install node"
    err "  or visit https://nodejs.org"
    exit 1
fi

ok "Node.js found"

# ─── Step 2: Create the export script ─────────────────────

TEMP_DIR=$(mktemp -d)
TEMP_SCRIPT="$TEMP_DIR/export-slides.mjs"

SERVE_DIR=$(dirname "$INPUT_HTML")
HTML_FILENAME=$(basename "$INPUT_HTML")

cat > "$TEMP_SCRIPT" << 'EXPORT_SCRIPT'
import { chromium } from 'playwright';
import { createServer } from 'http';
import { readFileSync, existsSync, mkdirSync, unlinkSync, writeFileSync } from 'fs';
import { join, extname, resolve } from 'path';

const SERVE_DIR = process.argv[2];
const HTML_FILE = process.argv[3];
const OUTPUT_PDF = process.argv[4];
const SCREENSHOT_DIR = process.argv[5];
const VP_WIDTH = parseInt(process.argv[6]) || 1440;
const VP_HEIGHT = parseInt(process.argv[7]) || 1080;

// ─── Simple static file server ────────────────────────────

const MIME_TYPES = {
  '.html': 'text/html',
  '.css': 'text/css',
  '.js': 'application/javascript',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.webp': 'image/webp',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.ttf': 'font/ttf',
  '.eot': 'application/vnd.ms-fontobject',
};

const server = createServer((req, res) => {
  const decodedUrl = decodeURIComponent(req.url);
  let filePath = join(SERVE_DIR, decodedUrl === '/' ? HTML_FILE : decodedUrl);
  try {
    const content = readFileSync(filePath);
    const ext = extname(filePath).toLowerCase();
    res.writeHead(200, { 'Content-Type': MIME_TYPES[ext] || 'application/octet-stream' });
    res.end(content);
  } catch {
    res.writeHead(404);
    res.end('Not found');
  }
});

const port = await new Promise((resolve) => {
  server.listen(0, () => resolve(server.address().port));
});

console.log(`  Local server on port ${port}`);

// ─── Screenshot each slide ────────────────────────────────

const browser = await chromium.launch();
const page = await browser.newPage({
  viewport: { width: VP_WIDTH, height: VP_HEIGHT },
});

await page.goto(`http://localhost:${port}/`, { waitUntil: 'networkidle' });
await page.evaluate(() => document.fonts.ready);
await page.waitForTimeout(1500);

const slideCount = await page.evaluate(() => {
  return document.querySelectorAll('.slide').length;
});

console.log(`  Found ${slideCount} slides`);

if (slideCount === 0) {
  console.error('  ERROR: No .slide elements found.');
  await browser.close();
  server.close();
  process.exit(1);
}

mkdirSync(SCREENSHOT_DIR, { recursive: true });
const screenshotPaths = [];

for (let i = 0; i < slideCount; i++) {
  await page.evaluate((index) => {
    const slides = document.querySelectorAll('.slide');
    slides.forEach((slide, idx) => {
      if (idx === index) {
        slide.style.display = '';
        slide.style.opacity = '1';
        slide.style.visibility = 'visible';
        slide.style.position = 'relative';
        slide.style.transform = 'none';
        slide.classList.add('active');
      } else {
        slide.style.display = 'none';
        slide.classList.remove('active');
      }
    });

    if (window.presentation && typeof window.presentation.goToSlide === 'function') {
      window.presentation.goToSlide(index);
    }

    // Update page indicator for PDF screenshot (if present)
    const currentPageEl = document.getElementById('currentPage');
    if (currentPageEl) {
      currentPageEl.textContent = index + 1;
    }
    const totalPagesEl = document.getElementById('totalPages');
    if (totalPagesEl) {
      totalPagesEl.textContent = slides.length;
    }

    slides[index]?.scrollIntoView({ behavior: 'instant' });
  }, i);

  await page.waitForTimeout(300);
  await page.waitForTimeout(200);

  await page.evaluate((index) => {
    const slides = document.querySelectorAll('.slide');
    const currentSlide = slides[index];
    if (currentSlide) {
      currentSlide.querySelectorAll('.reveal').forEach(el => {
        el.style.opacity = '1';
        el.style.transform = 'none';
        el.style.visibility = 'visible';
      });
    }
  }, i);

  await page.waitForTimeout(100);

  const screenshotPath = join(SCREENSHOT_DIR, `slide-${String(i + 1).padStart(3, '0')}.png`);
  await page.screenshot({ path: screenshotPath, fullPage: false });
  screenshotPaths.push(screenshotPath);
  console.log(`  Captured slide ${i + 1}/${slideCount}`);
}

await browser.close();
server.close();

// ─── Combine screenshots into PDF ─────────────────────────

console.log('  Assembling PDF...');

const browser2 = await chromium.launch();
const pdfPage = await browser2.newPage({
  viewport: { width: VP_WIDTH, height: VP_HEIGHT },
});

const imagesHtml = screenshotPaths.map((p) => {
  const imgData = readFileSync(p).toString('base64');
  return `<div class="page"><img src="data:image/png;base64,${imgData}" /></div>`;
}).join('\n');

const pdfHtml = `<!DOCTYPE html>
<html>
<head>
<style>
  * { margin: 0; padding: 0; }
  @page { size: ${VP_WIDTH}px ${VP_HEIGHT}px; margin: 0; }
  .page {
    width: ${VP_WIDTH}px;
    height: ${VP_HEIGHT}px;
    page-break-after: always;
    overflow: hidden;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .page:last-child { page-break-after: auto; }
  img {
    width: 100%;
    height: 100%;
    display: block;
  }
</style>
</head>
<body>${imagesHtml}</body>
</html>`;

await pdfPage.setContent(pdfHtml, { waitUntil: 'load' });
await pdfPage.pdf({
  path: OUTPUT_PDF,
  width: `${VP_WIDTH}px`,
  height: `${VP_HEIGHT}px`,
  printBackground: true,
  margin: { top: 0, right: 0, bottom: 0, left: 0 },
  scale: 1,
});

await browser2.close();

screenshotPaths.forEach(p => unlinkSync(p));

console.log(`  ✓ PDF saved to: ${OUTPUT_PDF}`);
EXPORT_SCRIPT

# ─── Step 3: Install Playwright in temp directory ──────────

info "Setting up Playwright (headless browser for screenshots)..."
info "This may take a moment on first run..."
echo ""

cd "$TEMP_DIR"

cat > "$TEMP_DIR/package.json" << 'PKG'
{ "name": "slide-export-portrait", "private": true, "type": "module" }
PKG

npm install playwright &>/dev/null || {
    err "Failed to install Playwright."
    rm -rf "$TEMP_DIR"
    exit 1
}

npx playwright install chromium 2>/dev/null || {
    err "Failed to install Chromium browser."
    rm -rf "$TEMP_DIR"
    exit 1
}
ok "Playwright ready"
echo ""

# ─── Step 4: Run the export ───────────────────────────────

SCREENSHOT_DIR="$TEMP_DIR/screenshots"

info "Exporting portrait slides to PDF..."
echo ""

if [[ "$COMPACT" == "true" ]]; then
    info "Using compact mode (720×1280) for smaller file size"
fi

node "$TEMP_SCRIPT" "$SERVE_DIR" "$HTML_FILENAME" "$OUTPUT_PDF" "$SCREENSHOT_DIR" "$VIEWPORT_W" "$VIEWPORT_H" || {
    err "PDF export failed."
    rm -rf "$TEMP_DIR"
    exit 1
}

# ─── Step 5: Cleanup and success ──────────────────────────

rm -rf "$TEMP_DIR"

echo ""
echo -e "${BOLD}════════════════════════════════════════════${NC}"
ok "PDF exported successfully!"
echo ""
echo -e "  ${BOLD}File:${NC}  $OUTPUT_PDF"
echo ""
FILE_SIZE=$(du -h "$OUTPUT_PDF" | cut -f1 | xargs)
echo "  Size: $FILE_SIZE"
echo "  Format: ${VIEWPORT_W}×${VIEWPORT_H} (4:3)"
echo ""
echo "  Ready for sharing and video production."
echo -e "${BOLD}════════════════════════════════════════════${NC}"
echo ""

if command -v open &>/dev/null; then
    open "$OUTPUT_PDF"
elif command -v xdg-open &>/dev/null; then
    xdg-open "$OUTPUT_PDF"
fi
