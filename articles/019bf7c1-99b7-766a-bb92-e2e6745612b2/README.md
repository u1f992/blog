## SMBを特定ディレクトリにマウント

`vers`がわからなければ省略可。匿名アクセスが許可されているなら`guest`、文字化けするなら`,iocharset=utf8`を追加。

```
$ sudo mkdir -p /mnt/share
$ sudo mount -t cifs //192.168.x.x/SHARE_NAME /mnt/share -o username=USERNAME,password=PASSWORD,vers=3.0

アンマウント
$ sudo umount /mnt/share


このエラーがでたらパッケージ不足
mount: /mnt/work_user: bad option; for several filesystems (e.g. nfs, cifs) you might need a /sbin/mount.<type> helper program.
       dmesg(1) may have more information after failed mount system call.

$ sudo apt update && sudo apt --yes install cifs-utils


このエラーは正しいversの指定を求められている
$ sudo mount -t cifs //192.168.x.x/share /mnt/share -o guest
mount error(22): Invalid argument
Refer to the mount.cifs(8) manual page (e.g. man mount.cifs) and kernel log messages (dmesg)
$ sudo dmesg | tail -n 80
...
[ 2308.191095] CIFS: No dialect specified on mount. Default has changed to a more secure dialect, SMB2.1 or later (e.g. SMB3.1.1), from CIFS (SMB1). To use the less secure SMB1 dialect to access old servers which do not support SMB3.1.1 (or even SMB3 or SMB2.1) specify vers=1.0 on mount.
...

$ sudo mount -t cifs //192.168.x.x/share /mnt/share -o guest,vers=1.0
```

コマンドにパスワードを書かないためには資格情報ファイルを作成する。名前は任意だが権限に注意。

```
$ sudo vim /root/.smbcred

  username=USERNAME
  password=PASSWORD

$ sudo mount -t cifs //192.168.x.x/SHARE_NAME /mnt/share -o credentials=/root/.smbcred,vers=3.0
```

常にマウントするなら、この資格情報ファイルを作成した上で`/etc/fstab`に追記する。ただしディレクトリは事前に作成しておく必要がある。

- `_netdev` → ネットワークが有効になってからマウントする指定。起動時にマウント失敗してブートが止まるようなトラブルを防ぐ
- `nofail` → 失敗しても起動を止めない
- `x-systemd.automount` → 起動時に実マウントしない。実際にアクセスした瞬間にマウント
  - `x-systemd.idle-timeout=60` → 60秒アクセスがなければ自動アンマウント
  - 今回は使用していない。直感的に、うかつにwatch（inotify）したりするとトラブルになりそう

`uid`／`gid`は必要に応じて合わせる。SMBはそもそもUNIXパーミッションとは仕組みが異なる（WindowsのACLモデル）。`uid`／`gid`やパーミッションの設定はLinux側からみた見た目だけを制御し、実際に操作できるかはサーバー側による。

第5フィールド（dump）dumpコマンド（バックアップ用）が対象にするかどうか。通常0。

- 0 = 対象にしない
- 1 = 対象にする

第6フィールド（fsck pass）起動時に fsck（ファイルシステムチェック）を自動実行する順番。CIFSのようなネットワークFSはfsckの対象にならないので、通常0。

- 0 = fsck しない
- 1 = ルート /（通常これだけ）
- 2 = それ以外を後から

```
$ sudo vim /etc/fstab

  //192.168.x.x/SHARE_NAME  /mnt/share  cifs  credentials=/root/.smbcred,vers=3.0,_netdev,nofail,x-systemd.automount,uid=1000,gid=1000,file_mode=0644,dir_mode=0755  0  0

$ sudo mount -a
mount: (hint) your fstab has been modified, but systemd still uses
       the old version; use 'systemctl daemon-reload' to reload.
$ sudo systemctl daemon-reload
$ sudo mount -a
```
