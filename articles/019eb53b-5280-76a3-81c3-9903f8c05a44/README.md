## `font-family`名をフォント自体のデータから適当に決めたい

`@font-face`の`font-family`名は任意のラベルなので内部の名前と独立して決められるのだが、別に自分で決めたくはない。フォント名をいい感じに取ってきたい。以下の情報によると、nameテーブルの16→1を見ればよいらしい。

[name - Naming table (OpenType 1.9.1) - Typography | Microsoft Learn](https://web.archive.org/web/20260513011006/https://learn.microsoft.com/en-us/typography/opentype/spec/name)

| ID | Meaning |
| --- | --- |
| 16 | Typographic Family name. ... If name ID 16 is absent, then name ID 1 is considered to be the typographic family name. ... |

[Font Names Table - TrueType Reference Manual - Apple Developer](https://web.archive.org/web/20260325101112/https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6name.html)

| NameID code(s) | Description |
| --- | --- |
| 16 | Preferred Family. ... These IDs are only present if they are different from IDs 1 and 2. |

ワンライナーならこんな形か

```shellsession
$ uv run --with fonttools python3 -c "import sys;from fontTools.ttLib import TTFont;n=TTFont(sys.argv[1])['name'];print(n.getDebugName(16) or n.getDebugName(1))" noto-cjk/02_NotoSerifCJK-OTF-VF/Variable/OTF/NotoSerifCJKjp-VF.otf
Noto Serif CJK JP
```
