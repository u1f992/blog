## 障害対応メモ

前提として起動用10.8.0.1はWireGuardサーバーを兼ねていて、10.8.0.2とは同じLAN内の機器。

```
local$ ssh mukai@10.8.0.1

10.8.0.1$ wakeonlan <MAC-10.8.0.2>
10.8.0.1$ exit

local$ ssh mukai@10.8.0.2
...（起動せず）
```

10.8.0.2をWoLで起動したはずがVPNに参加してこない。

以下の検証から、MACは合っているようだ。

```
10.8.0.1$ ip neigh | grep "<MAC>"
192.168.0.5 dev enp1s0 lladdr <MAC> STALE 
fe80::2d8:61ff:feff:5801 dev enp1s0 lladdr <MAC> STALE 
```

ルーターの設定画面にアクセスして確認してみる。以下のコマンドで10.8.0.1から見た192.168.0.1:80を、localhost:8888に転送できる。あとはローカルマシン側のWebブラウザでlocalhost:8888にアクセスする

```
local$ ssh -L 8888:192.168.0.1:80 mukai@10.8.0.1
```

ログを見ると、直近の時間で、DHCPでアドレス割当された記録がある。これならPCは起動していると考えられる。

```
... dhcps - 0.ntc: アドレス割り当て ,192.168.0.5 ,<MAC> ,LAN
```

LAN側アドレスがわかるが、対象のPCはWireGuard内でしかSSHを開けていないのでアクセスはできない。

応答するのでやはりPCは起動していそうだ。

```
10.8.0.1$ ping 192.168.0.5 -c 1
PING 192.168.0.5 (192.168.0.5) 56(84) bytes of data.
64 bytes from 192.168.0.5: icmp_seq=1 ttl=64 time=0.291 ms

--- 192.168.0.5 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.291/0.291/0.291/0.000 ms
10.8.0.1$ ip neigh show 192.168.0.5
192.168.0.5 dev enp1s0 lladdr 00:d8:61:ff:58:01 REACHABLE 
```

考えられるのは、何らかのミスでPC起動後にWireGuardが起動していない？

```
10.8.0.1$ mukai@glm-mn3350:~$ sudo wg show wg0
interface: wg0
  public key: <key>
  private key: (hidden)
  listening port: 51820

...

peer: <key>
  endpoint: 192.168.0.1:1053
  allowed ips: 10.8.0.2/32, fd42:42:42::2/128
  latest handshake: 13 hours, 14 minutes, 8 seconds ago
  transfer: 512.02 MiB received, 122.40 MiB sent
```

### 後で確認すること

#### 1. PCは起動しているか？　ログイン画面まで到達しているか？

してた。

#### 2. WireGuardは起動しているか？　自動起動設定が死んでいないか？

```
$ sudo systemctl status wg-quick@wg0
● wg-quick@wg0.service - WireGuard via wg-quick(8) for wg0
     Loaded: loaded (/usr/lib/systemd/system/wg-quick@.service; enabled; preset: enabled)
     Active: active (exited) since Wed 2025-11-19 09:49:06 JST; 10h ago
       Docs: man:wg-quick(8)
             man:wg(8)
             https://www.wireguard.com/
             https://www.wireguard.com/quickstart/
             https://git.zx2c4.com/wireguard-tools/about/src/man/wg-quick.8
             https://git.zx2c4.com/wireguard-tools/about/src/man/wg.8
   Main PID: 2413 (code=exited, status=0/SUCCESS)
        CPU: 24ms

11月 19 09:49:06 mukai-MS-7B98 systemd[1]: Starting wg-quick@wg0.service - WireGuard via wg-quick(8) for wg0...
11月 19 09:49:06 mukai-MS-7B98 wg-quick[2413]: [#] ip link add wg0 type wireguard
11月 19 09:49:06 mukai-MS-7B98 wg-quick[2413]: [#] wg setconf wg0 /dev/fd/63
11月 19 09:49:06 mukai-MS-7B98 wg-quick[2413]: [#] ip -4 address add 10.8.0.2/24 dev wg0
11月 19 09:49:06 mukai-MS-7B98 wg-quick[2413]: [#] ip -6 address add fd42:42:42::2/64 dev wg0
11月 19 09:49:06 mukai-MS-7B98 wg-quick[2413]: [#] ip link set mtu 1420 up dev wg0
11月 19 09:49:06 mukai-MS-7B98 systemd[1]: Finished wg-quick@wg0.service - WireGuard via wg-quick(8) for wg0.

$ sudo journalctl -u wg-quick@wg0 -b
11月 19 09:49:06 mukai-MS-7B98 systemd[1]: Starting wg-quick@wg0.service - WireGuard via wg-quick(8) for wg0...
11月 19 09:49:06 mukai-MS-7B98 wg-quick[2413]: [#] ip link add wg0 type wireguard
11月 19 09:49:06 mukai-MS-7B98 wg-quick[2413]: [#] wg setconf wg0 /dev/fd/63
11月 19 09:49:06 mukai-MS-7B98 wg-quick[2413]: [#] ip -4 address add 10.8.0.2/24 dev wg0
11月 19 09:49:06 mukai-MS-7B98 wg-quick[2413]: [#] ip -6 address add fd42:42:42::2/64 dev wg0
11月 19 09:49:06 mukai-MS-7B98 wg-quick[2413]: [#] ip link set mtu 1420 up dev wg0
11月 19 09:49:06 mukai-MS-7B98 systemd[1]: Finished wg-quick@wg0.service - WireGuard via wg-quick(8) for wg0.

$ sudo systemctl is-enabled wg-quick@wg0
enabled

```

