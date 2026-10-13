#!/usr/bin/env python3
import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def title_of(lines):
    for line in lines:
        if line.startswith("## "):
            return line[3:]
    return ""


def main():
    parser = argparse.ArgumentParser(
        description="articles/*/README.md を全文検索する。"
        "複数のパターンを指定した場合は、すべてにマッチする記事に絞り込む。"
    )
    parser.add_argument("pattern", nargs="+", help="Python の正規表現")
    parser.add_argument(
        "-s", "--case-sensitive", action="store_true", help="大文字と小文字を区別する"
    )
    parser.add_argument(
        "-l",
        "--list",
        action="store_true",
        help="マッチした行を表示せず、記事のパスとタイトルだけを出力する",
    )
    args = parser.parse_args()

    flags = 0 if args.case_sensitive else re.IGNORECASE
    try:
        patterns = [re.compile(p, flags) for p in args.pattern]
    except re.error as e:
        parser.error(f"正規表現が不正です: {e}")

    hit = False
    for path in sorted(ROOT.glob("articles/*/README.md")):
        lines = path.read_text(encoding="utf-8").splitlines()
        if not all(any(p.search(line) for line in lines) for p in patterns):
            continue
        hit = True
        print(f"{path.relative_to(ROOT)}: {title_of(lines)}")
        if args.list:
            continue
        for number, line in enumerate(lines, start=1):
            if any(p.search(line) for p in patterns):
                print(f"  {number}: {line}")
        print()
    return 0 if hit else 1


if __name__ == "__main__":
    sys.exit(main())
