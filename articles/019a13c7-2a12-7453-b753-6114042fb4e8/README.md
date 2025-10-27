## ThinkPad X1 Carbon Gen 12利用ログ

### UEFI設定

```
Config > Keyboard/Mouse > Trackpad > Off
  Fn and Ctrl Key swap > On
Security > Secure Boot > Off
Startup > Boot > Boot Priority Order　よしなに
```

### Ubuntuのインストール

```
Choose your language: (使用する言語を選択してください:) > 日本語
次
Ubuntuのアクセシビリティ
次
キーボードレイアウトを選択してください > 日本語
キーボードバリアントを選択: > 日本語
次
インターネットの接続方法を選択してください > 有線接続を使用
次
インストーラーのアップデートが適用できます > 今すぐアップデート > インストーラーを閉じる
DockからInstall RELEASEを起動
使用する言語を選択してください: > 日本語
次
Ubuntuのアクセシビリティ
次
キーボードレイアウトを選択してください > 日本語
キーボードバリアントを選択: > 日本語
次
インターネットの接続方法を選択してください > 有線接続を使用
次
Ubuntuをインストールしますか？ > 対話式インストール
次
開始時にどのアプリをインストールしますか？ > 既定の選択
次
推奨するプロプライエタリなソフトウェアをインストールしますか？
　+ グラフィックスとWi-Fi機器用のサードパーティ製ソフトウェアをインストールする
　+ 追加のメディアフォーマット用のサポートをダウンロードしてインストールする
次
どうやってUbuntuをインストールしますか？
ディスクを削除してUbuntuをインストールする
次
アカウントの設定
あなたの名前　Koutaro Mukai
コンピューターの名前　mukai-ThinkPad-X1-Carbon-Gen-12
ユーザー名を入力　mukai
+ ログイン時にパスワードを要求する
次
タイムゾーンを選択してください
現在地　Tokyo (Tokyo, Japan)
タイムゾーン　Asia/Tokyo
次
これまでの選択を確認してください
インストール

今すぐ再起動
Please remove the installation medium, then press ENTER:


Ubuntu 24.04.3 LTSへようこそ！
次へ
Ubuntu Proを有効化する > Skip for now
スキップ
Ubuntuの改善を支援する > はい、システムデータをUbuntuチームと共有します
次へ
さらにアプリケーションを追加する
完了
```

### 初期設定

```
設定 > ディスプレイ
+任意倍率のスケーリング
スケール　150%
適用
```

- ［設定］＞［マウスとタッチパッド］＞［タッチパッド］タブ＞［Touchpad］無効化
- ［設定］＞［Ubuntu Desktop］＞［Dockを自動的に隠す］
- ホームディレクトリの英語化

```
$ LANG=C xdg-user-dirs-update --force
$ rmdir ダウンロード
$ rmdir テンプレート
$ rmdir デスクトップ
$ rmdir ドキュメント
$ rmdir ビデオ
$ rmdir ピクチャ
$ rmdir ミュージック
$ rmdir 公開
$ systemctl reboot
［次回から表示しない］＞［古い名前のままにする］
$ systemctl reboot
```

ホームのデスクトップアイコンを画面右下端に移動。触ってしまったから自動で動かなかったのかも？

- フリーズ判定を少し長く

```
$ gsettings get org.gnome.mutter check-alive-timeout
uint32 5000
$ gsettings set org.gnome.mutter check-alive-timeout 10000
$ gsettings get org.gnome.mutter check-alive-timeout
uint32 10000
```

- Tweaks

```
$ sudo apt update
$ sudo apt --yes upgrade
$ sudo apt --yes install gnome-tweaks
```

- Mouse & Touchpad > 中クリックによる貼り付け　off
- 外観 > Styles > アイコン > Yaru-magenta
- レガシーなアプリケーション > Yaru-magenta

### Google Chrome

```
cd Downloads/
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
$ sudo dpkg -i google-chrome-stable_current_amd64.deb 
$ sudo apt --fix-broken --yes install
```

