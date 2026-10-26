## ThinkPad X1 Carbon Gen 12にUbuntu 26.04をセットアップする

### インストール

```
Choose your language: 日本語　次へ
Ubuntuのアクセシビリティ　次へ
キーボードレイアウトを選択してください　日本語
　キーボードバリアントを選択　日本語
インターネットの接続方法を選択してください　有線接続を使用
Ubuntuで何をしますか？　Ubuntuをインストール
Ubuntuをインストールしますか？　対話式インストール
開始時にどのアプリをインストールしますか？　既定の選択
推奨するプロプライエタリなソフトウェアをインストールしますか？
　x グラフィックスとWi-Fi機器用のサードパーティ製ソフトウェアをインストールする
　x 追加のメディアフォーマット用のサポートをダウンロードしてインストールする
Ubuntuをどのようにインストールしますか？　ディスクを削除してUbuntuをインストールする
暗号化とファイルシステム　暗号化しない
アカウントの設定
　あなたの名前　Koutaro Mukai
　コンピューターの名前　mukai-ThinkPad-X1-Carbon-Gen-12
　ユーザー名を入力　mukai
　x　ログイン時にパスワードを要求する
現在地　Tokyo
タイムゾーン　Asia/Tokyo

Ubuntu 26.04.1 LTSのインストールは完了し、使い始める準備が整いました　今すぐ再起動
Please remove the installation medium, then press ENTER:

Ubuntu 26.04.1 LTSへようこそ！　次へ
Ubuntu Proを有効化する　今回はスキップ
位置情報サービス　オフ
Ubuntuの改善を手助けする
　Ubuntuチームにシステムデータを共有する　オフ
　Ubuntuチームにエラーレポートを送る　オフ
Ubuntuの見た目を選択
　スタイル　デフォルト
　Accent Color 桃（オレンジの2つ右）
さらにアプリケーションを追加する　完了
```

### ホームディレクトリの英語化

```
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ LANG=C xdg-user-dirs-update --force
Moving DESKTOP directory from デスクトップ to Desktop
Moving DOWNLOAD directory from ダウンロード to Downloads
Moving TEMPLATES directory from テンプレート to Templates
Moving PUBLICSHARE directory from 公開 to Public
Moving DOCUMENTS directory from ドキュメント to Documents
Moving MUSIC directory from ミュージック to Music
Moving PICTURES directory from ピクチャ to Pictures
Moving VIDEOS directory from ビデオ to Videos
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ rmdir デスクトップ ダウンロード テンプ レート 公開 ドキュメント ミュージック ピクチャ ビデオ
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ systemctl reboot

標準フォルダーの名前を現在の言語に合わせて更新しますか？
x 次回から表示しない
古い名前のままにする
```

Nautilusのサイドバーにある「ドキュメント」「ミュージック」「ピクチャ」「ビデオ」「ダウンロード」は、初回セットアップ時に書き出されたブックマークで、日本語名のディレクトリを指したまま残る。警告アイコンが付いて開けなくなるので、参照先を英語パスに書き換える。ブックマークファイルは1行につき「URI 表示名」の書式で、表示名を指定すればサイドバーの日本語名はそのまま残せる。

```
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ cat ~/.config/gtk-3.0/bookmarks
file:///home/mukai/%E3%83%89%E3%82%AD%E3%83%A5%E3%83%A1%E3%83%B3%E3%83%88
file:///home/mukai/%E3%83%9F%E3%83%A5%E3%83%BC%E3%82%B8%E3%83%83%E3%82%AF
file:///home/mukai/%E3%83%94%E3%82%AF%E3%83%81%E3%83%A3
file:///home/mukai/%E3%83%93%E3%83%87%E3%82%AA
file:///home/mukai/%E3%83%80%E3%82%A6%E3%83%B3%E3%83%AD%E3%83%BC%E3%83%89
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ cp ~/.config/gtk-3.0/bookmarks ~/.config/gtk-3.0/bookmarks.orig
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ cat > ~/.config/gtk-3.0/bookmarks <<'EOF'
file:///home/mukai/Documents ドキュメント
file:///home/mukai/Music ミュージック
file:///home/mukai/Pictures ピクチャ
file:///home/mukai/Videos ビデオ
file:///home/mukai/Downloads ダウンロード
EOF
```

書き込むと即座にサイドバーへ反映される。

### デスクトップ設定

