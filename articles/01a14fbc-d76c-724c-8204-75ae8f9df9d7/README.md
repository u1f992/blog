## マザーボード変更後のネットワーク復旧

MSI Z390-A PROからMSI B760 GAMING PLUS WIFI DDR4へ交換したあとに起きたネットワークの問題の記録。OSはUbuntu 24.04.5、ネットワークの管理はnetplan経由のNetworkManager 1.46.0。

### 起動時にイーサネットが上がらない

#### 症状

- 起動しても有線LANにアドレスが付かない。ログイン後にNetworkManagerの接続「netplan-eno1」を手動で有効化すると使える
- ブリッジbr0は「接続中（IP設定を取得中）」のまま上がらず、br0に接続するVMはネットワークを持てない
- NetworkManager-wait-online.serviceが60秒でタイムアウトして失敗し、network-online.targetを待つdocker.serviceとwg-quick@wg0.serviceの起動が約60秒遅れる

#### 原因

交換でNICが変わり、インタフェース名もMACアドレスも変わった。

| 項目 | Z390-A PRO | B760 GAMING PLUS WIFI DDR4 |
| --- | --- | --- |
| NIC | Intel I219-V（e1000e、PCI 00:1f.6） | Realtek RTL8125（r8169、PCI 08:00.0） |
| インタフェース名 | eno1（ファームウェアのオンボード番号による命名） | enp8s0（PCIバスのパスによる命名） |

NetworkManagerの接続プロファイルは次の3つで、有線LANはブリッジbr0の下に置く構成になっている。br0はlibvirtのVMが接続先に使っている。

| プロファイル | 種別 | 自動接続 | インタフェース指定 | 役割 |
| --- | --- | --- | --- | --- |
| br0 | bridge | あり | br0 | DHCPでアドレスを受ける。VMの接続先 |
| br0-slave | ethernet | あり | eno1 | br0のポート |
| netplan-eno1 | ethernet | なし | なし | netplanの定義eno1から生成された単独DHCP接続。br0を作った時点で自動接続を切ったまま残っている |

交換前は、eno1のリンクアップでbr0-slaveが自動接続してeno1がbr0のポートになり、br0がDHCPでアドレスを受けていた。交換後は、br0は自動接続してDHCPを待つが、br0-slaveの対象であるeno1が存在しないためポートが付かず、キャリアのないままDHCPが完了しない。enp8s0はリンクアップ後に「disconnected」になるが、自動接続の対象になるプロファイルがないのでそこで止まる。NetworkManagerはbr0の接続中状態が続くため「接続中」のままになり、wait-onlineが60秒で失敗する。

交換前の最後の起動のログ。10秒でポートが付き、40秒でアドレスを受けている。

```
[    9.966867] NetworkManager: device (eno1): carrier: link connected
[    9.967341] NetworkManager: policy: auto-activating connection 'br0-slave'
[    9.968903] NetworkManager: device (br0): attached bridge port eno1
[   40.384228] NetworkManager: dhcp4 (br0): state changed new lease, address=...
```

交換後の起動のログ。9秒でenp8s0がリンクアップしたあと何も起きず、33秒にユーザー（uid=1000）が手動で接続し、66秒にwait-onlineが失敗している。

```
[    6.014070] NetworkManager: policy: auto-activating connection 'br0'
[    9.128877] NetworkManager: device (enp8s0): carrier: link connected
[    9.129350] NetworkManager: device (enp8s0): state change: unavailable -> disconnected (reason 'carrier-changed')
[   33.535185] NetworkManager: device (enp8s0): Activation: starting connection 'netplan-eno1'
[   33.535328] NetworkManager: audit: op="connection-activate" name="netplan-eno1" pid=3104 uid=1000 result="success"
[   34.222305] NetworkManager: dhcp4 (enp8s0): state changed new lease, address=...
[   66.060661] systemd: NetworkManager-wait-online.service: Main process exited, code=exited, status=1/FAILURE
```

`systemd-analyze critical-chain network-online.target`でも、network-online.targetが1分2秒に到達している。

#### 対処

br0はVMが使うので残し、br0-slaveの対象をenp8s0に変える。

```
nmcli connection modify br0-slave connection.interface-name enp8s0
nmcli connection up br0-slave
```

`up`でenp8s0はnetplan-eno1からbr0-slaveに切り替わる。以後の起動では、enp8s0のリンクアップでbr0-slaveが自動接続し、br0がアドレスを受ける。

あわせて次の2点を直す。

- br0はSTP（Spanning Tree Protocol、IEEE 802.1D）が有効になっている。STPはブリッジ同士が経路情報を交換し、同じネットワークへの経路が2本以上あるときに余分な経路のポートを遮断して、ブロードキャストが無限に循環するのを防ぐ仕組みである。新しくつながったポートは、ループの有無が判明するまで転送を止める。この待ちがforward delayで、listening・learningの2段階にそれぞれ15秒かかるため、ポートが付いてから30秒間はブリッジを通る通信がない。交換前のログで、ポート接続の10秒からアドレス取得の40秒まで空いているのがこの待ち時間

  ループはブリッジが同じネットワークへ2本以上の経路を持つときにだけ起きる。br0の物理ポートはenp8s0の1本で、残りのポートはVMにつながる仮想インタフェースであり、VMがLANへ出る経路はこのbr0だけなので、br0を経由する経路は1本しかなくループは作れない。LAN側のスイッチ同士のループ防止はスイッチ自身のSTPの役目で、本機のブリッジがSTPを止めても影響しない。無効にすると、ポートは接続と同時に転送を始める。同じ理由で、libvirt自身のvirbr0はforward delayをカーネルの下限の2秒にしており、docker0はSTPを無効にしている

  ```
  nmcli connection modify br0 bridge.stp no
  ```

  br0に2本目の物理NICや無線をポートとして足すと経路が2本になるので、その構成ではSTPを有効に戻す