- ［Google Chromeを既定のブラウザにする］
- ［使用統計データと障害レポートをGoogleに自動送信します］

```
Chromeにログイン
同期をオンにする
Chromeで表示される広告に対するプライバシー強化について
理解しました
```

- Chromeをピン留めしてFirefoxを外す

### デスクトップ壁紙

壁紙はPictures直下に置く。右クリック　背景として設定 > 設定

### VPN接続

```
$ sudo apt --yes install wireguard
$ sudo tee /etc/wireguard/wg0.conf >/dev/null <<EOF
[Interface]
Address = 10.8.0.4/24
PrivateKey = (mask)

[Peer]
PublicKey = qXCUF/jyT4hm7oVO9ftDTLz1MrpMAdh7CrUlqsHfICY=
Endpoint = 118.156.113.172:51820
AllowedIPs = 10.8.0.0/24
PersistentKeepalive = 25
EOF
$ sudo systemctl enable --now wg-quick@wg0
$ ssh mukai@10.8.0.1  # 疎通チェックOK
```

SSHサーバーを開始して、こちらにもログインできるように

```
$ sudo apt install --yes openssh-server
$ sudo systemctl enable --now ssh
$ sudo ufw allow from 10.8.0.0/24 to any port 22
$ sudo ufw enable
```

別の端末から`ssh mukai@10.8.0.4`。通らん　とりあえず再起動`systemctl reboot`

ルールの追加方法が間違っていた。wg0内で許可するならこちらのほうが明確

```
$ sudo ufw delete allow from 10.8.0.0/24 to any port 22
$ sudo ufw allow in on wg0 to any port 22
$ sudo ufw reload
```

別の端末から`ssh mukai@10.8.0.4`。OK

### 電源モード

設定 > 電源管理 > 電源モード　Performance

### スリープ時の挙動設定

フタ閉じたあともSSHアクセスを開けておきたい

```
$ gsettings get org.gnome.settings-daemon.plugins.power lid-close-ac-action
'suspend'
$ gsettings set org.gnome.settings-daemon.plugins.power lid-close-ac-action 'nothing'
$ sudo nano /etc/systemd/logind.conf
  # 以下2項目を設定
  # HandleLidSwitch=ignore
  # HandleLidSwitchDocked=ignore
```

開くようになった。

いつの間にか「ホーム」のデスクトップアイコンが1コマ左に動いている。右端に寄せ直す

### VS Code

```
https://code.visualstudio.com/
code_1.105.0-1759933565_amd64.debをダウンロード
$ sudo dpkg -i code_1.105.0-1759933565_amd64.deb
  # PPAが登録されるようだ
$ sudo apt --fix-broken --yes install
日本語言語パックを追加
MS-CEINTL.vscode-language-pack-ja
VS Codeを再起動
```

中クリックでペーストの挙動を切る

- ユーザー設定 > 設定 > editor.selectionClipboard: false https://github.com/microsoft/vscode/issues/14610

### VNC/RDPビュアー

- https://gitlab.com/Remmina/Remmina/-/wikis/home

Flatpakが先頭にあるのでこれがよさそうGNOME Softwareは使っていないから、GNOME Software Flatpak pluginはスキップ

- https://flathub.org/en/setup/Ubuntu

```
$ sudo apt install flatpak
$ flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

"To complete setup, restart your system."とのことなので
$ systemctl reboot

$ flatpak install --user flathub org.remmina.Remmina
Looking for matches…
error: No remote refs found for ‘flathub’
```

？？？
flathubのremote自体も--userで管理しなくてはならないそうだ

```
$ flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
$ flatpak install --user flathub org.remmina.Remmina
$ flatpak run --user org.remmina.Remmina
```

Remminaのログイン時自動起動は不要。ハンバーガーメニュー＞アプレット＞ユーザーのログイン時に起動してトレイに格納する　無効化

