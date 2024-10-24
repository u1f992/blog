## WSL2のNode.jsにPlaywrightでChrome入れたけど動かん

Vivliostyleのプレビューで必要だった。

Chromeを手で起動して、足りないと言われたものを`apt search`で探してかたっぱしから入れた。まあ起動はするけどたくさんエラーが出てるし、WSL2側にChromiumをインストールしたら解決する気がする。

```shell-session
$ /home/mukai/.cache/ms-playwright/chromium-1091/chrome-linux/chrome

$ sudo apt install -y x11-apps
$ sudo apt install -y libnss3
$ sudo apt install -y libatk1.0-0
$ sudo apt install -y libatk-bridge2.0-0
$ sudo apt install -y libxkbcommon0
$ sudo apt install -y libxcomposite1
$ sudo apt install -y libxdamage1
$ sudo apt install -y libxrandr2
$ sudo apt install -y libgbm1
$ sudo apt install -y libasound2
```
