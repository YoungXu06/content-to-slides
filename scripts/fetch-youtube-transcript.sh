#!/usr/bin/env bash
# fetch-youtube-transcript.sh — Download YouTube video transcript automatically
#
# Usage:
#   bash scripts/fetch-youtube-transcript.sh <youtube-url-or-video-id> [output-dir]
#
# Examples:
#   bash scripts/fetch-youtube-transcript.sh "https://www.youtube.com/watch?v=96jN2OCOfLs"
#   bash scripts/fetch-youtube-transcript.sh "96jN2OCOfLs" ./output/
#   bash scripts/fetch-youtube-transcript.sh "https://youtu.be/96jN2OCOfLs" ./my-output/
#
# What this does:
#   1. Extracts video ID from URL
#   2. Uses yt-dlp to download subtitles (manual + auto-generated)
#   3. Falls back to youtube-transcript-api if yt-dlp fails
#   4. Parses subtitles into clean plain text
#   5. Outputs metadata + transcript file
#
# Output:
#   <output-dir>/transcript.txt — Clean plain text transcript with metadata header
#
# Dependencies (auto-installed if missing):
#   - yt-dlp (pip3 install yt-dlp)
#   - youtube-transcript-api (pip3 install youtube-transcript-api)
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

# ─── Locate skill directory ───────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

