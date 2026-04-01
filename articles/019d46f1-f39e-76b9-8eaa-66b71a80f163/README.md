## USBイーサネットアダプタを取り外した後Wi-Fiに接続できない

USBイーサネットアダプタでブリッジbr0を構成していたPCで、USBイーサネットアダプタを取り外し後、Wi-Fiを有効化すると、APは見つけられているのにインターネットに接続できなかった。

原因1：br0のデフォルトルートがWi-Fiより優先されていた。NMがbr0の接続プロファイルを維持し続け、br0にDHCPリース（192.168.8.38/24）とデフォルトルート（metric 425）が残っていた。WiFiのデフォルトルート（metric 600）より小さい＝優先度が高いため、すべてのトラフィックがリンクダウンしたbr0に吸い込まれていた。

原因2：br0とWi-Fiが同一サブネットに存在した。上に気づいてアドレスを消した（`sudo ip addr flush dev br0`）が、インターフェイス自体が残っていたためルーティングが曖昧になり接続できなかった。

恒久対策としてbr0の自動接続を無効化。

```shellsession
$ nmcli connection modify br0 connection.autoconnect no
```

USBイーサネットアダプタ取り外し時には手動で削除。USBイーサネットアダプタの抜き差しに反応させることもできるが、そこまでは行っていない。

削除してからWi-Fiを有効化

```shellsession
$ sudo ip link delete br0
```

USBイーサネットを再接続した後にbr0をup。少し時間がかかるようだ。

```shellsession
$ nmcli connection up br0
```