### GitHub CLI

```
$ sudo apt install gh
$ gh auth login
- GitHub .com
- HTTPS
- Authenticate Git: Yes
unable to find git executable in PATH; please install git before retrying
```

はい…

```
$ sudo apt install git
$ git config --global user.email "mail"
$ git config --global user.name "Koutaro Mukai"

$ gh auth login
- Login with a web browser
```

### dotfiles導入

```
$ cd ~
$ git clone https://github.com/u1f992/dotfiles
$ cd dotfiles
$ ./link.sh
./link.sh: 6: curl: not found
./link.sh: 7: curl: not found
$ sudo apt install curl
$ ./link.sh
```

### Vim

いくつかのパッケージからインストールできるが、OSのクリップボードと連携してくれると助かる

```
$ sudo apt install vim-gtk3
$ vim --version | grep clipboard
+clipboard         +keymap            +printer           +vertsplit
+ex_extra          +mouse_netterm     +syntax            +xterm_clipboard
$ gvim --version | grep clipboard
+clipboard         +keymap            +printer           +vertsplit
+ex_extra          +mouse_netterm     +syntax            +xterm_clipboard
```

### VS Code拡張機能

- VS Code Remote Development拡張を追加 `ms-vscode-remote.vscode-remote-extensionpack`
- vscode-pdf拡張を追加 `tomoki1207.pdf`

### u1f992/blogの依存

```
sudo apt install make
sudo apt install python3-venv
```

### ハードウェアのカスタム

- 触覚タッチパッドをトラックパッドに換装
- FnキーとCtrlキーのキートップを入れ替え

パンタグラフ式キーボードの断面図は「又」のような形になる。この中心の逆三角形の隙間に工具を差し込み、「☓」から剥がすように斜め上方向にゆっくりと力を入れるとキートップだけを剥がせる。ThinkPad X1 Carbon Gen 12はキーストロークが短く、装着済みの状態でキートップを剥がすのは現実的ではない。キーボードをCカバー（パームレストとキーボードが一体になった状態）から剥がしておくとマシ。トラックパッド側は引っ掛ける形状で比較的外しやすく、ディスプレイ側は掴むようになっており外しづらい。

パンタグラフはツメで取り付けられている。トラックパッド側のツメがかかっている箇所の下に薄い工具を挟み込み慎重に持ち上げると外せる。

AliExpressとかで予備部品を確保したく、でも新しいから出回っておらず（セラーに聞いたらあるのかな？）難しめ

### Node.js

Node.jsの管理はfnmでいこう

- nvmと並んで https://nodejs.org/ja/download で紹介されているため
- nvmが.node-versionに対応しないため
- nvmは厳密にはクロスプラットフォームではなく、nvm-windowsは今後終了していくことが明言されているため https://github.com/coreybutler/nvm-windows/wiki/Runtime

https://github.com/Schniz/fnm

```
$ curl -fsSL https://fnm.vercel.app/install | bash
（ターミナルウィンドウを再起動）
$ fnm install 22
$ node -v
v22.20.0
$ npm -v
10.9.3
$ npm install --global npm@latest
$ npm -v
11.6.2

$ npm install -g @anthropic-ai/claude-code
```

### VS Codeの拡張機能追加

- `ms-python.python`
- `charliermarsh.ruff`
- `ms-python.mypy-type-checker`

### Python uv

https://docs.astral.sh/uv/getting-started/installation/

```
$ wget -qO- https://astral.sh/uv/install.sh | sh
$ source ~/.bashrc 
$ uv --version
uv 0.9.5
```

ネイティブ拡張のインストールにはどうせ使うか

```
sudo apt-get install build-essential
```

ファイルからパッケージを探すために

```
sudo apt-get install apt-file
```

pyaudioのために

```
sudo apt install --yes python3-dev 
```

### Docker

https://docs.docker.com/engine/install/ubuntu/

