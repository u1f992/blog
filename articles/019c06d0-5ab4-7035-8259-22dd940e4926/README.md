## Vivliostyle　CSSメモ

Vivliostyle.jsにおいて`@page :first-page`と`@page :nth(1)`は複数ファイルの結合（[Web Publications](https://www.w3.org/TR/wpub/)）時に動作が異なる。`:first-page`はグローバルの第1ページにマッチし、`:nth(1)`は各ファイルの第1ページにマッチする。これらはどちらも詳細度+256なので、両方指定された場合は後勝ち。なお`:blank`も同じ+256。

`:first-page` `:nth(1)`は`:left` `:right`（詳細度+1）に勝つ。

