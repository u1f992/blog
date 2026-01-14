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
Address = 10.8.0.4/24, fd42:42:42::4/64
PrivateKey = (mask)

[Peer]
PublicKey = qXCUF/jyT4hm7oVO9ftDTLz1MrpMAdh7CrUlqsHfICY=
Endpoint = 118.156.113.172:51820
AllowedIPs = 10.8.0.0/24, fd42:42:42::/64
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

### VS Code拡張

esbenp.prettier-vscode

ユーザーの既定のフォーマッターをPrettierに変更`@id:editor.defaultFormatter @lang:typescript`

ms-azuretools.vscode-containers

Dockerをインストールしている際の推奨機能らしい

```
$ npm install --global @devcontainers/cli
$ devcontainer --version
0.80.1
```

Claude Codeのネイティブバイナリ版が公開され、インストールもこちらが推奨になっていた。なお中身はBunらしい https://docs.claude.com/ja/docs/claude-code/overview

```
$ npm list --global
/home/mukai/.local/share/fnm/node-versions/v22.20.0/installation/lib
├── @anthropic-ai/claude-code@2.0.33
├── @devcontainers/cli@0.80.1
├── corepack@0.34.0
└── npm@11.6.2

$ npm uninstall --global @anthropic-ai/claude-code

removed 3 packages in 108ms
$ npm list --global
/home/mukai/.local/share/fnm/node-versions/v22.20.0/installation/lib
├── @devcontainers/cli@0.80.1
├── corepack@0.34.0
└── npm@11.6.2

$ curl -fsSL https://claude.ai/install.sh | bash
```

### KVM

- https://help.ubuntu.com/community/KVM/Installation （ちょっと古い）
- https://virt-manager.org/

```
$ kvm-ok 
コマンド 'kvm-ok' が見つかりません。次の方法でインストールできます:
sudo apt install cpu-checker
$ sudo apt install cpu-checker
$ kvm-ok 
INFO: /dev/kvm exists
KVM acceleration can be used
$ sudo apt install virt-manager virtiofsd
```

再起動するとlibvirtdが自動起動する

[ラップトップにプリインストールされたOEM版Windows 11をKVM上にインストールし直して利用する](../0198cacd-dcc9-7017-97a8-6fc964adb687/README.md)

```
$ mkdir ~/.win11
$ mv ~/Downloads/Win11_25H2_Japanese_x64.iso ~/.win11/
$ mv ~/Downloads/virtio-win-0.1.285.iso ~/.win11/
$ sudo cat /sys/firmware/acpi/tables/SLIC
cat: /sys/firmware/acpi/tables/SLIC: そのようなファイルやディレクトリはありません
$ sudo cat /sys/firmware/acpi/tables/MSDM | tee ~/.win11/msdm.bin
$ sudo dmidecode -t 0 -u | awk '/^\t\t[0-9A-F][0-9A-F]( |$)/' | xxd -r -p > ~/.win11/smbios_type_0.bin
$ sudo dmidecode -t 1 -u | awk '/^\t\t[0-9A-F][0-9A-F]( |$)/' | xxd -r -p > ~/.win11/smbios_type_1.bin
$ ls -la ~/.win11/
合計 8242188
drwxrwxr-x  2 mukai mukai       4096 11月  6 10:13 .
drwxr-x--- 26 mukai mukai       4096 11月  6 10:08 ..
-rw-rw-r--  1 mukai mukai 7650324480 11月  6 09:52 Win11_25H2_Japanese_x64.iso
-rw-rw-r--  1 mukai mukai         85 11月  6 10:11 msdm.bin
-rw-rw-r--  1 mukai mukai         61 11月  6 10:12 smbios_type_0.bin
-rw-rw-r--  1 mukai mukai        159 11月  6 10:13 smbios_type_1.bin
-rw-rw-r--  1 mukai mukai  789645312 11月  6 10:07 virtio-win-0.1.285.iso
```

```
$ sudo cp /etc/apparmor.d/abstractions/libvirt-qemu /etc/apparmor.d/abstractions/libvirt-qemu.orig
$ sudo nano /etc/apparmor.d/abstractions/libvirt-qemu
$ sudo apparmor_parser -r /etc/apparmor.d/abstractions/libvirt-qemu
AppArmor parser error for /etc/apparmor.d/abstractions/libvirt-qemu in profile /etc/apparmor.d/abstractions/openssl at line 13: syntax error, unexpected TOK_MODE, expecting TOK_OPEN
$ sudo cat /etc/apparmor.d/abstractions/libvirt-qemu | tail -n 3
  include if exists <local/abstractions/libvirt-qemu>

/home/mukai/.win11/** r,
```