```
$ for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

$ sudo apt-get update
$ sudo apt-get install ca-certificates curl
$ sudo install -m 0755 -d /etc/apt/keyrings
$ sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
$ sudo chmod a+r /etc/apt/keyrings/docker.asc

$ echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

$ sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

この段階ではdockerの実行にはsudoが必要で、次の手順に"If you initially ran Docker CLI commands using sudo before adding your user to the docker group,"という項目があり、設定ファイルの権限で不都合が発生する旨が説明されている。

ここではまだdockerを実行せずに、デーモンが起動しているかだけ確認しておくのがよさそう

```
$ sudo systemctl status docker
```

https://docs.docker.com/engine/install/linux-postinstall/

```
$ sudo groupadd docker
$ sudo usermod -aG docker $USER

$ grep docker /etc/group
docker:x:984:mukai

$ newgrp docker
$ docker run hello-world
```

再起動してDockerが自動起動することも確認しておく。

```
$ systemctl reboot
$ docker run hello-world
```

#### 雑チートシート

終了済みも含めてコンテナを表示

```
$ docker ps -a
CONTAINER ID   IMAGE         COMMAND    CREATED              STATUS                          PORTS     NAMES
e11498646114   hello-world   "/hello"   About a minute ago   Exited (0) About a minute ago             reverent_gates
d56ea7fc1cea   hello-world   "/hello"   5 minutes ago        Exited (0) 5 minutes ago                  trusting_wescoff
```

特定のコンテナを削除

```
$ docker rm e11498646114
```

または終了済みのコンテナをすべて削除

```
$ docker container prune
```

イメージを表示。ここで`-a/--all`は、タグのないイメージ（一般的には中間イメージ）を含めることを表している。これは`<none>`として一覧に現れる。

```
$ docker images -a
REPOSITORY    TAG       IMAGE ID       CREATED        SIZE
hello-world   latest    1b44b5a3e06a   2 months ago   10.1kB
```

特定のイメージを削除

```
$ docker rmi hello-world:latest
または docker rmi 1b44b5a3e06a
```

未使用のイメージをすべて削除

```
docker image prune -a
```

### ffmpeg

https://www.ffmpeg.org/download.html

Ubuntuのaptも公式の手順に含まれているから、これで良さそう

```
$ sudo apt update && sudo apt install --yes ffmpeg
```

### プリンター

C3935FのドライバはLinux版も提供されている

https://canon.jp/support/software/os/select?pr=5740&os=20

LIPSLX/ CARPS2とLIPS4があり、前者がデバイス固有、LIPS4が汎用ドライバらしい？

```
linux-lipslx-drv-v620-jp-01.tar.gzをダウンロード
$ tar xvf linux-lipslx-drv-v620-jp-01.tar.gz
$ cd linux-lipslx-drv-v620-jp/
$ sudo ./install.sh
```

Canon Printer Setup Utility 2 > 追加 > Canon iR-ADV C3935 LIPSLX

lpdが古いLine Printer Daemonプロトコルで、socketがただしい

IPアドレスはそのとおりに

### tmux

https://github.com/tmux/tmux/wiki/Installing

```
$ tmux
コマンド 'tmux' が見つかりません。次の方法でインストールできます:
sudo snap install tmux  # version 3.5a, or
sudo apt  install tmux  # version 3.4-1ubuntu0.1
他のバージョンについては 'snap info tmux' を確認してください。
```

aptだと若干遅れているけど、aptを勧められているな

### ターミナルからクリップボードへコピー

```
$ sudo apt install xsel

$ echo 'Hello, World!' | xsel --clipboard --input
```

### traceroute

```
$ traceroute 1.1.1.1
コマンド 'traceroute' が見つかりません。次の方法でインストールできます:
sudo apt install inetutils-traceroute  # version 2:2.4-3ubuntu1, or
sudo apt install traceroute            # version 1:2.1.5-1
$ sudo apt install traceroute
```

前者はGNU inetutils版らしい。

