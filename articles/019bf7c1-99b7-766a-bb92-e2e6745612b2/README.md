## SMBを特定ディレクトリにマウント

`vers`がわからなければ省略可。匿名アクセスが許可されているならユーザー名とパスワードのかわりに`guest`、文字化けするなら`,iocharset=utf8`を追加。`uid`／`gid`は必要に応じて合わせる。SMBはそもそもUNIXパーミッションとは仕組みが異なる（WindowsのACLモデル）。`uid`／`gid`やパーミッションの設定はLinux側からみた見た目だけを制御し、実際に操作できるかはサーバー側による。

```
$ sudo mkdir -p /media/share
$ sudo mount -t cifs //192.168.x.x/SHARE_NAME /media/share -o username=USERNAME,password=PASSWORD,vers=3.0,uid=1000,gid=1000

アンマウント
$ sudo umount /media/share


このエラーがでたらパッケージ不足
mount: /media/SHARE_NAME: 間違ったオプション設定; (nfs, cifs など)ファイルシステムによっては /sbin/mount.<タイプ> のヘルパープログラムが必要です.
       mount システムコールの失敗について、 dmesg(1) で詳しい情報が得られる場合があります。

$ sudo apt update && sudo apt --yes install cifs-utils


このエラーは、正しいバージョンの指定を求めているようだ
mount error(22): Invalid argument
Refer to the mount.cifs(8) manual page (e.g. man mount.cifs) and kernel log messages (dmesg)

$ sudo dmesg | tail -n 10
[234325.007137] CIFS: Attempting to mount //192.168.x.x/SHARE_NAME
[234325.015140] CIFS: VFS: cifs_mount failed w/return code = -22
```

コマンドにパスワードを書かないためには資格情報ファイルを作成する。名前は任意だが権限に注意。

```
$ sudo vim /root/.smbcred

  username=USERNAME
  password=PASSWORD

$ sudo mount -t cifs //192.168.x.x/SHARE_NAME /media/share -o credentials=/root/.smbcred,vers=3.0
```

常にマウントするなら、この資格情報ファイルを作成した上で`/etc/fstab`に追記する。ただしディレクトリは事前に作成しておく必要がある。

- `_netdev` → ネットワークが有効になってからマウントする指定。起動時にマウント失敗してブートが止まるようなトラブルを防ぐ
- `nofail` → 失敗しても起動を止めない
- `x-systemd.automount` → 起動時に実マウントしない。実際にアクセスした瞬間にマウント
  - `x-systemd.idle-timeout=60` → 60秒アクセスがなければ自動アンマウント
  - 今回は使用していない。直感的に、うかつにwatch（inotify）したりするとトラブルになりそう


第5フィールド（dump）dumpコマンド（バックアップ用）が対象にするかどうか。通常0。

- 0 = 対象にしない
- 1 = 対象にする

第6フィールド（fsck pass）起動時に fsck（ファイルシステムチェック）を自動実行する順番。CIFSのようなネットワークFSはfsckの対象にならないので、通常0。

- 0 = fsck しない
- 1 = ルート /（通常これだけ）
- 2 = それ以外を後から

```
$ sudo vim /etc/fstab

  //192.168.x.x/SHARE_NAME  /media/share  cifs  credentials=/root/.smbcred,vers=3.0,_netdev,nofail,x-systemd.automount,uid=1000,gid=1000,file_mode=0644,dir_mode=0755  0  0

$ sudo mount -a
mount: (hint) your fstab has been modified, but systemd still uses
       the old version; use 'systemctl daemon-reload' to reload.
$ sudo systemctl daemon-reload
$ sudo mount -a
```
