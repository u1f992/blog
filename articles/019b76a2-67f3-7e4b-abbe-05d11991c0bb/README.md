## Bottles

https://usebottles.com/

Flatpakからインストールするように指示されている[^1]。Flatpakをインストールしていなければ手順[^2]通りインストールする。GNOME Software FlatpakプラグインはUbuntuが提供しているアプリセンターと噛み合わせが悪いことが説明されている。そもそも私は使っていないからインストールは不要そうだ。

[^1]: https://docs.usebottles.com/getting-started/installation
[^2]: https://flathub.org/en/setup/Ubuntu

```
$ sudo apt install flatpak
$ flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
$ systemctl reboot

$ flatpak install flathub com.usebottles.bottles
$ flatpak run com.usebottles.bottles
```

中華フォントっぽい。

![](image.png)

キャッシュをクリアしてみる[^3]。

[^3]: https://sites.google.com/site/fuguzaemon/saikin/flatpak%E7%89%88gimp%E3%81%AE%E6%96%87%E5%AD%97%E5%8C%96%E3%81%91%E3%82%92%E6%B2%BB%E3%81%99

```
$ flatpak run --command=fc-cache com.usebottles.bottles --force --verbose
...
/run/host/fonts/truetype: failed to write cache
...
fc-cache: failed
```

失敗しているし、直ってもいない。一旦これは無視しよう。

はじめに選択されるデフォルトっぽい設定でWINEPREFIXを……Bottlesでは「ボトル」と言うらしい、ボトルを作成してみる。

```
名前：test
アプリケーション
ランナー：soda-9.0-1
ボトルのディレクトリ：（デフォルト）
```
