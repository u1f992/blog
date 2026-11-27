## imageRUNNER ADVANCE DX C3935FのLinux用ドライバ

- https://canon.jp/support/software/os?pr=5740

2種類ある。LIPS4は拡張キットを利用している場合に使用する。

- LIPSLX/ CARPS2 Printer Driver for Linux Ver.6.40（32bit & 64bit）
- LIPS4 Printer Driver for Linux Ver.6.40（32bit & 64bit）

```
$ sha256sum ../../linux-lipslx-drv-v640-jp-02.tar.gz 
8cad131e2759c894ec9de51016de4053ad4203bc361fe3f883310abf4679e617  ../../linux-lipslx-drv-v640-jp-02.tar.gz
$ ./install.sh
現在のユーザーはmukaiです。
rootに切り替えてから操作してください。
$ sudo ./install.sh
このインストーラは、ドライバリリース時点でサポート期間内だった以下のディストリビューションでの実行をおすすめします。
・ Fedora/Ubuntu/CentOS/Debian/UOS/Kylin OS/NeoKylin OS

サポート期間外のディストリビューションで実行した場合は、インストール完了後にシステムライブラリの追加インストールが必要になることがあります。

なお、インストールにはインターネット接続が必要です。

インストールを続行しますか? [Y/N]y

#----------------------------------------------------#
# Install Start
#----------------------------------------------------#
Machine Type = amd64
Package Type = deb
Package list = 
    ./x64/Debian/cnrdrvcups-lipslx_6.40-1.02_amd64.deb

#----------------------------------------------------#
# Install Package Check
#----------------------------------------------------#
 OK: cups

#----------------------------------------------------#
# Install Package Check
#----------------------------------------------------#
 OK: cups-bsd

#----------------------------------------------------#
# Install Package Check
#----------------------------------------------------#
 OK: libcups2t64

#----------------------------------------------------#
# Install Package Check
#----------------------------------------------------#
 OK: libcupsimage2t64

#----------------------------------------------------#
# Install Package Check
#----------------------------------------------------#
 OK: libgtk-3-0t64

#----------------------------------------------------#
# Install Package Check
#----------------------------------------------------#
#----------------------------------------------------#
# apt-get update
#----------------------------------------------------#
ヒット:1 https://download.docker.com/linux/ubuntu resolute InRelease
ヒット:2 https://cli.github.com/packages stable InRelease                                                
取得:3 https://packages.microsoft.com/repos/code stable InRelease [3,590 B]                              
ヒット:4 https://downloads.claude.ai/claude-desktop/apt/stable stable InRelease                          
取得:5 https://packages.microsoft.com/repos/code stable/main amd64 Packages [31.6 kB]                    
ヒット:6 https://persistent.oaistatic.com/codex-app-prod/linux/deb stable InRelease                      
取得:7 https://dl.google.com/linux/chrome-stable/deb stable InRelease [2,548 B]                          
取得:8 https://dl.google.com/linux/chrome-stable/deb stable/main amd64 Packages [1,406 B]                
取得:9 http://security.ubuntu.com/ubuntu resolute-security InRelease [137 kB]                            
ヒット:10 http://jp.archive.ubuntu.com/ubuntu resolute InRelease 
取得:11 http://jp.archive.ubuntu.com/ubuntu resolute-updates InRelease [137 kB]
取得:12 http://security.ubuntu.com/ubuntu resolute-security/main amd64 Packages [764 kB]
取得:13 http://jp.archive.ubuntu.com/ubuntu resolute-backports InRelease [137 kB]
取得:14 http://security.ubuntu.com/ubuntu resolute-security/main Translation-en [165 kB]
取得:15 http://security.ubuntu.com/ubuntu resolute-security/main amd64 Components [46.7 kB]
取得:16 http://security.ubuntu.com/ubuntu resolute-security/universe amd64 Packages [228 kB]            
取得:17 http://jp.archive.ubuntu.com/ubuntu resolute-updates/main amd64 Packages [927 kB]         
取得:18 http://security.ubuntu.com/ubuntu resolute-security/universe Translation-en [74.4 kB]       
取得:19 http://security.ubuntu.com/ubuntu resolute-security/universe amd64 Components [62.7 kB]   
取得:20 http://jp.archive.ubuntu.com/ubuntu resolute-updates/main Translation-en [205 kB]                
取得:21 http://jp.archive.ubuntu.com/ubuntu resolute-updates/main amd64 Components [110 kB]
取得:22 http://jp.archive.ubuntu.com/ubuntu resolute-updates/universe amd64 Packages [401 kB]
取得:23 http://jp.archive.ubuntu.com/ubuntu resolute-updates/universe Translation-en [127 kB]
取得:24 http://jp.archive.ubuntu.com/ubuntu resolute-updates/universe amd64 Components [208 kB]
取得:25 http://jp.archive.ubuntu.com/ubuntu resolute-backports/universe amd64 Components [1,056 B]
3,771 kB を 4秒 で取得しました (977 kB/s)
パッケージリストを読み込んでいます... 完了

#----------------------------------------------------#
# apt-get install libjpeg62
#----------------------------------------------------#
パッケージリストを読み込んでいます... 完了
依存関係ツリーを作成しています... 完了        
状態情報を読み取っています... 完了        
Solving dependencies... 完了
以下のパッケージが自動でインストールされましたが、もう必要とされていません:
  libflashrom1 libftdi1-2 libjcat1
これを削除するには 'sudo apt autoremove' を利用してください。
以下のパッケージが新たにインストールされます:
  libjpeg62
アップグレード: 0 個、新規インストール: 1 個、削除: 0 個、保留: 68 個。
86.2 kB のアーカイブを取得する必要があります。
この操作後に追加で 197 kB のディスク容量が消費されます。
取得:1 http://jp.archive.ubuntu.com/ubuntu resolute/universe amd64 libjpeg62 amd64 1:6b2-4build1 [86.2 kB]
86.2 kB を 1秒 で取得しました (66.0 kB/s)
以前に未選択のパッケージ libjpeg62:amd64 を選択しています。
(データベースを読み込んでいます ... 現在 215459 個のファイルとディレクトリがインストールされています。)
.../libjpeg62_1%3a6b2-4build1_amd64.deb を展開する準備をしています ...
libjpeg62:amd64 (1:6b2-4build1) を展開しています...
libjpeg62:amd64 (1:6b2-4build1) を設定しています ...
libc-bin (2.43-2ubuntu2.7) のトリガを処理しています ...

 OK: libjpeg62

#----------------------------------------------------#
# Install Package Check
#----------------------------------------------------#
 OK: libgcrypt20

#----------------------------------------------------#
# Install Package Check
#----------------------------------------------------#
 OK: libjbig0

#----------------------------------------------------#
# Install Printer Driver (dpkg -i -G --force-overwrite)
#----------------------------------------------------#
以前に未選択のパッケージ cnrdrvcups-lipslx を選択しています。
(データベースを読み込んでいます ... 現在 215466 個のファイルとディレクトリがインストールされています。)
.../cnrdrvcups-lipslx_6.40-1.02_amd64.deb を展開する準備をしています ...
cnrdrvcups-lipslx (6.40-1.02) を展開しています...
cnrdrvcups-lipslx (6.40-1.02) を設定しています ...
Restarting cups (via systemctl): cups.service.
gnome-menus (3.38.1-1ubuntu1) のトリガを処理しています ...
desktop-file-utils (0.28-1build1) のトリガを処理しています ...
hicolor-icon-theme (0.18-2build1) のトリガを処理しています ...
```

cnsetuputil2でプリンターを登録する。

- https://oip.manual.canon/USRMA-0585-zz-DR-jaJP/contents/dlu-inst-reg_utility.html#lcn_reg_printer

「C3935」（FAX無し品番）を選択

/usr/share/cups/doc-root/help/network.html によると、プリンターが他のプロトコルに対応しているならLPDを使わないよう勧めている。lpdとsocketのうちsocketを選ぶ。
