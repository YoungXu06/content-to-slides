#!/usr/bin/env python3
"""检查讲稿里否定—重定义句式的用量。

用途：验收或抽查已有 script.md，不参与默认生成流程。生成时按
references/voice.md 的规则直接写，不写完再回头扫描——SKILL.md 的单次
输出协议优先。

阈值：整篇最多 1 次“不是A，而是B”这类结构；超过 1 次视为 FAIL。

用法：
    python3 scripts/check_voice.py <script.md> [...]
"""
import pathlib
import re
import sys

PATTERNS = (
    r'不是[^。；\n]{0,30}?而是',
    r'不只是[^。；\n]{0,30}?而是',
    r'真正的[^。；\n]{0,12}?是',
    r'表面上[^。；\n]{0,20}?实际上',
    r'与其说[^。；\n]{0,20}?不如说',
    r'靠的是[^。；\n]{0,30}?而不是',
    r'关键在于[^。；\n]{0,20}?不在于',
    r'反直觉的是',
    r'更狠的是',
    r'更绝的是',
    r'颠覆认知',
)

MAX_HITS = 1


def find_hits(text: str):
    hits = []
    for pattern in PATTERNS:
        for match in re.finditer(pattern, text):
            hits.append(match.group(0))
    return hits


def main(argv):
    if not argv:
        print(__doc__.strip())
        return 2

    failed = False
    for name in argv:
        path = pathlib.Path(name)
        if not path.is_file():
            print(f'SKIP {name} (not a file)')
            continue
        hits = find_hits(path.read_text(encoding='utf-8'))
        status = 'FAIL' if len(hits) > MAX_HITS else 'PASS'
        failed = failed or status == 'FAIL'
        print(f'{status} {len(hits):>2} hit(s)  {name}')
        for hit in hits[:8]:
            print(f'       - {hit}')
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
