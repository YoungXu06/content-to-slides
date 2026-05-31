#!/usr/bin/env python3
"""parse_transcript.py — Parse YouTube subtitles into clean plain text.

Modes:
  --mode vtt     Parse a .vtt file (WebVTT format from yt-dlp)
  --mode srt     Parse a .srt file (SubRip format from yt-dlp)
  --mode api     Use youtube-transcript-api to fetch transcript by video ID

Usage:
  python3 parse_transcript.py --mode vtt --input subs.vtt --output transcript.txt
  python3 parse_transcript.py --mode srt --input subs.srt --output transcript.txt
  python3 parse_transcript.py --mode api --input VIDEO_ID --output transcript.txt [--langs en,zh-Hans,zh]
"""

import argparse
import re
import sys
import json
from pathlib import Path


def parse_vtt(filepath: str) -> str:
    """Parse WebVTT (.vtt) file into clean text."""
    content = Path(filepath).read_text(encoding="utf-8")
    lines = content.split("\n")

    text_lines = []
    seen = set()
    in_header = True

    for line in lines:
        line = line.strip()

        # Skip WebVTT header
        if in_header:
            if line == "" and not any(l.startswith("WEBVTT") for l in lines[:3]):
                in_header = False
            elif line == "" or line.startswith("WEBVTT") or line.startswith("Kind:") or line.startswith("Language:") or line.startswith("NOTE"):
                continue
            else:
                in_header = False

        # Skip timestamp lines (00:00:00.000 --> 00:00:05.000)
        if re.match(r"\d{2}:\d{2}[:\.][\d.]+ --> \d{2}:\d{2}[:\.][\d.]+", line):
            continue

        # Skip numeric cue identifiers
        if re.match(r"^\d+$", line):
            continue

        # Skip empty lines
        if not line:
            continue

        # Skip positioning tags like <c>, </c>, align:start position:0%
        if re.match(r"^(align|position|size|line):", line):
            continue

        # Remove HTML/VTT tags like <c>, </c>, <00:00:01.234>, etc.
        cleaned = re.sub(r"<[^>]+>", "", line)
        cleaned = cleaned.strip()

        if not cleaned:
            continue

        # Deduplicate (auto-captions often repeat lines)
        if cleaned not in seen:
            seen.add(cleaned)
            text_lines.append(cleaned)

    # Join into paragraphs — group every ~5 sentences for readability
    return join_into_paragraphs(text_lines)


def parse_srt(filepath: str) -> str:
    """Parse SubRip (.srt) file into clean text."""
    content = Path(filepath).read_text(encoding="utf-8")
    lines = content.split("\n")

    text_lines = []
    seen = set()

    for line in lines:
        line = line.strip()

        # Skip sequence numbers
        if re.match(r"^\d+$", line):
            continue

        # Skip timestamp lines
        if re.match(r"\d{2}:\d{2}:\d{2},\d{3} --> \d{2}:\d{2}:\d{2},\d{3}", line):
            continue

        # Skip empty
        if not line:
            continue

        # Remove HTML tags
        cleaned = re.sub(r"<[^>]+>", "", line)
        cleaned = cleaned.strip()

        if not cleaned:
            continue

        if cleaned not in seen:
            seen.add(cleaned)
            text_lines.append(cleaned)

    return join_into_paragraphs(text_lines)


