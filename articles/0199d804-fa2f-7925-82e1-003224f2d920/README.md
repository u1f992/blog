## GLM-MN3350

- https://www.gm-japan.co.jp/product/mn3350/

<dl>
<dt>CPU</dt><dd>Intel Celeron N3350 1.1-2.4GHz</dd>
<dt>RAM</dt><dd>4GB</dd>
<dt>ストレージ</dt><dd>64GB</dd>
<dt>備考</dt><dd>2021年にメルカリで購入</dd>
</dl>

Ubuntu Server 24.04.3をインストール。デフォルトから変更する点は、キーボード設定を「Layout: Japanese / Variant: Japanese」、「Search for third-party drivers」を有効化。他にはenp1s0がDHCP有効になっている点が後で重要だった。

インストール直後の再起動後、`networkctl status enp1s0`を実行し`192.168.0.3`を割り当てられたことを確認。サーバーをシャットダウン。ルーターに固定割り当て設定を追加。ルーターの設定を永続化し再起動。サーバーを再起動。するとなぜか`192.168.0.4`を割り当てられている。

Ubuntu Serverが既定で使用するsystemd-networkdのDHCPクライアントは、デフォルトでDUIDをClient IDに使用する（Ubuntu Desktopが使用するNetworkManagerの内蔵DHCPクライアントはMACを使用する？　未確認）。

/etc/netplan/99-set-dhcp-identifier-mac.yamlを以下の内容で作成する。なお同ディレクトリには50-cloud-init.yamlが存在するが、cloud-init自体は/etc/cloud/cloud-init.disabledによって無効化されている（ローカルマシンにインストールされていることを検知して自動で無効化する？　未確認）。ファイル名は任意だが既存の設定ファイルに順序で負けない名前にすること。

```
network:
  version: 2
  ethernets:
    enp1s0:
      dhcp4: true
      dhcp-identifier: mac
```

再起動後`networkctl status enp1s0`を実行し、`.3`を割り当てられたことを確認する。

このマシンをVPNサーバーとし、VPN経由でSSHアクセスを開放する。

```
$ sudo apt update
$ sudo apt --yes install wireguard
$ cd ~/wireguard
$ bash
$ umask 077
$ wg genkey | tee glm-mn3350_private.key | wg pubkey > glm-mn3350_public.key
$ wg genkey | tee client_private.key | wg pubkey > client_public.key
$ exit
```

<figure>
<figcaption>/etc/wireguard/wg0.conf</figcaption>

```
[Interface]
Address = 10.8.0.1/24, fd42:42:42::1/64
ListenPort = 51820
PrivateKey = (glm-mn3350_private.keyの中身)

[Peer]
PublicKey = (client_public.keyの中身)
AllowedIPs = 10.8.0.2/32, fd42:42:42::2/128
```

</figure>

メモ：Vimで、termの内容を選択してヤンクする。termウィンドウにカーソルがある状態で`Ctrl+W`、`Shift+N`。`i`で通常のターミナルに復帰。

WireGuardを有効化。

```
$ sudo systemctl enable --now wg-quick@wg0
```

Ubuntu Serverでは、既定ではファイアウォールが起動していない。

```
$ sudo ufw status
Status: inactive
$ sudo ufw enable
Firewall is active and enabled on system startup
```

```
$ sudo ufw allow 51820/udp
$ sudo ufw allow in on wg0 proto tcp to any port 22
```

ルーター側で「ポートマッピング設定」を行う。

SSHサーバーをインストールして有効化。

```
$ sudo apt install openssh-server
$ sudo systemctl status ssh
$ sudo systemctl enable --now ssh  # disabledなら
```

クライアント側でもwireguardを有効化する。

<figure>
<figcaption>wg0.conf</figcaption>

```
[Interface]
Address = 10.8.0.2/24, fd42:42:42::2/64
PrivateKey = (client_private.key の中身)

[Peer]
PublicKey = (glm-mn3350_public.key の中身)
Endpoint = (GLM-MN3350のグローバルIP):51820
AllowedIPs = 10.8.0.0/24, fd42:42:42::/64
PersistentKeepalive = 25
```

</figure>

`PersistentKeepalive = 25`がないと、WoLで起動した後自動でVPNに接続されなかった。

あとでWoLをやるつもり。

```
$ sudo apt install --yes wakeonlan
$ cat wakeonlan-(client-name).sh 
#!/bin/sh
wakeonlan (client_mac)
```

VPNを介してクライアント間で通信（10.8.0.2に開けたSSHに10.8.0.3のスマホからアクセスしたい）には追加の設定が必要。

- `/etc/sysctl.conf`と`/sys/ufw/sysctl.conf`がある。ufwのほうが後に起動して前者を上書きするはず。

```
$ sudo ufw route allow in on wg0 out on wg0
$ sudo vim /etc/ufw/sysctl.conf
  以下の3行をアンコメント
  #net/ipv4/ip_forward=1
  #net/ipv6/conf/default/forwarding=1
  #net/ipv6/conf/all/forwarding=1
$ sudo vim /etc/default/ufw
  # DEFAULT_FORWARD_POLICY="DROP"を"ACCEPT"に変更
$ sudo ufw reload
```

### WireGuard内の端末からのすべてのWeb通信を、WireGuardサーバー経由にする

一般的なVPNの使い方といえばこちらか

#### クライアント側の追加設定

```
[Interface]
...
DNS = 1.1.1.1

[Peer]
...
- AllowedIPs = 10.8.0.0/24, fd42:42:42::/64
+ AllowedIPs = 0.0.0.0/0, ::/0
```

