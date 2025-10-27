## WireGuard内の端末からのすべてのWeb通信を、WireGuardサーバー経由にする

一般的なVPNの使い方といえばこちらか

既存設定（クライアント側）

```
$ sudo wg show
interface: wg0
  public key: ...
  private key: (hidden)
  listening port: ...

peer: ...
  endpoint: ...
  allowed ips: 10.8.0.0/24
  latest handshake: 1 minute, 50 seconds ago
  transfer: 408.61 KiB received, 864.52 KiB sent
  persistent keepalive: every 25 seconds
```

既存設定（WireGuardサーバー側）

```
$ sudo wg show
interface: wg0
  public key: ...
  private key: (hidden)
  listening port: ...

peer: ...
  endpoint: ...
  allowed ips: 10.8.0.4/32
  latest handshake: 16 seconds ago
  transfer: 46.84 MiB received, 1.26 MiB sent

...
```

クライアント側の新規設定

```
- AllowedIPs = 10.8.0.0/24
+ AllowedIPs = 0.0.0.0/0, ::/0
```

サーバー側の新規設定

- [IPフォワーディングの有効化](../0199d804-fa2f-7925-82e1-003224f2d920/README.md)
  - `/etc/sysctl.conf`と`/sys/ufw/sysctl.conf`がある。ufwのほうが後に起動して前者を上書きするはず。

サーバーからインターネットへ出るインターフェイスを調べる。ここでは`enp1s0`

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

最後にクライアント側から実行する`curl https://checkip.amazonaws.com`の示すグローバルIPアドレスがVPNサーバーのものになっていれば成功。