```
壁紙はPicturesの直下に置いて、右クリック　背景として設定

［設定］＞［マウスとタッチパッド］＞［タッチパッド］タブ＞［タッチパッド］無効化
［設定］＞［Ubuntuデスクトップ］＞［Dockを自動的に隠す］

$ gsettings get org.gnome.settings-daemon.plugins.power lid-close-ac-action
'suspend'
$ gsettings set org.gnome.settings-daemon.plugins.power lid-close-ac-action 'nothing'
$ sudo nano /etc/systemd/logind.conf
  # 以下2項目を設定
  HandleLidSwitch=ignore
  HandleLidSwitchDocked=ignore

［設定］＞［システム］＞［指紋認証ログイン］

$ sudo pam-auth-update
  #「Fingerprint authentication」にチェック

スプラッシュスクリーン無効化

$ grep "GRUB_CMD"  /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_CMDLINE_LINUX=""
$ sudo nano /etc/default/grub
$ grep "GRUB_CMD"  /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT=""
GRUB_CMDLINE_LINUX=""
$ sudo update-grub
```

[以前](../articles/019a13c7-2a12-7453-b753-6114042fb4e8/README.md)TLPで設定したバッテリー満充電75%〜80%制限は不揮発で保持されている。設定を変えたくなったらTLPをインストールすることになる。

### Google Chrome

```
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ cd Downloads/
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~/Downloads$ wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~/Downloads$ sudo dpkg -i google-chrome-stable_current_amd64.deb 

Google ChromeおよびChromeOS追加利用規約
同意する

x Google Chromeを既定のブラウザにする
x 使用統計データと障害レポートわGoogleに自動送信します

Chromeにログイン
個人Googleアカウントでログイン

入力を省いて、時間を節約
履歴とタブを同期すると…　ONにする

別のアカウントを追加
新しいプロフィールでChromeにログインしますか？　利用しない

Chromeをピン留めしてFirefox外す
```

### ツール

#### Git＋GitHub CLI

```
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ sudo apt update && sudo apt install --yes git
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ # https://github.com/cli/cli/blob/ed40e856ffecd31286733876c613a2d3745e12bd/docs/install_linux.md#debian
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ (type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
        && sudo mkdir -p -m 755 /etc/apt/keyrings \
        && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
        && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
        && sudo mkdir -p -m 755 /etc/apt/sources.list.d \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
        && sudo apt update \
        && sudo apt install gh -y
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ git config --global user.name "Koutaro Mukai" && git config --global user.email "mukai.k1011k@outlook.jp"
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ gh auth login
```

#### dotfiles

```
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ git clone https://github.com/u1f992/dotfiles.git
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ cd dotfiles/
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~/dotfiles$ ./link.sh 
```

#### Claude

デスクトップアプリ

```
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ # https://code.claude.com/docs/ja/desktop-linux#install
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ sudo apt install --yes curl gnupg
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ sudo curl -fsSLo /usr/share/keyrings/claude-desktop-archive-keyring.asc https://downloads.claude.ai/claude-desktop/key.asc
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ gpg --show-keys /usr/share/keyrings/claude-desktop-archive-keyring.asc
pub   rsa4096 2026-03-30 [SCE]
      31DDDE24DDFAB679F42D7BD2BAA929FF1A7ECACE
uid                      Anthropic Claude Code Release Signing <security@anthropic.com>

mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/claude-desktop-archive-keyring.asc] https://downloads.claude.ai/claude-desktop/apt/stable stable main" | sudo tee /etc/apt/sources.list.d/claude-desktop.list
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ sudo apt update && sudo apt install claude-desktop
```

グローバルショートカットの追加を提案される。あまり嬉しくないけど、毎回出るのが嫌になって追加してしまった。

```
Add Keyboard Shortcuts
Claude shortcut: Ctrl+Alt+Space
Cancel  Add
```

何度か起動していると以下のメッセージが出た。特に問題はなさそう。

```
ハードウェアアクセラレーションが無効化されました
```

Claude Code

ClaudeデスクトップアプリをインストールしてもCLIにはパスは通らない。

```
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ which claude
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ ls -l ~/.local/bin/claude
ls: cannot access '/home/mukai/.local/bin/claude': No such file or directory
```

`/home/mukai/.config/Claude/claude-code/2.1.299/20ca25213130/claude`に実体は一応あるようだが、現時点のドキュメントでは、CLIで使いたいなら別途インストールする指示になっているので、それに従う

> https://code.claude.com/docs/en/desktop-quickstart.md
> 
> > [!NOTE]
> >
> > These cases are covered on other pages:
> >
> > * **Already set up**: see [Use Claude Code Desktop](/docs/en/desktop) for everything the Code tab can do
> > * **Want `claude` in your terminal**: [install the CLI](/docs/en/quickstart) separately

```
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ # https://code.claude.com/docs/en/quickstart#step-1-install-claude-code
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ curl -fsSL https://claude.ai/install.sh | bash
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ claude login
```

#### Python

```
$ sudo apt install --yes python3-venv
```

#### mise

このマシンでは以下のツールをmise下で管理する

- Node.js
- uv

