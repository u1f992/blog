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

#### 2. WireGuardは起動しているか？　自動起動設定が死んでいないか？

```
$ sudo systemctl status wg-quick@wg0
$ sudo journalctl -u wg-quick@wg0 -b
$ sudo systemctl is-enabled wg-quick@wg0
```

### 今後の対応

起動用PCからはLAN内でssh接続を許可。このPCはDHCP固定割当も設定されているので、以下の設定でよい。

```
$ sudo ufw allow from 192.168.0.3 to any port 22 proto tcp
$ sudo ufw status numbered
```

LAN側アドレスは変わる可能性があり、`10.8.0.1$ mukai@192.168.0.5`ではないかもしれないが、上の手順で割当は容易に確認できる。