- netplan-eno1は、名前こそ旧インタフェース名だがデバイスの指定を持たず、どのEthernetデバイスでも有効化できる。交換後の手動接続に使えたのはそのためで、br0-slaveの切り替え後は役割がない。netplanがこの定義から生成する`/run/systemd/network/10-netplan-eno1.link`は[Match]が空で、systemd-udevdが起動ごとに警告を出している。削除する

  ```
  nmcli connection delete netplan-eno1
  ```

#### 確認

再起動後に次を実行し、enp8s0の接続がbr0-slave、br0が接続済みで、wait-onlineがactive (exited)になっていればよい。

```
nmcli -f DEVICE,STATE,CONNECTION device status
systemctl status NetworkManager-wait-online.service
ip link show br0
```

ルータのDHCPは本機のアドレスをenp8s0のMACアドレスに固定割り当てしている。アドレスを受けるのはbr0になるので、`ip link show br0`でbr0のMACアドレスがポートのenp8s0と同じになっていることを確認する。異なっていればbr0側で指定する。

```
nmcli connection modify br0 802-3-ethernet.cloned-mac-address <enp8s0のMACアドレス>
nmcli connection up br0
```

### VPN内から10.8.0.2に到達できない

#### 症状

本機はWireGuardのwg0に10.8.0.2を持ち、VPN内の他のピアから10.8.0.2へSSH接続できていた。交換後は到達できない。wg0自体はwg-quick@wg0.serviceで起動し、アドレスも付いている。

#### 確認できたこと

- 本機のLANアドレスは、交換後の初回起動では交換前と同じ値をDHCPで受けた。その後ルータのDHCPで新しいMACアドレスに別のアドレスを固定割り当てした
- WireGuardのサーバーはLAN内にある。今回の起動の57秒と62秒に、サーバーは本機の以前のアドレスと以前のポート宛にハンドシェイク開始パケットを、本機のMACアドレスへ送ってきた。サーバーのARPキャッシュに以前のアドレスと本機のMACアドレスの対応が残っていたためで、本機はIPフォワーディングが有効なので転送を試み、UFWのFORWARDで破棄された

  ```
  [   57.127849] kernel: [UFW BLOCK] IN=enp8s0 OUT=enp8s0 SRC=<サーバー> DST=<本機の以前のアドレス> LEN=176 PROTO=UDP SPT=51820 DPT=<本機の以前のポート> LEN=156
  ```

- 本機のwg0は起動後約20分で送信260パケット（1パケット148バイトで、ハンドシェイク開始パケットの長さ）、受信0パケット。`wg show wg0`でもreceivedが0 Bのまま。本機からのハンドシェイクにサーバーが応答していない
- 本機のwg0.confはEndpointがLAN内のサーバー、PersistentKeepalive 25秒で、ListenPortの指定はない。UFWはwg0上のSSHとRDPを許可しており、インタフェース名eno1を指定するルールはない

#### 原因

交換後の初回起動で、システムクロックが約8時間進んでいた。新しいマザーボードのRTCにはUTCより8時間進んだ時刻（UTC+8の台湾時間と一致する）が入っていた。OSはRTCをUTCとして読む設定（`timedatectl`でRTC in local TZ: no）なので、起動直後のシステムクロックは実時刻の約8時間先になり、systemd-timesyncdが同期してクロックを戻すまでに、wg0が起動してサーバーとハンドシェイクを済ませている。

| 初回起動の出来事 | 起動からの経過 | システムクロック |
| --- | --- | --- |
| カーネル起動、RTCを読む | 0秒 | 実時刻の約8時間先 |
| wg0起動、ハンドシェイク | 約1分 | 実時刻の約8時間先 |
| timesyncdが同期する | 約4分 | 実時刻に戻る |

WireGuardのハンドシェイク開始パケットには送信側の時刻（TAI64N）が入り、受け手は同じピアからそれまでに受けた最大の時刻以下のものをリプレイとして黙って捨てる。サーバーは本機から約8時間先の時刻を受け取って記録したので、クロックが戻ったあとの本機のハンドシェイクはすべてこの値より小さく、捨てられる。本機側に残るのは送信カウンタだけで、受信は0のまま。

サーバーから本機へのハンドシェイクは、サーバーが最後に確認した本機のエンドポイントに送られる。本機はListenPortを指定していないためポートが起動ごとに変わり、サーバーが持つエンドポイントは初回起動時のアドレスとポートなので、再起動後は届かない。

このため、初回起動のセッションが切れた2回目の起動以降、どちらの方向からもセッションが張れていない。

#### 対処

サーバー側で本機のピアを削除して再登録し、記録している時刻を消す。本機からの次のハンドシェイクが受理され、サーバーが持つ本機のエンドポイントも現在のアドレスとポートに更新される。

#### 確認

```
sudo wg show wg0
```

latest handshakeが表示され、transferのreceivedが増えていればセッションが張れている。

サーバー側でピアを削除して再登録した直後に、それまで0だったwg0の受信パケットが増え始め、10.8.0.1へのpingが往復約1.2 msで通った。VPN内の他の機器から10.8.0.2への接続も回復した。
