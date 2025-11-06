## だいたい狙った時間で指定したファイルを配信するローカルサーバ

```py
import http.server
import math
import time
from urllib.parse import urlparse, parse_qs

PORT = 8080
FONT_ROUTE = "/NotoSansJP-VariableFont_wght.ttf"
FONT_PATH = "Noto_Sans_JP/NotoSansJP-VariableFont_wght.ttf"
CHUNK = 32  # bytes
SECONDS_PARAM = "s"  # 受信完了までの目標秒数

with open(FONT_PATH, "rb") as f:
    FONT_DATA = f.read()

FONT_SIZE = len(FONT_DATA)


class SlowHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        url = urlparse(self.path)
        if url.path != FONT_ROUTE:
            self.send_error(404)
            return

        q = parse_qs(url.query)
        s = None
        raw = q.get(SECONDS_PARAM, [None])[0]
        if raw is not None:
            try:
                s = float(raw)
            except ValueError:
                s = None

        self.send_response(200)
        self.send_header("Content-Type", "font/ttf")
        self.send_header("Content-Length", str(FONT_SIZE))
        self.send_header("Cache-Control", "no-store")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()

        if not s or s <= 0:
            try:
                self.wfile.write(FONT_DATA)
            except BrokenPipeError:
                pass
            return

        chunks = max(1, math.ceil(FONT_SIZE / CHUNK))

        start = time.perf_counter()
        try:
            offset = 0
            idx = 0
            while offset < FONT_SIZE:
                self.wfile.write(FONT_DATA[offset : offset + CHUNK])
                self.wfile.flush()

                idx += 1
                offset += CHUNK

                # 理想スケジュール：i個目のチャンク送信直後の時刻 = (s * i) / chunks
                target = (s * idx) / chunks
                now = time.perf_counter() - start
                sleep_for = target - now
                if sleep_for > 0:
                    time.sleep(sleep_for)

        except BrokenPipeError:
            pass


http.server.ThreadingHTTPServer(("0.0.0.0", PORT), SlowHandler).serve_forever()
```

```html
<!DOCTYPE html>
<html lang="ja">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Document</title>
    <style>
      @page {
        size: A5;
      }
      @font-face {
        font-family: "Noto Sans JP";
        src: url("http://localhost:8080/NotoSansJP-VariableFont_wght.ttf?s=10");
        font-display: swap;
        font-weight: 100 900;
        font-style: normal;
      }
      p {
        font-family: "Noto Sans JP", serif;
      }
    </style>
  </head>
  <body>
    <p>
      フォントのダウンロードが非常に遅いので、しばらく明朝で表示されます。
    </p>
  </body>
</html>
```

Vivliostyleにおける`font-display: swap`の挙動が気になったので作ったけど、先にフォント全体を読み込むのでスワップは起こらないことがわかって不要だった。

