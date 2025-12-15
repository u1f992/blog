## PDF出力した際に任意のデータを埋め込むWebページ

以下は没ネタ記事。面白いけど、PlaywrightでPDFを出力する想定なら、JavaScriptのグローバルに置いて`evaluate`で回収すればよいので。

主要なWebブラウザにはPDFを出力する機能が備わっており、この機能に依存してPDF出力を行うアプリケーションは少なくありません。同様の機能はW3C WebDriverでも定義されており[^1]、各ブラウザで個別に偶然備わっているわけではありません[^2]。

[^1]: https://www.w3.org/TR/webdriver2/#print
[^2]: 機能に根拠があるという話であり、PlaywrightやPuppeteerが直接WebDriverを使用しているということではありません。Playwrightにおいては、Chrome（Chromium）にはChrome DevTools Protocol（CDP）、FireFoxには独自パッチを当てた専用ビルドを用いているようです。Puppetterでは、ChromeにはCDP、FireFoxにはWebDriver BiDiを使用しているようです。

この出力機能でPDFに反映されるのは基本的には視覚要素で、PDFが持つすべての機能を制御することを意図した機能ではありません。Webブラウザを使用してPDFを出力するアプリケーションを考えるとき、後続の処理に渡せる情報が少ないという問題があります。どうにかして、Webページ自身に、PDF出力された際に任意のデータを埋め込む機能を持たせる方法はないでしょうか。対象を一旦Chromiumに限定して考えてみます。

試してみると、ChromiumのPDF出力では`a`要素のリンクが文書内外問わず残ることがわかります。リンク先をdata URLにすればデータを埋め込めそうです。

~~~python
import base64

import fitz
from playwright.sync_api import sync_playwright


def make_payload(n: int) -> bytes:
    return bytes([] if n < 0 else (i & 0xFF for i in range(n)))


DATA_URL_PREFIX = "data:application/octet-stream;base64,"


def make_data_url(payload: bytes) -> str:
    return DATA_URL_PREFIX + base64.b64encode(payload).decode("ascii")


def make_html(data_url: str) -> str:
    return f'<!doctype html><meta charset="utf-8"><a href="{data_url}">a</a>'


def render_pdf(html: str) -> bytes:
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        page.set_content(html)
        pdf_bytes = page.pdf()
        browser.close()
        return pdf_bytes


def extract_payload(pdf_bytes: bytes) -> bytes | None:
    doc = fitz.open(stream=pdf_bytes, filetype="pdf")
    try:
        for page in doc:
            for link in page.get_links():
                uri = link.get("uri")
                if uri and uri.startswith(DATA_URL_PREFIX):
                    b64 = uri[len(DATA_URL_PREFIX) :]
                    return base64.b64decode(b64)
        return None
    finally:
        doc.close()

def main() -> None:
    size = 1024
    payload = make_payload(size)
    data_url = make_data_url(payload)
    html = make_html(data_url)
    pdf = render_pdf(html)
    extracted = extract_payload(pdf)

    print(extracted == payload)

if __name__ == "__main__":
    main()
~~~

~~~
$ uv run --with pymupdf --with playwright python embedded_data.py
True
~~~

この方法で埋め込める最大サイズを二分探索で調べると78642621バイトとなりました。これをBase64に変換するとほぼ100MiBです。Chromium内部のなんらかに100MiB＋いくらかの制限があるのでしょう。これほど大きな内容を埋め込みたいならハックではなく何か他の方法を考えたほうがよいので、ここはこれ以上調べていません。

<details>
<summary>二分探索の例</summary>

~~~python
import base64

import fitz
from playwright.sync_api import sync_playwright


def make_payload(n: int) -> bytes:
    return bytes([] if n < 0 else (i & 0xFF for i in range(n)))


DATA_URL_PREFIX = "data:application/octet-stream;base64,"


def make_data_url(payload: bytes) -> str:
    return DATA_URL_PREFIX + base64.b64encode(payload).decode("ascii")


def make_html(data_url: str) -> str:
    return f'<!doctype html><meta charset="utf-8"><a href="{data_url}">a</a>'


def render_pdf(html: str) -> bytes:
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        page.set_content(html)
        pdf_bytes = page.pdf()
        browser.close()
        return pdf_bytes


def extract_payload(pdf_bytes: bytes) -> bytes | None:
    doc = fitz.open(stream=pdf_bytes, filetype="pdf")
    try:
        for page in doc:
            for link in page.get_links():
                uri = link.get("uri")
                if uri and uri.startswith(DATA_URL_PREFIX):
                    b64 = uri[len(DATA_URL_PREFIX) :]
                    return base64.b64decode(b64)
        return None
    finally:
        doc.close()

MIN_SIZE = 0
MAX_SIZE = 100 * 1024 * 1024


def test_payload_size(size: int) -> bool:
    payload = make_payload(size)
    data_url = make_data_url(payload)
    html = make_html(data_url)
    pdf = render_pdf(html)
    extracted = extract_payload(pdf)
    return extracted == payload


def find_max_payload_size() -> int:
    low = MIN_SIZE
    high = MAX_SIZE

    while low < high:
        mid = (low + high + 1) // 2
        print(f"Testing size: {mid} (range: {low}-{high})")
        try:
            result = test_payload_size(mid)
        except Exception as e:
            print(f"  -> NG (exception: {type(e).__name__})")
            high = mid - 1
            continue

        if result:
            print("  -> OK")
            low = mid
        else:
            print("  -> NG")
            high = mid - 1

    return low


def main() -> None:
    max_size = find_max_payload_size()
    print(f"\nMax payload size: {max_size} bytes")


if __name__ == "__main__":
    main()
~~~

~~~
$ uv run --with pymupdf --with playwright python embedded_data.py
Testing size: 52428800 (range: 0-104857600)
  -> OK
Testing size: 78643200 (range: 52428800-104857600)
  -> NG (exception: TargetClosedError)

...

Max payload size: 78642621 bytes
~~~

</details>

`<a href="...">a</a>`は明らかに可視ですが、不可視にする方法も考えます。試した結果、`width=0.078125 height=0`のSVG要素であればリンクが埋め込まれるようです。この`0.078125`は5/64にあたります。Chromiumの内部レイアウト単位が1/64pxなので何らか関係がありそうですが（4/64=1/16まではゼロ幅判定でボックスが作られない？）、確証はありません。

`pointer-events: none;`をつけておけばWebページとして表示中にクリックされることはなくなります。ただしPDF出力後はリンクになります。Evince（PDFビュアー）では、ごくわずかな範囲でマウスカーソルがリンクに反応します。

~~~python
def make_html(data_url: str) -> str:
    return f'<!doctype html><meta charset="utf-8"><a style="pointer-events:none" href="{data_url}"><svg width=0.078125 height=0></svg></a>'
~~~