インストールメディアを指定する画面から進める際に「エミュレーターはパス'/home/mukai/.win11/Win11_25H2_Japanese_x64.iso'を検索する権限を持っていません。今すぐこれを訂正しますか？」というダイアログが表示される。「今後これらのティレクトリーについては確認しない。」にチェックを入れて「はい」で進める。

メモリとCPUはホストの半分で15800(/31601)と7(/14)

ストレージは256GBあげる

vGPUはできないらしい、ざんねん。

[Intel® Core™ Ultra 7 Processor 155U](https://www.intel.com/content/www/us/en/products/sku/237327/intel-core-ultra-7-processor-155u-12m-cache-up-to-4-80-ghz/specifications.html)

> <dl><dt>Product Collection</dt><dd>Intel® Core™ Ultra processors (Series 1)</dd>
> <dt>Code Name</dt><dd>Products formerly Meteor Lake</dd></dl>

[Graphics Virtualization Technologies Support for Each Intel® Graphics Family](https://www.intel.com/content/www/us/en/support/articles/000093216/graphics/processor-graphics.html)

> | Product Family | Graphics Virtualization Technology Supported |
> | --- | --- |
> | Intel® Core™ Ultra Processor (Series 1) processor family (Formerly Known as Meteor Lake) | Not Supported |

[Dockerと同じ](../0199d804-fa2f-7925-82e1-003224f2d920/README.md)ように、MTUを明示的に設定する必要がある。

```xml
<interface type="network">
  <mac address="52:54:00:6f:7d:05"/>
  <source network="default"/>
  <model type="virtio"/>
  <link state="up"/>
  <mtu size="1420"/>
  <address type="pci" domain="0x0000" bus="0x02" slot="0x00" function="0x0"/>
</interface>
```

設定を完了してインストールを開始しようとするとエラーが発生

```
インストールを完了できません: 'internal error: process exited while connecting to monitor: qemu-system-x86_64: -acpitable file=/home/mukai/.win11/msdm.bin: can't open file /home/mukai/.win11/msdm.bin: Permission denied'

Traceback (most recent call last):
  File "/usr/share/virt-manager/virtManager/asyncjob.py", line 72, in cb_wrapper
    callback(asyncjob, *args, **kwargs)
  File "/usr/share/virt-manager/virtManager/createvm.py", line 2008, in _do_async_install
    installer.start_install(guest, meter=meter)
  File "/usr/share/virt-manager/virtinst/install/installer.py", line 695, in start_install
    domain = self._create_guest(
             ^^^^^^^^^^^^^^^^^^^
  File "/usr/share/virt-manager/virtinst/install/installer.py", line 637, in _create_guest
    domain = self.conn.createXML(initial_xml or final_xml, 0)
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3/dist-packages/libvirt.py", line 4529, in createXML
    raise libvirtError('virDomainCreateXML() failed')
libvirt.libvirtError: internal error: process exited while connecting to monitor: qemu-system-x86_64: -acpitable file=/home/mukai/.win11/msdm.bin: can't open file /home/mukai/.win11/msdm.bin: Permission denied
```

```
$ getfacl /home/mukai/.win11/msdm.bin
getfacl: 絶対パス名から先頭の '/' を削除

# file: home/mukai/.win11/msdm.bin
# owner: mukai
# group: mukai
user::rw-
group::rw-
other::r--

$ sudo setfacl -m u:libvirt-qemu:r /home/mukai/.win11/msdm.bin
$ getfacl /home/mukai/.win11/msdm.bin
getfacl: 絶対パス名から先頭の '/' を削除

# file: home/mukai/.win11/msdm.bin
# owner: mukai
# group: mukai
user::rw-
user:libvirt-qemu:r--
group::rw-
mask::rw-
other::r--

sudo setfacl -m u:libvirt-qemu:x /home/mukai
```

やっとVMが起動する。「ショートカットの置き換えを許可する　アプリ仮想マシンマネージャーがショットカットを置き換えることを要求しています　&lt;Super&gt;Escapeを押してショートカットを復元できます。」せめて何を置き換えるつもりか説明してほしいものだ。許可

電源プラン高パフォーマンス
画面タイムアウトなし
ディスプレイ拡大縮小150%（SPICE側で表示＞画面の拡大縮小＞常に行う＋仮想マシンのウィンドウを自動的にリサイズ　と併用）
sudoの有効化
開発者モードon
エクスプローラー＞ファイル拡張子を表示するon
デバイスの暗号化off
OneDrive削除

### ESLint

dbaeumer.vscode-eslint


```
$ sudo apt install --yes gddrescue
$ sudo apt install --yes xxhash
```

[指紋認証](../019a76b5-4753-7fac-8408-7141665a8faa/README.md)

よくCapsLockを間違えて入力してしまいめんどくさい。

```
$ gsettings get org.gnome.desktop.input-sources xkb-options
@as []
$ gsettings set org.gnome.desktop.input-sources xkb-options "['caps:none']"
$ gsettings get org.gnome.desktop.input-sources xkb-options
['caps:none']
```

ログアウトして再ログインすればCapsLockが無効化される

### Tkinter

```
$ python3
Python 3.12.3 (main, Nov  6 2025, 13:44:16) [GCC 13.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import tkinter as tk
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ModuleNotFoundError: No module named 'tkinter'
```

ないんだ。でも確かにvenvとかpipも入っていないんだっけ。

- https://stackoverflow.com/a/18143036

### Inkscape

今回はAppImage版を選択した。`~/.local/bin`に作るディレクトリ名は`.desktop`の名前に合わせておくと丸いのかも（つまりダウンロードした直後に一回extractして中身を見ておく）

[AppImageを手動でインストールする（Ubuntu 24.04）](../articles/0194d66f-55fa-7755-93b3-7b488b50edaa/README.md)

```
~/.local/bin/org.inkscape.Inkscape/squashfs-root$ diff org.inkscape.Inkscape.desktop.orig org.inkscape.Inkscape.desktop
263,264c263,264
< Exec=inkscape %F
< TryExec=inkscape
---
> Exec=/home/mukai/.local/bin/org.inkscape.Inkscape/squashfs-root/AppRun %F
> TryExec=/home/mukai/.local/bin/org.inkscape.Inkscape/squashfs-root/AppRun
267c267
< Icon=org.inkscape.Inkscape
---
> Icon=/home/mukai/.local/bin/org.inkscape.Inkscape/squashfs-root/org.inkscape.Inkscape.png
303c303
< Exec=inkscape
---
> Exec=/home/mukai/.local/bin/org.inkscape.Inkscape/squashfs-root/AppRun
```

いつの間にかNautilusに`/home/mukai/ドキュメント`・`/home/mukai/ミュージック`・`/home/mukai/ピクチャ`・`/home/mukai/ビデオ`・`/home/mukai/ダウンロード`へのブックマークが追加されている（もとから残っていた？）これらは一番はじめに英語に切り替えたのですべてリンク切れの状態になっている。右クリック＞ブックマークから削除

### GIMP

```
$ mkdir ~/.local/bin/org.gimp.GIMP.Stable
$ mv ~/Downloads/GIMP-3.0.6-x86_64.AppImage ~/.local/bin/org.gimp.GIMP.Stable/
$ cd ~/.local/bin/org.gimp.GIMP.Stable/
~/.local/bin/org.gimp.GIMP.Stable$ chmod +x GIMP-3.0.6-x86_64.AppImage
~/.local/bin/org.gimp.GIMP.Stable$ ./GIMP-3.0.6-x86_64.AppImage --appimage-extract
~/.local/bin/org.gimp.GIMP.Stable$ chmod +x squashfs-root/org.gimp.GIMP.Stable.desktop
~/.local/bin/org.gimp.GIMP.Stable$ ln -s /home/mukai/.local/bin/org.gimp.GIMP.Stable/squashfs-root/org.gimp.GIMP.Stable.desktop ~/.local/share/applications/org.gimp.GIMP.Stable.desktop
~/.local/bin/org.gimp.GIMP.Stable$ cp squashfs-root/org.gimp.GIMP.Stable.desktop squashfs-root/org.gimp.GIMP.Stable.desktop.orig
~/.local/bin/org.gimp.GIMP.Stable$ vim squashfs-root/org.gimp.GIMP.Stable.desktop
~/.local/bin/org.gimp.GIMP.Stable$ diff squashfs-root/org.gimp.GIMP.Stable.desktop.orig squashfs-root/org.gimp.GIMP.Stable.desktop
271,273c271,273
< Exec=org.gimp.GIMP.Stable %U
< TryExec=org.gimp.GIMP.Stable
< Icon=org.gimp.GIMP.Stable
---
> Exec=/home/mukai/.local/bin/org.gimp.GIMP.Stable/squashfs-root/AppRun %U
> TryExec=/home/mukai/.local/bin/org.gimp.GIMP.Stable/squashfs-root/AppRun
> Icon=/home/mukai/.local/bin/org.gimp.GIMP.Stable/squashfs-root/org.gimp.GIMP.Stable.svg
```

よく見たらGIMPのdesktopはリンクだったから、origへの退避を間違えている気がする（書き戻す際に`.orig`を外すだけでは不足）。

```
$ ls -l /home/mukai/.local/bin/org.gimp.GIMP.Stable/squashfs-root/
合計 40
-rwxrwxrwx 1 mukai mukai  1553 10月  6 03:06 AppRun
lrwxrwxrwx 1 mukai mukai    51 11月 26 11:56 org.gimp.GIMP.Stable.desktop -> usr/share/applications/org.gimp.GIMP.Stable.desktop
-rw-r--r-- 1 mukai mukai 17099 11月 26 11:58 org.gimp.GIMP.Stable.desktop.orig
-rw-r--r-- 1 mukai mukai  9604 10月  6 03:06 org.gimp.GIMP.Stable.svg
drwxr-xr-x 9 mukai mukai  4096 11月 26 11:56 usr
```

上の記事でも触れたけれど、展開したsquashfs-rootから実行するのはAppImageファイルを直接実行するのとは処理が違うらしい。GIMPではちゃんと分岐できているようだが、Arduino IDEのように分岐を実装していないものもある。

```
$ /home/mukai/.local/bin/org.gimp.GIMP.Stable/squashfs-root/AppRun
Running without type2-runtime. AppDir is /home/mukai/.local/bin/org.gimp.GIMP.Stable/squashfs-root
```

こっちのほうがよさそう。

```
$ diff ~/.local/bin/org.inkscape.Inkscape/squashfs-root/org.inkscape.Inkscape.desktop.orig ~/.local/bin/org.inkscape.Inkscape/squashfs-root/org.inkscape.Inkscape.desktop
263,264c263,264
< Exec=inkscape %F
< TryExec=inkscape
---
> Exec=/home/mukai/.local/bin/org.inkscape.Inkscape/Inkscape-ebf0e94-x86_64.AppImage %F
> TryExec=/home/mukai/.local/bin/org.inkscape.Inkscape/Inkscape-ebf0e94-x86_64.AppImage
267c267
< Icon=org.inkscape.Inkscape
---
> Icon=/home/mukai/.local/bin/org.inkscape.Inkscape/squashfs-root/org.inkscape.Inkscape.png
303c303
< Exec=inkscape
---
> Exec=/home/mukai/.local/bin/org.inkscape.Inkscape/Inkscape-ebf0e94-x86_64.AppImage
$ diff ~/.local/bin/org.gimp.GIMP.Stable/squashfs-root/org.gimp.GIMP.Stable.desktop.orig ~/.local/bin/org.gimp.GIMP.Stable/squashfs-root/org.gimp.GIMP.Stable.desktop
271,273c271,273
< Exec=org.gimp.GIMP.Stable %U
< TryExec=org.gimp.GIMP.Stable
< Icon=org.gimp.GIMP.Stable
---
> Exec=/home/mukai/.local/bin/org.gimp.GIMP.Stable/GIMP-3.0.6-x86_64.AppImage %U
> TryExec=/home/mukai/.local/bin/org.gimp.GIMP.Stable/GIMP-3.0.6-x86_64.AppImage
> Icon=/home/mukai/.local/bin/org.gimp.GIMP.Stable/squashfs-root/org.gimp.GIMP.Stable.svg
```

で、この場合、FUSEが必要

```
$ /home/mukai/.local/bin/org.inkscape.Inkscape/Inkscape-ebf0e94-x86_64.AppImage
dlopen(): error loading libfuse.so.2

AppImages require FUSE to run. 
You might still be able to extract the contents of this AppImage 
if you run it with the --appimage-extract option. 
See https://github.com/AppImage/AppImageKit/wiki/FUSE 
for more information
```

- https://github.com/AppImage/AppImageKit/wiki/FUSE

> For example, on **Debian (>= 13) and Ubuntu (>= 24.04)**:
> 
> ```
> sudo add-apt-repository universe
> sudo apt install libfuse2t64
> ```
>
> Note: In Ubuntu 24.04, the `libfuse2` package was [renamed](https://changelogs.ubuntu.com/changelogs/pool/universe/f/fuse/fuse_2.9.9-8.1build1/changelog) to `libfuse2t64`.

```
sudo apt install pv arping nmap pdftk-java
```

`uv run`でもplaywrightは使えるが、ブラウザのインストールは別途必要

```
$ sudo /home/mukai/.local/bin/uv run --with playwright python -m playwright install-deps
$ uv run --with playwright python -m playwright install
```

VS Codeのeditor.colorDecoratorsを切る

### Windows VMをローカルネットワークのプリンターに触らせたい

現在のネットワークを確認。

```
$ ip link
<mask>
```

`enx3c18a0226677`が対象の実ネットワークであることを確認する。直接IPが付いているか

```
$ ip addr show enx3c18a0226677
2: enx3c18a0226677: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    inet 192.168. ...
```

`inet ...`が重要で、直接付いていることを表している。

現在の接続名を確認

```
$ nmcli connection show
NAME                     UUID                                  TYPE       DEVIC>
netplan-enx3c18a0226677  <mask>                                ethernet   enx3c>
...
```

ブリッジを作成してIPを付け替える

```
$ nmcli connection add type bridge ifname br0 con-name br0
$ nmcli connection add type ethernet ifname enx3c18a0226677 con-name br0-slave master br0
$ nmcli connection modify br0 ipv4.method auto
$ nmcli connection modify br0 ipv6.method auto
$ nmcli connection down netplan-enx3c18a0226677
$ nmcli connection up br0

$ ip addr show br0
8: br0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
    link/ether <mask>            brd ff:ff:ff:ff:ff:ff
```

来てない。スレーブも明示的に起動する必要がある。

```
$ nmcli connection up br0-slave
$ ip addr show br0
8: br0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
    link/ether <mask>            brd ff:ff:ff:ff:ff:ff
    inet 192.168. ...
```

`inet ...`がついた。

VMのネットワーク設定も変更する

NIC > ネットワークソースを「ブリッジデバイス」に変更。必要があればデバイス名を変更。

VS Codeシェル補完どうもうまくないように見える。`terminal.integrated.suggest.enabled = false`

### バッテリーヘルス対策

このPCは1日の1/3程度は電源に接続したまま起動している。これはバッテリー寿命にはよくないだろう。

Ubuntu 24.04に（Ubuntu Serverにも）標準搭載されているupowerで確かめてみると、今のところは良好のようだ。

```
$ upower -e
/org/freedesktop/UPower/devices/battery_BAT0
/org/freedesktop/UPower/devices/line_power_AC
/org/freedesktop/UPower/devices/line_power_ucsi_source_psy_USBC000o001
/org/freedesktop/UPower/devices/line_power_ucsi_source_psy_USBC000o002
/org/freedesktop/UPower/devices/mouse_dev_E2_BF_22_A8_B2_36
/org/freedesktop/UPower/devices/DisplayDevice
$ upower -i /org/freedesktop/UPower/devices/battery_BAT0
  native-path:          BAT0
  vendor:               Sunwoda
  model:                5B11H56385
  serial:               530
  power supply:         yes
  updated:              2026年01月13日 09時25分23秒 (11 seconds ago)
  has history:          yes
  has statistics:       yes
  battery
    present:             yes
    rechargeable:        yes
    state:               fully-charged
    warning-level:       none
    energy:              55.29 Wh
    energy-empty:        0 Wh
    energy-full:         56.02 Wh
    energy-full-design:  57 Wh
    energy-rate:         0 W
    voltage:             13.044 V
    charge-cycles:       40
    percentage:          98%
    capacity:            98.2807%
    technology:          lithium-polymer
    icon-name:          'battery-full-charged-symbolic'
```

良好なうちに対策を施す。この用途で有名なのはTLPというコマンドラインツールらしい。

- https://github.com/linrunner/TLP
- https://linrunner.de/tlp/installation/ubuntu.html

```
$ sudo add-apt-repository ppa:linrunner/tlp
$ sudo apt update
$ sudo apt install tlp
```

- tlp
- tlp-pd - オプション・マウスクリックでプロファイルを選択（バージョン 1.9 以降）
- tlp-rdw - オプション・無線デバイスウィザード

まあメインツールだけでよいだろう。

ChatGPTによると、以下の対策が有効という

- 満充電を避ける
- 0%を避ける
- 高温を避ける
- たまに（3ヶ月ごと程度）10%程度まで使ってから100%まで充電するキャリブレーションを行う

充電と放電を自動制御して常に75%〜80%に保つように設定。デフォルトも75〜80ぽいけど。

```
$ sudo tlp-stat -b
指紋読取装置に右の人指し指を置いてください
--- TLP 1.9.1 --------------------------------------------

+++ Battery Care
Plugin: thinkpad
Supported features: charge thresholds, chargeonce, discharge, recalibrate
Driver usage:
* natacpi (thinkpad_acpi) = active (charge thresholds, force-discharge)
Parameter value ranges:
* START_CHARGE_THRESH_BAT0/1:  0(off)..96(default)..99
* STOP_CHARGE_THRESH_BAT0/1:   1..100(default)

+++ ThinkPad Battery Status: BAT0 (Main / Internal)
...
/sys/class/power_supply/BAT0/charge_control_start_threshold =     75 [%]
/sys/class/power_supply/BAT0/charge_control_end_threshold   =     80 [%]
/sys/class/power_supply/BAT0/charge_behaviour               = [auto] inhibit-charge force-discharge
...

$ grep "START_CHARGE_THRESH_BAT0" /etc/tlp.conf
#START_CHARGE_THRESH_BAT0=75
$ grep "STOP_CHARGE_THRESH_BAT0" /etc/tlp.conf
#STOP_CHARGE_THRESH_BAT0=80
$ sudo vim /etc/tlp.conf  # コメントアウトを解除
$ systemctl reboot

$ sudo tlp-stat -b
...
/sys/class/power_supply/BAT0/charge_control_start_threshold =     75 [%]
/sys/class/power_supply/BAT0/charge_control_end_threshold   =     80 [%]
/sys/class/power_supply/BAT0/charge_behaviour               = [auto] inhibit-charge force-discharge
...
```

### Scribus

AppImage版のダウンロードリンクを探すのが少し混乱した。リリースページにSourceForgeへのリンクがあった。

- https://wiki.scribus.net/canvas/1.6.5_Release
- [AppImageを手動でインストールする（Ubuntu 24.04）](../articles/0194d66f-55fa-7755-93b3-7b488b50edaa/README.md)

```
$ mkdir ~/.local/bin/scribus-1.6.5
$ cd ~/.local/bin/scribus-1.6.5
$ mv ~/Downloads/scribus-1.6.5-linux-x86_64.AppImage .
$ chmod +x scribus-1.6.5-linux-x86_64.AppImage
$ cp scribus-1.6.5-linux-x86_64.AppImage scribus-1.6.5-linux-x86_64.AppImage.orig
$ ./scribus-1.6.5-linux-x86_64.AppImage --appimage-extract
$ find squashfs-root -name *.desktop
squashfs-root/scribus.desktop
squashfs-root/usr/share/applications/python3.12.desktop
squashfs-root/usr/share/applications/scribus.desktop
$ chmod +x squashfs-root/scribus.desktop
$ cp squashfs-root/scribus.desktop squashfs-root/scribus.desktop.orig
$ ln -s ~/.local/bin/scribus-1.6.5/squashfs-root/scribus.desktop ~/.local/share/applications/scribus.desktop
$ diff -u squashfs-root/scribus.desktop.orig squashfs-root/scribus.desktop
--- squashfs-root/scribus.desktop.orig  2026-01-13 14:39:06.328662443 +0900
+++ squashfs-root/scribus.desktop       2026-01-13 14:43:24.680336069 +0900
@@ -93,9 +93,9 @@
 GenericName[zh_CN]=桌面出版
 GenericName[zh_TW]=桌面出版
 GenericName[zu]=Ukushicilelwa kwe-Desktop
-TryExec=scribus
-Exec=scribus %f
-Icon=scribus
+TryExec=/home/mukai/.local/bin/scribus-1.6.5/scribus-1.6.5-linux-x86_64.AppImage
+Exec=/home/mukai/.local/bin/scribus-1.6.5/scribus-1.6.5-linux-x86_64.AppImage %f
+Icon=/home/mukai/.local/bin/scribus-1.6.5/squashfs-root/scribus.png
 Terminal=false
 MimeType=application/vnd.scribus;
 Categories=Qt;Graphics;Publishing;
```
