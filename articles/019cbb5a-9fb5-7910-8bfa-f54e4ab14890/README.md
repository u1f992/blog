## Ubuntu Desktop (24.04.4)のライブ環境でのリモート作業

```shellsession
$ # ローカルIPアドレスを確認しておく
$ ip addr

$ sudo apt install openssh-server
$ sudo systemctl enable --now ssh
$ sudo ufw allow from 192.168.0.0/16 to any port 22 proto tcp

$ # パスワードが未設定では入れない（パスワードを聞かれ、空では通らない）
$ sudo passwd ubuntu
```

以降はリモートで作業できる

```shellsession
$ ssh ubuntu@192.168.x.x
```

sshfsでディレクトリをSSHクライアント側にマウント

```shellsession
$ # 既定でsftpが無効になっているようだ
$ sftp ubuntu@192.168.x.xx
subsystem request failed on channel 0
$ # 有効化
$ ssh ubuntu@192.168.x.xx "
  echo 'Subsystem sftp /usr/lib/openssh/sftp-server' | sudo tee -a /etc/ssh/sshd_config
  sudo systemctl reload sshd
"

$ # 認証済みソケット作成
$ # ユニークなファイル名を予約
$ SSH_CTL=$(mktemp -u)
$ # -M：ControlMasterモード。このプロセスが認証済みソケットを作成・管理する親になる
$ # -N：リモートでコマンドを実行しない。ポートフォワードやソケット維持だけに使う
$ # -f：バックグラウンドで実行。パスワード入力後に端末を返す
$ ssh -o StrictHostKeyChecking=no -M -S "$SSH_CTL" -N -f ubuntu@192.168.x.xx

$ # sshfsマウント
$ MOUNTPOINT=$(mktemp -d)
$ # Dockerでマウントしたければallow_rootが必要
$ sshfs -o ssh_command="ssh -S $SSH_CTL",allow_root ubuntu@192.168.x.xx:/somewhere "$MOUNTPOINT"


$ # クリーンアップ
$ fusermount -u "$MOUNTPOINT"
$ # -O：ControlMasterに対する操作を指定する。exitのほかにcheckなど
$ # exitと同時にソケットも削除される
$ ssh -S "$SSH_CTL" -O exit ubuntu@192.168.x.xx
$ rmdir "$MOUNTPOINT"
```
