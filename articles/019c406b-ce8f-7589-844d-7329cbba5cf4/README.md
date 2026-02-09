## トンボなし見開き2up PDFの生成

カレントディレクトリにあるinput.pdfの86-87ページをトンボなし見開き2up PDFにしたい。

以下の説明ではTeX Live（2024）に含まれているツールで説明する。他のコマンドを使用すれば手数が減る（例：TrimBoxはPopplerのpdfinfoを使用すれば取得でき、Ghostscriptの出力から切り出す必要はない）が、システムにツールをインストールする必要がある。TeX Liveに含まれているものならコンテナイメージから直接利用できるので管理の手間が省ける。

以下の説明では便宜的に`gs`・`pdfjam`を直接使用するが、コンテナイメージから使用するなら以下のようにシェル変数を利用すると短く済む。

```bash
IMAGE=registry.gitlab.com/islandoftex/images/texlive:TL2024-historic-doc
DOCKER="docker run --rm --mount type=bind,source=.,target=/workdir --workdir /workdir --user texlive"
GS="${DOCKER} --entrypoint gs ${IMAGE}"
PDFJAM="${DOCKER} --entrypoint /usr/local/texlive/2024/bin/x86_64-linux/pdfjam ${IMAGE}"
```

### 1. TrimBoxの確認

明らかに全ページ同じなら1ページ目だけ確認すれば十分。

```shellsession
$ gs -dBATCH -dNOPAUSE -dNODISPLAY -dPDFDEBUG -dFirstPage=1 -dLastPage=1 input.pdf 2>&1 | grep -E 'MediaBox|BleedBox|TrimBox|CropBox'
 /MediaBox[ 0 0.362980 606.614258 743.039978 ]
 /BleedBox[ 36.850426 37.213406 569.763794 706.189575 ]
 /TrimBox[ 45.354374 45.717354 561.259888 697.685608 ]
```

- MediaBox：紙
- BleedBox：外トンボ
- TrimBox：内トンボ←裁ち落とし後サイズ
- CropBox：ビュアーが描画を切り取るサイズ

### 2. 指定ページの抽出とトリム

#### 方法A

GhostscriptでTrimBoxを参照して切り出す。

```shellsession
$ gs -o trimmed-86-87.pdf -sDEVICE=pdfwrite -dUseTrimBox -dFirstPage=86 -dLastPage=87 input.pdf
```

- `-o`は自動で`-dBATCH`・`-dNOPAUSE`を付与する（[参考](https://ghostscript.readthedocs.io/en/latest/Use.html#o-option)）。

<details>
<summary>別解</summary>

PDFjamでTrimBoxを参照して切り出すには、以下のように`\Gin@pagebox`を書き換える。

```shellsession
$ pdfjam \
  --preamble '\makeatletter\def\Gin@pagebox{trimbox}\makeatother' \
  --fitpaper true \
  input.pdf 86,87 -o trimmed-86-87.pdf
```

`\Gin@pagebox`とは、内部的に`pdftex.def`が`\pdfximage`に渡すページボックス指定。デフォルトは`cropbox`になっている。

</details>

#### 方法B

TrimBoxが未定義の場合や任意の領域を切り出したい場合は手動で指定する。

<details>
<summary>TrimBoxとMediaBoxの差分から各辺のトリム量を算出する計算式</summary>

```
左：TrimBox.x1  - MediaBox.x1 = 45.354374  - 0          = 45.354374bp
下：TrimBox.y1  - MediaBox.y1 = 45.717354  - 0.362980   = 45.354374bp
右：MediaBox.x2 - TrimBox.x2  = 606.614258 - 561.259888 = 45.354370bp
上：MediaBox.y2 - TrimBox.y2  = 743.039978 - 697.685608 = 45.354370bp
```

なお今回はTrimBoxが定義されているので方法Aを使用すればよく、この計算に特に利点はない。

</details>

```shellsession
$ pdfjam --trim '45.354374bp 45.354374bp 45.354370bp 45.354370bp' --clip true --fitpaper true input.pdf 86,87 -o trimmed-86-87.pdf
```

- `--trim '左 下 右 上'`：各辺のトリム量。単位bpはPDFポイント
- `--clip true`：トリム領域外を切り落とす
- `--fitpaper true`：出力用紙サイズをトリム後のコンテンツに合わせる

### 3. 見開き2up PDFの生成

トリム後のページサイズから、2upの用紙サイズを算出する。`--fitpaper true`は入力1ページ分のサイズを出力用紙にするため、`--nup 2x1`と併用すると2ページが1ページ分の幅に縮小されてしまう。2upでは用紙サイズを手動で算出する必要がある。

```
トリム後
　幅　：TrimBox.x2 - TrimBox.x1 = 561.259888 - 45.354374 = 515.905514bp
　高さ：TrimBox.y2 - TrimBox.y1 = 697.685608 - 45.717354 = 651.968254bp

2up用紙
　幅　：トリム後幅×2 = 1031.811028bp
　高さ：トリム後高さ  = 651.968254bp
```

```bash
$ pdfjam --nup 2x1 --papersize '{1031.811028bp,651.968254bp}' trimmed-86-87.pdf -o 86-87.pdf
```

### PyMuPDFによる一括処理

Pythonが使えるなら、上記の手順1〜3はPyMuPDFで完結する。

```bash
$ uv run --with pymupdf python3 spread.py
```

```python
import pymupdf

PAGES = [(86, 87)]

with pymupdf.open("input.pdf") as doc:
    for left_page, right_page in PAGES:
        # 0-indexed
        left_idx = left_page - 1
        right_idx = right_page - 1

        trim = doc[left_idx].trimbox
        page_w = trim.width
        page_h = trim.height

        with pymupdf.open() as out:
            spread = out.new_page(width=page_w * 2, height=page_h)

            for i, pg_idx in enumerate([left_idx, right_idx]):
                spread.show_pdf_page(
                    pymupdf.Rect(i * page_w, 0, (i + 1) * page_w, page_h),
                    doc,
                    pg_idx,
                    clip=trim,
                )

            out.save(f"{left_page}-{right_page}.pdf")
```

コマンドとPythonとどちらが使いやすいかは時とマシンによる。Dockerがあるか、Pythonがあるか、venvを切れるか、uvがあるか……　もちろんどちらもAdobeのアプリほど「まとも」ではないけど、入稿用データならともかく表示用には、見た目さえ大丈夫ならそれでよいはず。PyMuPDFでPDFをラスター画像に書き出す際シェーディングパターンの描画が崩れた経験が一応あるが、2up PDF生成の場合はPDF→PDFだし問題ないでしょう。
