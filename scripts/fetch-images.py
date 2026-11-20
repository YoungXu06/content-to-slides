#!/usr/bin/env python3
"""从网页 / PDF 里挑出值得放进 slide 的图，并记录它属于哪一节。

图片最容易出的问题不是抓不到，而是图文错位：把第 2 节的架构图放到讲第 5 节
的页面上。所以每张图都同时输出它最近的标题链和上下文，生成时据此判断能否
用在同一页。

用法：
    python3 scripts/fetch-images.py <来源 URL 或本地 HTML/PDF> <输出目录> [--max 6]

输出：
    <输出目录>/images/*            下载后的图片
    <输出目录>/images/manifest.json 来源、所属章节、尺寸、说明力标记

失败策略：单张失败只跳过，不影响整体；没有可用图时写空 manifest，由调用方
退化为纯文字页。
"""
import argparse
import hashlib
import json
import mimetypes
import os
import re
import sys
import urllib.parse
import urllib.request

MAX_BYTES = 8 * 1024 * 1024
MIN_EDGE_PX = 240
USER_AGENT = 'Mozilla/5.0 (compatible; content-to-slides/1.0)'

DROP_URL_HINTS = (
    'logo', 'avatar', 'icon', 'sprite', 'badge', 'emoji', 'favicon',
    'advert', 'tracking', 'pixel.gif', 'spacer',
)
DROP_ALT_HINTS = ('logo', 'avatar', 'icon', 'profile picture')

HIGH_VALUE_HINTS = (
    'architecture', 'diagram', 'pipeline', 'workflow', 'flowchart',
    'benchmark', 'result', 'metric', 'chart', 'graph', 'plot', 'figure',
    'table', 'comparison', '架构', '流程', '指标', '曲线', '对比', '结果',
)


def _log(msg):
    print(msg, file=sys.stderr)


def _clean(text):
    return re.sub(r'\s+', ' ', (text or '')).strip()


def _is_decorative(url, alt):
    low_url = (url or '').lower()
    low_alt = (alt or '').lower()
    if any(h in low_url for h in DROP_URL_HINTS):
        return True
    return any(low_alt.startswith(h) for h in DROP_ALT_HINTS)


def _value_hint(url, alt, caption):
    blob = f'{url} {alt} {caption}'.lower()
    return any(h in blob for h in HIGH_VALUE_HINTS)


def _download(url, dest_dir, index):
    if url.startswith('file://'):
        src = urllib.request.url2pathname(urllib.parse.urlparse(url).path)
        if not os.path.isfile(src):
            raise ValueError('file not found')
        blob = open(src, 'rb').read(MAX_BYTES + 1)
        if len(blob) > MAX_BYTES:
            raise ValueError('too large')
        if len(blob) == 0:
            raise ValueError('empty file')
        ext = os.path.splitext(src)[1].lower() or '.png'
        name = '%02d-%s%s' % (index, hashlib.sha1(url.encode()).hexdigest()[:8], ext)
        path = os.path.join(dest_dir, name)
        with open(path, 'wb') as handle:
            handle.write(blob)
        return path, len(blob)

    request = urllib.request.Request(url, headers={'User-Agent': USER_AGENT})
    with urllib.request.urlopen(request, timeout=20) as resp:
        declared = resp.headers.get('Content-Length')
        if declared and int(declared) > MAX_BYTES:
            raise ValueError('too large')
        blob = resp.read(MAX_BYTES + 1)
    if len(blob) > MAX_BYTES:
        raise ValueError('too large')
    if len(blob) == 0:
        raise ValueError('empty response')

    ext = os.path.splitext(urllib.parse.urlparse(url).path)[1].lower()
    if ext not in ('.png', '.jpg', '.jpeg', '.webp', '.gif'):
        ext = mimetypes.guess_extension(resp.headers.get_content_type() or '') or '.png'
        ext = '.jpg' if ext in ('.jpe', '.jpeg') else ext

    name = '%02d-%s%s' % (index, hashlib.sha1(url.encode()).hexdigest()[:8], ext)
    path = os.path.join(dest_dir, name)
    with open(path, 'wb') as handle:
        handle.write(blob)
    return path, len(blob)


def _image_size(path):
    try:
        from PIL import Image  # type: ignore
    except ImportError:
        return None
    try:
        with Image.open(path) as img:
            return img.size
    except Exception:
        return None


_HEADING_RE = re.compile(r'<h([1-3])[^>]*>(.*?)</h\1>', re.I | re.S)
_FIGURE_RE = re.compile(r'<figure[^>]*>(.*?)</figure>', re.I | re.S)
_IMG_RE = re.compile(r'<img\b[^>]*>', re.I)
_SRC_RE = re.compile(r'\bsrc\s*=\s*["\']([^"\']+)["\']', re.I)
_ALT_RE = re.compile(r'\balt\s*=\s*["\']([^"\']*)["\']', re.I)
_CAP_RE = re.compile(r'<figcaption[^>]*>(.*?)</figcaption>', re.I | re.S)
_TAG_RE = re.compile(r'<[^>]+>')