# ─── Parse arguments ──────────────────────────────────────
if [ $# -lt 1 ]; then
    err "Usage: bash $0 <youtube-url-or-video-id> [output-dir]"
    exit 1
fi

INPUT="$1"
OUTPUT_DIR="${2:-.}"

# ─── Extract Video ID ─────────────────────────────────────
extract_video_id() {
    local input="$1"
    local video_id=""

    # Full YouTube URL: https://www.youtube.com/watch?v=XXXXX
    if echo "$input" | grep -qE "youtube\.com/watch\?v="; then
        video_id=$(echo "$input" | sed -E 's/.*[?&]v=([a-zA-Z0-9_-]{11}).*/\1/')
    # Short URL: https://youtu.be/XXXXX
    elif echo "$input" | grep -qE "youtu\.be/"; then
        video_id=$(echo "$input" | sed -E 's/.*youtu\.be\/([a-zA-Z0-9_-]{11}).*/\1/')
    # YouTube embed: https://www.youtube.com/embed/XXXXX
    elif echo "$input" | grep -qE "youtube\.com/embed/"; then
        video_id=$(echo "$input" | sed -E 's/.*youtube\.com\/embed\/([a-zA-Z0-9_-]{11}).*/\1/')
    # Direct video ID (11 characters)
    elif echo "$input" | grep -qE "^[a-zA-Z0-9_-]{11}$"; then
        video_id="$input"
    else
        err "Cannot extract video ID from: $input"
        exit 1
    fi

    echo "$video_id"
}

VIDEO_ID=$(extract_video_id "$INPUT")
info "Video ID: ${BOLD}${VIDEO_ID}${NC}"

# ─── Create output directory ──────────────────────────────
mkdir -p "$OUTPUT_DIR"
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# ─── Phase 1: Check dependencies ─────────────────────────
info "Phase 1: Checking dependencies..."

# Check Python3
if ! command -v python3 &>/dev/null; then
    err "Python3 is required but not found."
    exit 1
fi

# Check/install yt-dlp
if ! command -v yt-dlp &>/dev/null && ! python3 -c "import yt_dlp" 2>/dev/null; then
    warn "yt-dlp not found. Installing..."
    pip3 install yt-dlp --quiet
fi

# Check/install youtube-transcript-api
if ! python3 -c "from youtube_transcript_api import YouTubeTranscriptApi" 2>/dev/null; then
    warn "youtube-transcript-api not found. Installing..."
    pip3 install youtube-transcript-api --quiet
fi

# Check for deno (needed for yt-dlp JS challenge solving)
if ! command -v deno &>/dev/null; then
    warn "deno not found. yt-dlp works best with deno for JS challenge solving."
    warn "Install with: brew install deno (macOS) or see https://deno.land"
fi

ok "Dependencies ready"

# ─── Detect browser for cookies ───────────────────────────
BROWSER_COOKIE=""

# macOS: check for browser data directories
if [ "$(uname)" = "Darwin" ]; then
    if [ -d "$HOME/Library/Application Support/Google/Chrome" ]; then
        BROWSER_COOKIE="chrome"
    elif [ -d "$HOME/Library/Application Support/Firefox" ]; then
        BROWSER_COOKIE="firefox"
    elif [ -d "$HOME/Library/Application Support/BraveSoftware/Brave-Browser" ]; then
        BROWSER_COOKIE="brave"
    elif [ -d "$HOME/Library/Application Support/Microsoft Edge" ]; then
        BROWSER_COOKIE="edge"
    fi
else
    # Linux: check common paths
    if [ -d "$HOME/.config/google-chrome" ]; then
        BROWSER_COOKIE="chrome"
    elif [ -d "$HOME/.config/chromium" ]; then
        BROWSER_COOKIE="chromium"
    elif [ -d "$HOME/.mozilla/firefox" ]; then
        BROWSER_COOKIE="firefox"
    fi
fi

if [ -n "$BROWSER_COOKIE" ]; then
    info "Will use cookies from: $BROWSER_COOKIE"
else
    warn "No browser detected for cookie extraction. YouTube may block requests."
fi

# ─── Phase 2: Fetch video metadata ───────────────────────
info "Phase 2: Fetching video metadata..."

TITLE=""
CHANNEL=""
DURATION=""
UPLOAD_DATE=""

# Use yt-dlp to get metadata (JSON)
if command -v yt-dlp &>/dev/null; then
    METADATA_CMD="yt-dlp"
else
    METADATA_CMD="python3 -m yt_dlp"
fi

# Build metadata flags (same cookies/remote-components as subtitle download)
METADATA_EXTRA_FLAGS=""
if [ -n "$BROWSER_COOKIE" ]; then
    METADATA_EXTRA_FLAGS="--cookies-from-browser $BROWSER_COOKIE"
fi
if command -v deno &>/dev/null; then
    METADATA_EXTRA_FLAGS="$METADATA_EXTRA_FLAGS --remote-components ejs:github"
fi

METADATA_JSON=$($METADATA_CMD $METADATA_EXTRA_FLAGS --dump-json --skip-download "https://www.youtube.com/watch?v=${VIDEO_ID}" 2>/dev/null || echo "")

if [ -n "$METADATA_JSON" ]; then
    TITLE=$(echo "$METADATA_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('title',''))" 2>/dev/null || echo "")
    CHANNEL=$(echo "$METADATA_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('channel','') or d.get('uploader',''))" 2>/dev/null || echo "")
    DURATION_SEC=$(echo "$METADATA_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('duration',0))" 2>/dev/null || echo "0")
    UPLOAD_DATE=$(echo "$METADATA_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('upload_date',''))" 2>/dev/null || echo "")

    if [ -n "$DURATION_SEC" ] && [ "$DURATION_SEC" != "0" ]; then
        HOURS=$((DURATION_SEC / 3600))
        MINUTES=$(( (DURATION_SEC % 3600) / 60 ))
        SECONDS=$((DURATION_SEC % 60))
        if [ "$HOURS" -gt 0 ]; then
            DURATION="${HOURS}h ${MINUTES}m ${SECONDS}s"
        else
            DURATION="${MINUTES}m ${SECONDS}s"
        fi
    fi

    if [ -n "$UPLOAD_DATE" ] && [ ${#UPLOAD_DATE} -eq 8 ]; then
        UPLOAD_DATE="${UPLOAD_DATE:0:4}-${UPLOAD_DATE:4:2}-${UPLOAD_DATE:6:2}"
    fi

    ok "Metadata: ${BOLD}${TITLE}${NC}"
    info "  Channel: $CHANNEL"
    info "  Duration: $DURATION"
    info "  Upload: $UPLOAD_DATE"
else
    warn "Could not fetch metadata (will continue with transcript extraction)"
fi

# ─── Phase 3: Strategy 1 — yt-dlp subtitle download ──────
info "Phase 3: Attempting yt-dlp subtitle download..."

TRANSCRIPT_TEXT=""
SUBTITLE_LANG=""
YT_DLP_SUCCESS=false

# Build yt-dlp command
if command -v yt-dlp &>/dev/null; then
    YT_DLP_CMD="yt-dlp"
else
    YT_DLP_CMD="python3 -m yt_dlp"
fi

# Build cookie and remote-components flags
YT_DLP_EXTRA_FLAGS=""
if [ -n "$BROWSER_COOKIE" ]; then
    YT_DLP_EXTRA_FLAGS="--cookies-from-browser $BROWSER_COOKIE"
fi
# Add remote-components for JS challenge solving (needed for YouTube)
if command -v deno &>/dev/null; then
    YT_DLP_EXTRA_FLAGS="$YT_DLP_EXTRA_FLAGS --remote-components ejs:github"
fi

# First try: manual subtitles (higher quality)
$YT_DLP_CMD \
    $YT_DLP_EXTRA_FLAGS \
    --write-subs \
    --sub-langs "en,zh-Hans,zh,zh-Hant,ja,ko" \
    --sub-format "vtt/srt/best" \
    --skip-download \
    --no-warnings \
    -o "${TEMP_DIR}/subs" \
    "https://www.youtube.com/watch?v=${VIDEO_ID}" 2>/dev/null || true

# Check if manual subs were downloaded
SUBTITLE_FILE=$(find "$TEMP_DIR" -name "subs*.vtt" -o -name "subs*.srt" 2>/dev/null | head -1)

# If no manual subs, try auto-generated
if [ -z "$SUBTITLE_FILE" ]; then
    info "  No manual subtitles found, trying auto-generated..."
    $YT_DLP_CMD \
        $YT_DLP_EXTRA_FLAGS \
        --write-auto-subs \
        --sub-langs "en,zh-Hans,zh,zh-Hant,ja,ko" \
        --sub-format "vtt/srt/best" \
        --skip-download \
        --no-warnings \
        -o "${TEMP_DIR}/autosubs" \
        "https://www.youtube.com/watch?v=${VIDEO_ID}" 2>/dev/null || true

    SUBTITLE_FILE=$(find "$TEMP_DIR" -name "autosubs*.vtt" -o -name "autosubs*.srt" 2>/dev/null | head -1)
fi

# Parse the subtitle file if found
if [ -n "$SUBTITLE_FILE" ] && [ -f "$SUBTITLE_FILE" ]; then
    ok "  Subtitle file found: $(basename "$SUBTITLE_FILE")"

    # Detect format
    if echo "$SUBTITLE_FILE" | grep -q "\.vtt$"; then
        PARSE_MODE="vtt"
    else
        PARSE_MODE="srt"
    fi

    # Detect language from filename
    SUBTITLE_LANG=$(echo "$(basename "$SUBTITLE_FILE")" | sed -E 's/.*\.([a-zA-Z-]+)\.(vtt|srt)$/\1/' || echo "unknown")

    # Parse subtitle file
    python3 "${SCRIPT_DIR}/parse_transcript.py" \
        --mode "$PARSE_MODE" \
        --input "$SUBTITLE_FILE" \
        --output "${TEMP_DIR}/parsed_transcript.txt"

    if [ -f "${TEMP_DIR}/parsed_transcript.txt" ]; then
        TRANSCRIPT_TEXT=$(cat "${TEMP_DIR}/parsed_transcript.txt")
        YT_DLP_SUCCESS=true
        ok "  yt-dlp strategy succeeded (lang: ${SUBTITLE_LANG})"
    fi
fi

# ─── Phase 4: Strategy 2 — youtube-transcript-api fallback ─
if [ "$YT_DLP_SUCCESS" = false ]; then
    warn "yt-dlp subtitle download failed. Falling back to youtube-transcript-api..."

    python3 "${SCRIPT_DIR}/parse_transcript.py" \
        --mode api \
        --input "$VIDEO_ID" \
        --output "${TEMP_DIR}/api_transcript.txt" 2>&1 || true

    if [ -f "${TEMP_DIR}/api_transcript.txt" ]; then
        TRANSCRIPT_TEXT=$(cat "${TEMP_DIR}/api_transcript.txt")
        SUBTITLE_LANG="auto-detected"
        ok "  youtube-transcript-api fallback succeeded"
    fi
fi

# ─── Phase 5: Validate and output ────────────────────────
if [ -z "$TRANSCRIPT_TEXT" ]; then
    err "Failed to extract transcript using both strategies."
    err ""
    err "Possible causes:"
    err "  - Video has no subtitles/captions enabled"
    err "  - Video is private or age-restricted"
    err "  - Network issues"
    err ""
    err "Fallback: Please open the video, click 'Show transcript' below the video,"
    err "          and paste the text content manually."
    exit 1
fi

# Check minimum content threshold
CHAR_COUNT=${#TRANSCRIPT_TEXT}
if [ "$CHAR_COUNT" -lt 200 ]; then
    warn "Transcript is very short ($CHAR_COUNT chars). Content may be incomplete."
fi

# ─── Phase 6: Write output file ──────────────────────────
info "Phase 6: Writing output..."

OUTPUT_FILE="${OUTPUT_DIR}/transcript.txt"

cat > "$OUTPUT_FILE" << HEREDOC
# Video Metadata
Title: ${TITLE}
Channel: ${CHANNEL}
Duration: ${DURATION}
Upload Date: ${UPLOAD_DATE}
Language: ${SUBTITLE_LANG}
Video URL: https://www.youtube.com/watch?v=${VIDEO_ID}

# Transcript

${TRANSCRIPT_TEXT}
HEREDOC

ok "Done!"
echo ""
echo -e "${GREEN}${BOLD}Output:${NC} ${OUTPUT_FILE}"
echo -e "${CYAN}Stats:${NC} ${CHAR_COUNT} characters, ~$(echo "$TRANSCRIPT_TEXT" | wc -w | tr -d ' ') words"
echo ""