全部正常だ……

```
$ sudo tcpdump -i eno1 udp port 51820 -n
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eno1, link-type EN10MB (Ethernet), snapshot length 262144 bytes
... : UDP, length 148
... : UDP, length 148
^C
2 packets captured
2 packets received by filter
0 packets dropped by kernel

$ sudo tcpdump -i wlp3s0 udp port 51820 -n
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on wlp3s0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
^C
0 packets captured
0 packets received by filter
0 packets dropped by kernel
```

ハンドシェイクもちゃんと出ている。なぜ返ってこない？

サーバー側で見た設定の以下の箇所に注目する。10.8.0.2の設定ではグローバルIPを指定しているのに、サーバーからはルーターのアドレスが見えている。つまり、ルーター側のヘアピンNATを利用していたことがわかる（グローバルIPを指定していたのは冗長だったといえる）。このヘアピンNATになんらかの不具合が起こっているのでは

```
peer: <key>
  endpoint: 192.168.0.1:1053
```

そこで、別端末をLANに参加させた後、先程までssh接続できていたはずの10.8.0.1にアクセスしてみたらタイムアウトが発生する。ヘアピンNATがかなり怪しいことがわかってきた。

民生品ルーターの管理画面からは簡易的なログしか見られない……が、深夜に、リモート制御による再起動がかけられていることがわかった。これがかなり怪しい。

```
2025-11-19 01:55:08 staup - 0.ntc: システム起動(初期化)成功
2025-11-19 01:55:18 dhcpc - 0.ntc: アドレス割り当て ,<IP> ,WAN
2025-11-19 01:55:21 dhcps - 0.ntc: アドレス割り当て ,192.168.0.2 ,<MAC> ,LAN
2025-11-19 01:55:22 iface - 2.ntc: LAN1 ポートリンクアップ
2025-11-19 01:55:22 iface - 2.ntc: LAN4 ポートリンクアップ
2025-11-19 01:55:23 voip  - 4.ntc: レジスタ要求
2025-11-19 01:55:23 voip  - 0.ntc: レジスタ成功 200OK
2025-11-19 01:55:24 voip  - 4.ntc: レジスタ要求
2025-11-19 01:55:24 voip  - 0.ntc: レジスタ成功 200OK
2025-11-19 01:55:36 voip  -15.war: リンクダウン
2025-11-19 01:55:36 dhcpc - 0.ntc: アドレス割り当て ,<IP> ,WAN
2025-11-19 01:55:37 voip  - 4.ntc: レジスタ要求
2025-11-19 01:55:37 voip  - 0.ntc: レジスタ成功 200OK
2025-11-19 01:55:38 voip  - 4.ntc: レジスタ要求
2025-11-19 01:55:38 voip  - 0.ntc: レジスタ成功 200OK
2025-11-19 01:55:54 tr069 - 0.inf: TR069 Inform 開始 EventCode=1 BOOT/7 TRANSFER COMPLETE/M Download
2025-11-19 01:55:56 tr069 - 2.inf: TR069 Method=Inform FaultCode=0
2025-11-19 01:55:56 tr069 - 2.inf: TR069 Method=TransferComplete FaultCode=0
2025-11-19 01:55:57 tr069 - 1.inf: TR069 Inform 完了
```

これ以上はわかりそうにない。ルーターを再起動してみる。が、ダメ

```
$ sudo traceroute -n -U -p 51820 118.156.113.172
traceroute to 118.156.113.172 (118.156.113.172), 30 hops max, 60 byte packets
 1  118.156.113.172  0.462 ms  0.552 ms  0.628 ms
```

ということは192.168.0.3まで届いていないな？　ルーターの設定を初期化してセットアップし直したが変わらず。

お手上げ

wg0.confの`Endpoint = <IP>:51820`としているのを、`192.168.0.3:51820`とすればVPNには参加できるようになる。起動用PCは常に同じLANにあるはずだから、これはまあ許容できる。問題はLANから参加することもWANからVPNに参加することもあるスマートフォンで、グローバルIPを指定している間は自宅Wi-Fi＋WireGuardに接続できない。

### 今後の対応

起動用PCからはLAN内でssh接続を許可。このPCはDHCP固定割当も設定されているので、以下の設定でよい。

```
$ sudo ufw allow from 192.168.0.3 to any port 22 proto tcp
$ sudo ufw status numbered
```

LAN側アドレスは変わる可能性があり、`10.8.0.1$ mukai@192.168.0.5`ではないかもしれないが、上の手順で割当は容易に確認できる。