```
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~/Documents/blog$ curl -fsSL https://mise.run | sh
mise: selected 2026.10.14 (minimum release age: 24h)
mise: installing mise...
######################################################################## 100.0%
mise: installed successfully to /home/mukai/.local/bin/mise
mise: run the following to activate mise in your shell:
echo "eval \"\$(/home/mukai/.local/bin/mise activate bash)\"" >> ~/.bashrc

mise: run `mise doctor` to verify this is set up correctly
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~/Documents/blog$ echo "eval \"\$(/home/mukai/.local/bin/mise activate bash)\"" >> ~/.bashrc

--- ターミナルを一旦終了

mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ mise --version
              _                                        __              
   ____ ___  (_)_______        ___  ____        ____  / /___ _________
  / __ `__ \/ / ___/ _ \______/ _ \/ __ \______/ __ \/ / __ `/ ___/ _ \
 / / / / / / (__  )  __/_____/  __/ / / /_____/ /_/ / / /_/ / /__/  __/
/_/ /_/ /_/_/____/\___/      \___/_/ /_/     / .___/_/\__,_/\___/\___/
                                            /_/                 by @jdx
2026.10.14 linux-x64 (2026-10-18)
mise hint keep mise updated automatically with mise settings self_update.auto=true
```

`mise exec`すればグローバルに追加されるけど、他に追加する方法はないのか？`mise install`でグローバルにインストールされる？後で確認する。

```
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ mise exec node@24 -- node --version
✓ installed 1 tool in 1.3s: node@24.22.0
v24.22.0
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ node --version
mise ERROR No version is set for shim: node
Set a global default version with one of the following:
mise use -g node@24.22.0
mise ERROR Version: 2026.10.14 linux-x64 (2026-10-18)
mise ERROR Run with --verbose or MISE_VERBOSE=1 for more information
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ mise use -g node@24.22.0
mise ~/.config/mise/config.toml tools: node@24.22.0
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ node --version
v24.22.0

mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ mise exec uv -- uv --version
✓ installed 1 tool in 919ms: uv@0.13.1
uv 0.13.1 (x86_64-unknown-linux-gnu)
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ uv
mise ERROR No version is set for shim: uv
Set a global default version with one of the following:
mise use -g uv@0.13.1
mise ERROR Version: 2026.10.14 linux-x64 (2026-10-18)
mise ERROR Run with --verbose or MISE_VERBOSE=1 for more information
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ mise use -g uv@0.13.1
mise ~/.config/mise/config.toml tools: uv@0.13.1
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ uv --version
uv 0.13.1 (x86_64-unknown-linux-gnu)
```

#### WireGuardとSSH

```
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ sudo apt --yes install wireguard
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ sudo ls /etc/wireguard/

wg0.confを作成

mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ sudo cp wg0.conf /etc/wireguard/
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ sudo systemctl enable --now wg-quick@wg0

疎通確認
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ ssh mukai@10.8.0.1


mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ sudo apt install --yes openssh-server
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ sudo systemctl enable --now ssh

mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ sudo ufw allow in on wg0 to any port 22 proto tcp
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ sudo ufw reload 
ファイアウォールは有効になっていません（再読込を飛ばします）
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ sudo ufw enable
ファイアウォールはアクティブかつシステムの起動時に有効化されます。
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ sudo ufw reload 
ファイアウォールを再読込しました
```

別の端末から疎通確認

#### tmux

```
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ sudo apt install --yes tmux
```

#### Vim

```
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ sudo apt install --yes vim-gtk3

:PlugInstall
```

#### AppImage

- GIMP
- Inkscape
- Scribus
- ImageMagick

あまりうまい方法が思いつかない。AppImageをランチャーに登録するために別のアプリを入れるのも本末転倒な気がする。当面は手動で管理してみる。

```
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~/Downloads$ ls
GIMP-3.2.6-x86_64.AppImage  ImageMagick-7.1.2-34-gcc-x86_64.AppImage  Inkscape-1.4.4.AppImage  google-chrome-stable_current_amd64.deb  scribus-1.6.6-linux-x86_64.AppImage
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~/Downloads$ ls *.AppImage
GIMP-3.2.6-x86_64.AppImage  ImageMagick-7.1.2-34-gcc-x86_64.AppImage  Inkscape-1.4.4.AppImage  scribus-1.6.6-linux-x86_64.AppImage
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~/Downloads$ chmod a+x GIMP-3.2.6-x86_64.AppImage 
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~/Downloads$ mv GIMP-3.2.6-x86_64.AppImage ~/.local/bin/
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~/Downloads$ GIMP-3.2.6-x86_64.AppImage 
```

```
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~/Downloads$ ln -s ~/.local/bin/ImageMagick-7.1.2-34-gcc-x86_64.AppImage ~/.local/bin/magick
```