#### サーバー側の追加設定

サーバーからインターネットへ出るインターフェイスを調べる。ここでは`enp1s0`だとわかる

```
$ ip route show default
default via 192.168.0.1 dev enp1s0 proto dhcp src 192.168.0.3 metric 100 
```

ファイル先頭にIPマスカレード設定を追加

```
$ sudo cat /etc/ufw/before.rules  | head -n 7
*nat
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s 10.8.0.0/24 -o enp1s0 -j MASQUERADE
COMMIT

#
# rules.before
$ sudo cat /etc/ufw/before6.rules | head -n 7
*nat
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s fd42:42:42::/64 -o enp1s0 -j MASQUERADE
COMMIT

#
# rules.before
```

設定が正しく反映されたことを確認

```
$ sudo ufw reload
$ sudo iptables -t nat -L POSTROUTING -n -v
Chain POSTROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination 
        
    0     0 MASQUERADE  0    --  *      enp1s0  10.8.0.0/24          0.0.0.0/0  
         
```

クライアント側のWireGuardも再起動

```
$ sudo systemctl restart wg-quick@wg0
```

最後にクライアント側から実行する`curl https://checkip.amazonaws.com`の示すグローバルIPアドレスがVPNサーバーのものになっていれば成功。`traceroute`でも確認できる。

```
$ traceroute 1.1.1.1
traceroute to 1.1.1.1 (1.1.1.1), 30 hops max, 60 byte packets
 1  10.8.0.1 (10.8.0.1)  19.193 ms  19.152 ms  19.141 ms
 2  192.168.0.1 (192.168.0.1)  19.133 ms  21.373 ms  21.365 ms
 3  * * *
 4  tmfACS002.bb.kddi.ne.jp (27.85.212.117)  23.431 ms tmfACS002.bb.kddi.ne.jp (27.86.127.213)  22.305 ms tmfACS002.bb.kddi.ne.jp (27.85.212.21)  23.417 ms
 5  106.139.194.89 (106.139.194.89)  23.410 ms 106.139.194.97 (106.139.194.97)  23.404 ms 27.86.47.221 (27.86.47.221)  23.398 ms
 6  27.85.230.58 (27.85.230.58)  23.392 ms 106.139.193.110 (106.139.193.110)  17.932 ms 27.85.137.86 (27.85.137.86)  17.870 ms
 7  210.171.224.134 (210.171.224.134)  17.926 ms * *
 8  103.22.201.87 (103.22.201.87)  17.796 ms 103.22.201.29 (103.22.201.29)  17.484 ms 103.22.201.87 (103.22.201.87)  17.480 ms
 9  one.one.one.one (1.1.1.1)  17.344 ms 103.22.201.21 (103.22.201.21)  17.320 ms one.one.one.one (1.1.1.1)  17.298 ms
```

PCから10.8.0.1に送られて、ついで自宅で契約しているau回線からインターネットに出ていることがわかる。

ところでどういう設定かわからずすこし気持ち悪いが、`0.0.0.0/0, ::/0`でもLANアクセスはVPNを通らない。実用的にはこれで助かるが……

```
$ ip route get 1.1.1.1
1.1.1.1 dev wg0 table 51820 src 10.8.0.4 uid 1000 
    cache 
$ ip route get 192.168.8.246
192.168.8.246 dev wlp0s20f3 src 192.168.8.69 uid 1000 
    cache 
```

### クライアント上のDockerの通信が異常に遅い

（PID 1がSIGINTを無視するため中断できなくなるので`--init`が必要）

```
$ docker run --rm -it --init ubuntu:24.04 bash -c "apt update >/dev/null 2>&1 && apt install --yes curl >/dev/null 2>&1 && curl -o /dev/null -L 'https://github.com/freerouting/freerouting/releases/download/v2.1.0/freerouting-2.1.0.jar'"
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:36 --:--:--     0^C
```

これは最大伝送単位（MTU：Maximum Transmission Unit）のミスマッチが原因。物理インターフェースの最大サイズは1500であり、Dockerのブリッジネットワークも1500で送出しようとする。しかしWireGuardでは暗号化のオーバーヘッドで60（IPv4）〜80（IPv6）バイトかかり、既定でMTU=1420になる。さらに、Docker→WireGuardの仮想ネットワーク経路ではICMP Packet Too Big（PTB）の伝達も行われず、Docker側は正しいMTUを理解できない。

ChatGPT曰く

> - 仮想L2（bridge, veth）と仮想L3（tunnel, wg）をまたいでMTU情報を伝播する仕組みはない
> - DockerのNAT実装がICMPエラーを透過的に返す設計になっていない

WireGuardクライアント側でDockerブリッジネットワークのMTUを明示することで問題を回避できる。

```
$ cat /etc/docker/daemon.json 
cat: /etc/docker/daemon.json: そのようなファイルやディレクトリはありません
$ echo '{"mtu":1420}' | sudo tee /etc/docker/daemon.json
{"mtu":1420}
$ sudo systemctl restart docker
$ docker network prune -f
$ docker run --rm -it --init ubuntu:24.04 bash -c "apt update >/dev/null 2>&1 && apt install --yes curl >/dev/null 2>&1 && curl -o /dev/null -L 'https://github.com/freerouting/freerouting/releases/download/v2.1.0/freerouting-2.1.0.jar'"
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 63.8M  100 63.8M    0     0  58.9M      0  0:00:01  0:00:01 --:--:--  105M
```

---

2026/1/25 [ThinkPad P52](../019bca2d-1360-74d5-b863-7cdf35f80d99/README.md)に役割を譲って引退。
