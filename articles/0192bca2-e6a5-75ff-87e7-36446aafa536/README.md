## Realtekの汎用ASIOドライバー

あってしかるべきとは思っていたけど、調べてみたらやっぱりあるらしい。ASIO4ALLよりはマシか？

- https://www.baumannmusic.com/2021/the-official-asio-driver-for-realtek-hd-audio-dell-hp-lenovo-asus/

ここからダウンロードする。DellだがThinkPadにもインストールできた。ほんまかいな。

- https://www.dell.com/support/home/ja-jp/drivers/driversdetails?driverid=7776f

```
$ sha256sum Realtek-High-Definition-Audio-Driver_7776F_WIN_6.0.1.7737_A04_02.EXE
c5051533b798a2ff4da58e746b651243e08f2bf1a1a5bdbca50c2e3b4432c9d9 *Realtek-High-Definition-Audio-Driver_7776F_WIN_6.0.1.7737_A04_02.EXE
```

「INSTALL」ではなく「EXTRACT」を選択。フォルダを作成して収めるような親切なことはしてくれないので、ぶちまけたくなければ新規フォルダを作成して選択すること。

`{展開先}\RealtekHDAudio\ASIO\Install.exe`を実行して、指示に従いインストールする。
