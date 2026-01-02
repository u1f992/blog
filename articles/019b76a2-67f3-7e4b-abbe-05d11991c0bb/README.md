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

おそらくこれはflatpakサンドボックスがシステムのフォントを正しく参照できていない。以下のような情報が見つかった。

- https://github.com/flatpak/flatpak/issues/5425
- https://okutom.hatenablog.com/entry/2024/11/07/204055

```
$ mkdir -p ~/.config/fontconfig/conf.d
$ cp /etc/fonts/fonts.conf ~/.config/fontconfig/fonts.conf
$ cp -L /etc/fonts/conf.d/*.conf ~/.config/fontconfig/conf.d/
$ tree ~/.config/fontconfig/
/home/mukai/.config/fontconfig/
├── conf.d
│   ├── 10-hinting-slight.conf
│   ├── 10-scale-bitmap-fonts.conf
│   ├── 10-sub-pixel-rgb.conf
...
│   ├── 80-delicious.conf
│   ├── 90-synthetic.conf
│   └── 99-language-selector-zh.conf
└── fonts.conf

2 directories, 63 files
$ sudo flatpak override --filesystem=xdg-config/fontconfig:ro

$ rm -rf ~/.cache/fontconfig
$ rm -rf ~/.var/app/*/cache/fontconfig

$ flatpak run com.usebottles.bottles
```

![](image-1.png)

デフォルトっぽい設定でWINEPREFIXを……Bottlesでは「ボトル」と言うらしい、ボトルを作成してみる。

```
名前：test
アプリケーション
ランナー：soda-9.0-1
ボトルのディレクトリ：（デフォルト）
```

Browse C:/ driveから表示すると、`/home/mukai/.var/app/com.usebottles.bottles/data/bottles/bottles/test/drive_c`が表示される。WINEPREFIXである`/home/mukai/.var/app/com.usebottles.bottles/data/bottles/bottles/test`には`bottle.yml`がある。

[microfortnight/yabridge-bottles-wineloader](https://github.com/microfortnight/yabridge-bottles-wineloader)によると、Wineバイナリの実パスは以下のパスになる。

```
$ yq -r ".Runner" /home/mukai/.var/app/com.usebottles.bottles/data/bottles/bottles/test/bottle.yml 
soda-9.0-1
$ ls ~/.var/app/com.usebottles.bottles/data/bottles/runners/soda-9.0-1/bin/
function_grep.pl  regedit   wine-preloader        wine64-preloader  winecfg      winedump  winemaker   wmc
msidb             regsvr32  wine-tkg              wine64-tkg        wineconsole  winefile  winemine    wrc
msiexec           widl      wine-tkg-interactive  wineboot          winecpp      wineg++   winepath
notepad           wine      wine64                winebuild         winedbg      winegcc   wineserver
```

素直に動きそうなWindowsアプリを実行してみる。

- https://ackiesound.ifdef.jp/download.html

`~/Downloads/wavetone274.zip`にダウンロードして解凍。`wavetone.exe`が現れる。歯車マークの「Run executable in "test"」から`~/Downloads/wavetone274/wavetone.exe`を実行

![](image-2.png)

まずは豆腐を直したい。Bottlesでは「依存関係」（dependencies）という概念を導入して、Winetricksの機能を自前で用意している。とはいえ内容の出自はWinetricksで、基本的には名称もWinetricksと共通していると考えてよいようだ。testの>アイコン（詳細）＞依存関係から「cjkfonts」をインストールする。

![](image-3.png)

awlib.dllは自身のdata/awlib.dllに存在するので、単にアクセスできないという問題だろう。ディレクトリをWINEPREFIX内に移動する。

```
$ mv ~/Downloads/wavetone274 /home/mukai/.var/app/com.usebottles.bottles/data/bottles/bottles/test/drive_c/users/steamuser/Documents/
```

テキスト座標などがちょっと怪しいけど、起動は問題なさそうだ。

![](image-4.png)

ランナーは様々な種類があり、ハンバーガーメニューのPreferences>Runnersからインストールできる。[robbert-vdh/yabridge #382](https://github.com/robbert-vdh/yabridge/issues/382)の影響で、[microfortnight/yabridge-bottles-wineloader](https://github.com/microfortnight/yabridge-bottles-wineloader)ではkron4ek-wine-9.21-staging-tkg-amd64の使用を推奨している。[Kron4ek](https://github.com/Kron4ek)氏が配布している、パッチを複数適用したバイナリということ？

BottlesにはCLIもあるが、依存関係のインストールなどは特にできないらしい。現時点ではあまり使いみちがなさそう。

- https://docs.usebottles.com/advanced/cli

```
$ flatpak run --command=bottles-cli com.usebottles.bottles list bottles
16:22:16 (INFO) Forcing offline mode 
Found 1 bottles:
- test
$ flatpak run --command=bottles-cli com.usebottles.bottles tools --bottle test winecfg
16:23:10 (INFO) Forcing offline mode 
wineserver: using server-side synchronization.
```
