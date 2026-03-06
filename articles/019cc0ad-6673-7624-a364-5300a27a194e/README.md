## SSHからUbuntu Serverのインストールを進める

```
Language: English

Layout: Japanese
Variant: Japanese

(X) Ubuntu Server
[X] Search for third-party drivers
```

enp3s0（Realtek Semiconductor Co., Ltd. / RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller）が「disabled  autoconfiguration failed」になっているので手動設定。今回は予約した静的IPを使う。

```
Edit IPv4 >
IPv4 Method: Maunal
Subnet: 192.168.8.0/24 ← 同LANの別PCでのip route結果`
192.168.8.0/24 dev br0 proto kernel scope link src 192.168.8.78 ...`より
Address: 192.168.x.x
Gateway: 192.168.8.1 ← 同じく`default via 192.168.8.1 dev br0 proto dhcp ...`より
Name servers: 1.1.1.1 ← Cloudflare DNS
Search domains:
```

```
$ sudo ufw status
Status: inactive
$ sudo systemctl status ssh
disabled
$ sudo systemctl enable --now ssh
$ sudo passwd ubuntu-server
なんでもいい　aとかでいい
```

SSHクライアントから

```
$ ssh ubuntu-server@192.168.x.x
$ sudo snap run subiquity
```

tty1で開いているインストーラーは放置してよいだろう。

SSHではなぜか日本語が選べた（メニューが日本語になったりはしないようだ）。ネットワーク設定まではtty1のものが引き継がれている

```
Proxy configuration
  Proxy address:

Ubuntu archive mirror configuration
  Mirror address: http://archive.ubuntu.com/ubuntu

(X) Use an entire disk
  [X] Set up this disk as an LVM group

Your servers name: legion-t5-28imb05 ← sudo dmidecode | grep --after-context=9 "System Information"の「Family」から

Upgrade to Ubuntu Pro
  (X) Skip for now

SSH configuration
  [X] Install OpenSSH server

Third-party drivers
  The following third-party drivers were found. Do you want to install them?

* nvidia-driver- ...

(X) Install all third-party drivers

Featured server snaps
  選択なし
```

Reboot Nowのあと締め出される（当然）。端末に戻り、指示通りインストーラーメディアを取り出してEnterを入力すると再起動がかかる。

再起動後は同じIPアドレスで待ち受けているが、鍵が変わっているので対応する必要がある。

```
$ ssh user@192.168.x.x
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
...

$ ssh-keygen -f '/home/mukai/.ssh/known_hosts' -R '192.168.x.x'
```