def fetch_via_api(video_id: str, langs: list[str] = None) -> str:
    """Fetch transcript using youtube-transcript-api."""
    try:
        from youtube_transcript_api import YouTubeTranscriptApi
    except ImportError:
        print("ERROR: youtube-transcript-api not installed. Run: pip3 install youtube-transcript-api", file=sys.stderr)
        sys.exit(1)

    if langs is None:
        langs = ["en", "zh-Hans", "zh", "zh-Hant", "ja", "ko"]

    try:
        # youtube-transcript-api >= 1.0.0 uses instance-based API
        ytt_api = YouTubeTranscriptApi()

        # First try: direct fetch with language priority
        try:
            entries = ytt_api.fetch(video_id, languages=langs)
            text_lines = []
            seen = set()

            for entry in entries:
                text = entry.text if hasattr(entry, 'text') else entry.get('text', '')
                # Clean up auto-caption artifacts
                text = re.sub(r"\[.*?\]", "", text)  # Remove [Music], [Applause], etc.
                text = text.replace("\n", " ").strip()
                if text and text not in seen:
                    seen.add(text)
                    text_lines.append(text)

            return join_into_paragraphs(text_lines)
        except Exception as e_fetch:
            # Fallback: list transcripts and try any available
            try:
                transcript_list = ytt_api.list(video_id)
                transcript = None

                # Try to find transcript in preferred languages
                for lang in langs:
                    try:
                        transcript = transcript_list.find_transcript([lang])
                        break
                    except Exception:
                        continue

                # If no preferred language, try generated transcripts
                if transcript is None:
                    try:
                        transcript = transcript_list.find_generated_transcript(langs)
                    except Exception:
                        # Last resort: get whatever is available
                        for t in transcript_list:
                            transcript = t
                            break

                if transcript is None:
                    raise Exception(f"No transcript found. Initial error: {e_fetch}")

                entries = transcript.fetch()
                text_lines = []
                seen = set()

                for entry in entries:
                    text = entry.text if hasattr(entry, 'text') else entry.get('text', '')
                    text = re.sub(r"\[.*?\]", "", text)
                    text = text.replace("\n", " ").strip()
                    if text and text not in seen:
                        seen.add(text)
                        text_lines.append(text)

                return join_into_paragraphs(text_lines)
            except Exception as e_list:
                raise Exception(f"Both fetch and list failed. fetch: {e_fetch}, list: {e_list}")

    except Exception as e:
        print(f"ERROR: youtube-transcript-api failed: {e}", file=sys.stderr)
        sys.exit(1)


def join_into_paragraphs(lines: list[str], sentences_per_paragraph: int = 5) -> str:
    """Join text lines into readable paragraphs."""
    if not lines:
        return ""

    # First, join all lines into continuous text
    full_text = " ".join(lines)

    # Clean up multiple spaces
    full_text = re.sub(r"\s+", " ", full_text).strip()

    # Split by sentence boundaries for paragraph grouping
    # Handle both English (. ! ?) and Chinese (。！？) sentence endings
    sentences = re.split(r"(?<=[.!?。！？])\s+", full_text)

    if not sentences:
        return full_text

    paragraphs = []
    current = []

    for sent in sentences:
        current.append(sent)
        if len(current) >= sentences_per_paragraph:
            paragraphs.append(" ".join(current))
            current = []

    if current:
        paragraphs.append(" ".join(current))

    return "\n\n".join(paragraphs)


def main():
    parser = argparse.ArgumentParser(description="Parse YouTube subtitles into clean text")
    parser.add_argument("--mode", required=True, choices=["vtt", "srt", "api"],
                        help="Parse mode: vtt, srt, or api")
    parser.add_argument("--input", required=True,
                        help="Input file path (for vtt/srt) or video ID (for api)")
    parser.add_argument("--output", required=True,
                        help="Output file path for clean transcript")
    parser.add_argument("--langs", default="en,zh-Hans,zh,zh-Hant",
                        help="Comma-separated language codes for api mode (default: en,zh-Hans,zh,zh-Hant)")

    args = parser.parse_args()

    if args.mode == "vtt":
        if not Path(args.input).exists():
            print(f"ERROR: File not found: {args.input}", file=sys.stderr)
            sys.exit(1)
        text = parse_vtt(args.input)
    elif args.mode == "srt":
        if not Path(args.input).exists():
            print(f"ERROR: File not found: {args.input}", file=sys.stderr)
            sys.exit(1)
        text = parse_srt(args.input)
    elif args.mode == "api":
        langs = [l.strip() for l in args.langs.split(",")]
        text = fetch_via_api(args.input, langs)

    if not text:
        print("ERROR: No transcript content extracted.", file=sys.stderr)
        sys.exit(1)

    # Write output
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(text, encoding="utf-8")

    # Report stats
    word_count = len(text.split())
    char_count = len(text)
    print(f"OK: Transcript extracted ({char_count} chars, ~{word_count} words) -> {args.output}")


if __name__ == "__main__":
    main()
