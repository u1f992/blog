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
Address = 10.8.0.1/24
ListenPort = 51820
PrivateKey = (glm-mn3350_private.keyの中身)

[Peer]
PublicKey = (client_public.keyの中身)
AllowedIPs = 10.8.0.2/32
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
$ sudo ufw allow from 10.8.0.0/24 to any port 22
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
<figcaption>wireguard.conf</figcaption>

```
[Interface]
Address = 10.8.0.2/24
PrivateKey = (client_private.key の中身)

[Peer]
PublicKey = (glm-mn3350_public.key の中身)
Endpoint = (GLM-MN3350のグローバルIP):51820
AllowedIPs = 10.8.0.0/24
```

</figure>