def extract_from_html(html, base_url):
    """按文档顺序返回候选图，附带章节标题与上下文。"""
    sections = [
        (m.start(), _clean(_TAG_RE.sub('', m.group(2))))
        for m in _HEADING_RE.finditer(html)
    ]

    def section_for(pos):
        current = ''
        for start, text in sections:
            if start <= pos:
                current = text
            else:
                break
        return current

    captions = {}
    for fig in _FIGURE_RE.finditer(html):
        cap = _CAP_RE.search(fig.group(1))
        if not cap:
            continue
        text = _clean(_TAG_RE.sub('', cap.group(1)))
        for img in _IMG_RE.finditer(fig.group(1)):
            captions[fig.start(1) + img.start()] = text

    out = []
    for img in _IMG_RE.finditer(html):
        src = _SRC_RE.search(img.group(0))
        if not src:
            continue
        raw = src.group(1).strip()
        if raw.startswith('data:'):
            continue
        if raw.lower().startswith(('http://', 'https://', 'file://')):
            url = raw
        elif base_url.lower().startswith(('http://', 'https://')):
            url = urllib.parse.urljoin(base_url, raw)
        else:
            # 本地 HTML 的相对路径：按源文件所在目录解析
            url = 'file://' + os.path.abspath(os.path.join(base_url or '.', raw))
        alt_m = _ALT_RE.search(img.group(0))
        pos = img.start()
        out.append({
            'url': url,
            'alt': _clean(alt_m.group(1)) if alt_m else '',
            'caption': captions.get(pos, ''),
            'section': section_for(pos),
            'context': _clean(_TAG_RE.sub('', html[max(0, pos - 400):pos]))[-200:],
        })
    return out


def extract_from_pdf(path):
    """PDF：取嵌入位图，记录所在页。"""
    try:
        import fitz  # PyMuPDF
    except ImportError:
        _log('[images] PyMuPDF not installed; skip PDF extraction')
        return []

    out = []
    with fitz.open(path) as doc:
        for page_no, page in enumerate(doc, start=1):
            for info in page.get_images(full=True):
                out.append({
                    'url': 'pdf://%s#%d' % (path, info[0]),
                    'alt': '',
                    'caption': '',
                    'section': '第 %d 页' % page_no,
                    'context': '',
                    'pdf_page': page_no,
                    'xref': info[0],
                })
    return out


def fetch_source(source):
    if source.startswith(('http://', 'https://')):
        request = urllib.request.Request(source, headers={'User-Agent': USER_AGENT})
        with urllib.request.urlopen(request, timeout=25) as resp:
            html = resp.read(4 * 1024 * 1024).decode('utf-8', 'replace')
        return extract_from_html(html, source)
    if source.lower().endswith('.pdf'):
        return extract_from_pdf(source)
    with open(source, encoding='utf-8', errors='replace') as handle:
        # 以文件所在目录为基准解析相对路径图片
        return extract_from_html(handle.read(), os.path.dirname(os.path.abspath(source)))


def save_pdf_image(item, dest_dir, index):
    import fitz
    src = item['url'].split('#')[0].replace('pdf://', '', 1)
    with fitz.open(src) as doc:
        pix = doc.extract_image(item['xref'])
    path = os.path.join(
        dest_dir, '%02d-pdf%d.%s' % (index, item['pdf_page'], pix.get('ext', 'png'))
    )
    with open(path, 'wb') as handle:
        handle.write(pix['image'])
    return path, len(pix['image'])


def main(argv):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source', help='URL / 本地 HTML / PDF')
    parser.add_argument('outdir', help='输出目录（会创建 images/）')
    parser.add_argument('--max', type=int, default=6, help='最多保留几张')
    args = parser.parse_args(argv)

    dest = os.path.join(args.outdir, 'images')
    os.makedirs(dest, exist_ok=True)

    try:
        candidates = fetch_source(args.source)
    except Exception as exc:
        _log('[images] cannot read source: %s' % exc)
        candidates = []

    manifest = []
    seen = set()
    for item in candidates:
        if len(manifest) >= args.max:
            break
        if item['url'] in seen:
            continue
        seen.add(item['url'])
        if _is_decorative(item['url'], item.get('alt')):
            continue

        entry = {
            'source_url': item['url'],
            'alt': item.get('alt', ''),
            'caption': item.get('caption', ''),
            'section': item.get('section', ''),
            'context': item.get('context', ''),
            'high_value': _value_hint(
                item['url'], item.get('alt', ''), item.get('caption', '')
            ),
        }
        try:
            if item['url'].startswith('pdf://'):
                path, size = save_pdf_image(item, dest, len(manifest) + 1)
            else:
                path, size = _download(item['url'], dest, len(manifest) + 1)
            dims = _image_size(path)
            if dims and max(dims) < MIN_EDGE_PX:
                os.remove(path)
                continue
            entry.update({
                'file': os.path.relpath(path, args.outdir),
                'bytes': size,
                'width': dims[0] if dims else None,
                'height': dims[1] if dims else None,
            })
        except Exception as exc:
            _log('[images] skip %s: %s' % (item['url'][:80], exc))
            continue
        manifest.append(entry)

    manifest_path = os.path.join(dest, 'manifest.json')
    with open(manifest_path, 'w', encoding='utf-8') as handle:
        json.dump(manifest, handle, ensure_ascii=False, indent=2)

    print('%d image(s) -> %s' % (len(manifest), manifest_path))
    for entry in manifest:
        flag = 'HIGH' if entry['high_value'] else '    '
        print('  %s %s  [%s]' % (flag, entry['file'], entry['section'][:40]))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
