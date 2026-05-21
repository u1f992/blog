## Flatpakアプリの中華フォント対策

- https://github.com/flatpak/flatpak/issues/5425
- https://okutom.hatenablog.com/entry/2024/11/07/204055

Flatpakアプリはサンドボックス内で動くため、ホストのfontconfig設定（`/etc/fonts/conf.d/`配下のディストリ提供設定や`~/.config/fontconfig/`のユーザー設定）にアクセスできない。その結果fontconfigがフォールバック動作になり、CJK統合漢字がたまたまインストールされている中国語フォント（例: Noto Sans CJK SC）で描画され、日本語のはずの文字が「中華フォント」っぽく見えてしまう。

fontconfigはユーザー設定として`$XDG_CONFIG_HOME/fontconfig/`（`man 5 fonts-conf`で確認できる）を読み込むが、Flatpakサンドボックス内では`$XDG_CONFIG_HOME`が`~/.var/app/$FLATPAK_ID/config`に書き換えられる。したがって、ホストの`~/.config/fontconfig/`を`flatpak override --filesystem=xdg-config/fontconfig`で見せても、サンドボックス内のfontconfigが見るパスとは噛み合わず読まれない。

対策はアプリごとの`~/.var/app/$FLATPAK_ID/config/fontconfig/`配下にホストのfontconfig設定を配置すること。サンドボックス内fontconfigはこのパスを`$XDG_CONFIG_HOME/fontconfig/`として読みに行くので、追加のoverrideなしで反映される。以下の手順で実施する（例としてRemmina = `org.remmina.Remmina`）。

1. `mkdir -p ~/.var/app/org.remmina.Remmina/config/fontconfig/conf.d`で対象アプリのper-app config配下にfontconfig設定置き場を用意。
2. `cp /etc/fonts/fonts.conf ~/.var/app/org.remmina.Remmina/config/fontconfig/fonts.conf` / `cp -L /etc/fonts/conf.d/*.conf ~/.var/app/org.remmina.Remmina/config/fontconfig/conf.d/`でホストの選択ロジックを、シンボリックリンクは実体に解決した上でコピー。
3. `rm -rf ~/.var/app/org.remmina.Remmina/cache/fontconfig`で古い（中華フォントが選ばれた状態の）fontconfigキャッシュを削除し、次回起動時に再生成させる。

```
$ APP=org.remmina.Remmina
$ mkdir -p ~/.var/app/$APP/config/fontconfig/conf.d
$ cp /etc/fonts/fonts.conf ~/.var/app/$APP/config/fontconfig/fonts.conf
$ cp -L /etc/fonts/conf.d/*.conf ~/.var/app/$APP/config/fontconfig/conf.d/
$ tree ~/.var/app/$APP/config/fontconfig/
/home/mukai/.var/app/org.remmina.Remmina/config/fontconfig/
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
$ rm -rf ~/.var/app/$APP/cache/fontconfig

$ flatpak run $APP
```

設定前

![](image.png)

設定後

![](image-1.png)

---

以前（`87e9cc99218783c790ef7e51468ae35edf97c5fa`）は、`~/.config/fontconfig/conf.d`にコピーして`sudo flatpak override --filesystem=xdg-config/fontconfig:ro`でサンドボックスに見せる方法を記述していた。Bottlesはこれで中華フォントが解消された。しかし、同じ方法をRemminaに対して適用しても効かなかった。

調査の結果、原因はアプリが宣言する`--filesystem=home` permissionにあった。`flatpak info --show-permissions`でそれぞれの宣言を見ると:

```
$ flatpak info --show-permissions com.usebottles.bottles | grep filesystems
filesystems=xdg-config/fontconfig:ro;

$ flatpak info --show-permissions org.remmina.Remmina | grep filesystems
filesystems=xdg-run/pipewire-0;home;xdg-run/gvfsd;xdg-download;
```

Bottlesはfontconfig設定のためのpermissionだけを最小限宣言しているのに対し、Remminaは`home`を含み、`~`全体へのアクセスを宣言している（リモートデスクトップとして転送ファイルやSSH鍵などホームの任意位置を読み書きできる必要があるためと思われる。[Flathub上流マニフェスト](https://github.com/flathub/org.remmina.Remmina/blob/master/org.remmina.Remmina.json)の`finish-args`に`--filesystem=home`が直接書かれている）。

それぞれのサンドボックス内の`/proc/self/mountinfo`を見ると、`flatpak override --filesystem=xdg-config/fontconfig:ro`の結果として実際に作られるbind mountが異なる:

```
# Bottles（homeなし、override効果あり）
/home/mukai/.config/fontconfig → /home/mukai/.config/fontconfig (ro)
/home/mukai/.config/fontconfig → /home/mukai/.var/app/com.usebottles.bottles/config/fontconfig (ro)

# Remmina（homeあり、override効果が消える）
/home/mukai → /home/mukai (rw)   ← homeのbindのみ
（per-app XDG config dirへのbindはなし）
```

Bottlesでは2本目のbind（ホストの`~/.config/fontconfig`をper-app XDG config dirの`fontconfig`サブディレクトリに重ねる）が作られ、これによってサンドボックス内fontconfigが`$XDG_CONFIG_HOME/fontconfig/`を読みに行ったときホストの設定が見える。Remminaでは`home` permissionがあるためflatpakがこのper-app bindを省略してしまう（home全体が既に見えているので冗長と判断していると思われる）。結果、サンドボックス内fontconfigの探すパスは空のままになる。

つまり`flatpak override --filesystem=xdg-config/fontconfig:ro`の方法は、`home`を持たないアプリでのみ動作する条件付き解だった。この記事の前半で示した「per-app config配下に直接コピーする方法」は`home` permissionの有無に関係なく動作する汎用解。
