## 別のPCのX Windowアプリをローカルの画面で表示させる

例えば、うちでは10.8.0.2のPCが最もパワフルなので、ほとんどの作業はこちらでやりたい。

サーバー側で設定が必要。

```
$ sudo vim /etc/ssh/sshd_config
→ X11Forwarding yes をアンコメント。デフォルト有効かも
$ sudo systemctl restart sshd
$ sudo apt install xauth
```

ローカル側では、以下のどちらかでSSH接続する。`-X`ではリモート側のXクライアントがローカルXサーバへアクセスできる権限が制限される。`-Y`では制限されない（trusted）。

```
$ ssh -X user@host
$ ssh -Y user@host
```

接続された先でGUIアプリを起動すると、ローカルのXサーバで表示される。

```
$ xcalc &
```

ただしファイルを開くダイアログなどで表示されるファイルシステムはリモートのものになる。

**サーバー側のファイルシステムがローカルに**マウントする方法は以下の通り。実体はサーバー側にあることに注意。逆にしたければ、リモートからローカルにsshfsを実行できるようにしておく必要がある。

サーバーとローカルでマウントポイントを用意

```
$ mkdir -p /tmp/Public
```

ローカルで

```
$ sudo vim /etc/fuse.conf
→ user_allow_other をアンコメント

$ sshfs /tmp/Public user@host:/tmp/Public -o allow_other -o default_permissions -o reconnect
（user@hostの/tmp/Publicを、ローカルの/tmp/Publicにマウントする）
```

切断はローカルで

```
$ fusermount -u /tmp/Public
```