#### Slack

https://slack.com/intl/ja-jp/downloads/linux

Snap, debから選べるらしい。Snapが第一に見えるのでSnap版を使ってみる……のだが、「Snap storeからダウンロード」をクリックしてもなにも起こらない。

https://snapcraft.io/slack

```
$ sudo snap install slack
```

#### ChatGPT / Codex

https://chatgpt.com/ja-JP/download/

```
$ sudo dpkg -i chatgpt_amd64.deb

あなたの仕事に最も近いものは？
エンジニアリング
[x] 自分向けのタスクを提案

スキップ
ChatGPTへ移動

他のAIアプリから作業をインポート
スキップ

利用を開始する＞セットアップを非表示
```

アカウントの切り替えはログアウトして再ログインが必要。初めてのアカウントにログインしても初期設定は現れなかった。

`codex`にはパスは通らないようだ。

```
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:/tmp/tmp.mhbtqYB6wO$ codex
コマンド 'codex' が見つかりません。もしかして:
  command 'godex' from deb golang-golang-x-tools (1:0.42.0+ds-3)
次を試してみてください: sudo apt install <deb name>
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:/tmp/tmp.mhbtqYB6wO$ which codex
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:/tmp/tmp.mhbtqYB6wO$
```

https://learn.chatgpt.com/docs/codex/cli#getting-started

Launching Codexで起動しなかった。初回起動時からログイン済みの状態になっていた。

```
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~/Downloads$ curl -fsSL https://chatgpt.com/codex/install.sh | sh
==> Installing Codex CLI
==> Detected platform: Linux (x64)
==> Resolved version: 0.163.0
==> Downloading Codex CLI
==> Installing standalone package to /home/mukai/.codex/packages/standalone/releases/0.163.0-x86_64-unknown-linux-musl
==> /home/mukai/.local/bin is already on PATH
==> Current terminal: codex
==> Future terminals: open a new terminal and run: codex
Codex CLI 0.163.0 installed successfully.
Start Codex now? [y/N] y
==> Launching Codex
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~/Downloads$ codex
```

#### virt-manager

```
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ sudo apt install --yes virt-manager
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ groups mukai
mukai : mukai adm cdrom sudo dip plugdev users lpadmin lxd
```

Group libvirtに追加すると`qemu:///system`を触れるようになる

今回はあえて追加しないことにした。このシステムには仮想マシンは作らず、リモートの仮想マシンだけを扱う。

```
$ virsh --connect qemu+ssh://mukai@10.8.0.2/system list --all
```

リモートサーバー側で設定変更

```
$ sudo vim /etc/ssh/sshd_config.d/10-gatewayports.conf

GatewayPorts clientspecified

$ sudo sshd -t
$ sudo sshd -T | grep -i gatewayports    # → gatewayports clientspecified と出ればOK
$ sudo systemctl reload ssh

$ sudo ufw allow from 192.168.0.0/24 to 192.168.0.3 port 9100 proto tcp
```

こっちのLANの何らかに、リモートの仮想マシンから触る

```
ssh -N -o ExitOnForwardFailure=yes -R 192.168.0.3:9100:192.168.x.x:9100 mukai@10.8.0.2
```

#### Docker

- https://docs.docker.com/engine/install/ubuntu/
  - https://github.com/docker/docs/blob/226023fc89bdeb3f051c4c8c697d04ed5f5bcd2c/content/manuals/engine/install/ubuntu.md

```
$ sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc | cut -f1)

# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

- https://docs.docker.com/engine/install/linux-postinstall/
  - https://github.com/docker/docs/blob/226023fc89bdeb3f051c4c8c697d04ed5f5bcd2c/content/manuals/engine/install/linux-postinstall.md

```
sudo groupadd docker
sudo usermod -aG docker $USER
```

#### Remmina

- https://remmina.org/
- https://snapcraft.io/remmina

```
sudo snap install remmina
```

Snap版では追加の設定が必要と表示された。ダイアログの指示通り実行

```
sudo snap connect remmina:audio-record :audio-record
sudo snap connect remmina:avahi-observe :avahi-observe
sudo snap connect remmina:cups-control :cups-control
sudo snap connect remmina:mount-observe :mount-observe
sudo snap connect remmina:password-manager-service :password-manager-service
sudo snap connect remmina:ssh-keys :ssh-keys
sudo snap connect remmina:ssh-public-keys :ssh-public-keys
```

「Remmina VNCプラグイン」を選択
サーバーはIPのみ、`user@`つけない
ユーザー名・ユーザーパスワード
SSHトンネルを有効化
認証方式：公開鍵
ユーザー名必要
パスワード不要
秘密鍵の明示必要

#### chezmoi

- https://www.chezmoi.io/install/#one-line-binary-install

```
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
```

