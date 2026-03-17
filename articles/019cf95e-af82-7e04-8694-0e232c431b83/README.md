## Ubuntuのネットワーク設定

### ネットワーク設定の分業体制

Ubuntuでは、ネットワーク設定は「フロントエンド＝記述層」と「バックエンド＝レンダラ」に分業されている。Ubuntu（24.04、Server/Desktop）で共通して記述層を担うのがNetplanである。Netplan自体はネットワークデーモンではなく、`netplan apply`（内部的には`netplan generate`＋バックエンド再起動）を実行するとYAMLをレンダラが読める設定ファイルに変換して終了するジェネレータである[^1][^2]。

設定ファイルの格納場所は`/etc/netplan/`で、ファイルは辞書順（lexical order）に処理され、番号が大きいほど優先される[^3]。

### Server版

Server版のレンダラはsystemd-networkdである[^4]。Netplanは`/etc/netplan/`に記述された設定の翻訳結果を`netplan apply`によって`/run/systemd/network/`に書き出し、systemd-networkdはこれを読んで動作する。`/run/systemd/network/`はtmpfs上にあり、毎回YAMLから再生成される[^2]。

典型的な構成で初期構築した直後には、`/etc/netplan/50-cloud-init.yaml`が存在する。

```yaml
network:
  version: 2
  ethernets:
    enp3s0:
      addresses:
      - "192.168.8.222/24"
      nameservers:
        addresses:
        - 1.1.1.1
        search: []
      routes:
      - to: "default"
        via: "192.168.8.1"
```

例としてこのマシンでブリッジを構築するには、次のようにYAMLを直接編集すればよい[^5]。

```yaml
network:
  version: 2
  ethernets:
    enp3s0:
      dhcp4: false
      dhcp6: false
  bridges:
    br0:
      interfaces:
      - enp3s0
      addresses:
      - "192.168.8.222/24"
      nameservers:
        addresses:
        - 1.1.1.1
        search: []
      routes:
      - to: "default"
        via: "192.168.8.1"
```

```shellsession
$ sudo netplan apply
```

### Desktop版

Desktop版のレンダラはNetworkManagerである[^4]が、Ubuntu固有の事情として、NetworkManagerは単なるレンダラではなくフロントエンドを内包している（Ubuntu 23.10以降）[^6][^7]。

ユーザーはNetworkManagerのCLIであるnmcliやGUIで設定を変更し、その結果は`/etc/netplan/90-NM-<UUID>.yaml`として出力される。

```
/etc/netplan/
├── 01-network-manager-all.yaml              # NMをレンダラに指定
├── 90-NM-3e609b5b-ec4a-432a-9d00-....yaml   # NMがlibnetplan経由で生成
├── 90-NM-496e6fd4-8e18-47ca-bd53-....yaml
└── ...
```

そのうえでNetworkManagerは内部的に`netplan generate`相当を実行し、Netplanはエフェメラルな`/run/NetworkManager/system-connections/netplan-<id>.nmconnection`を生成する。このファイルをNetworkManagerが読んで動作する。整理すると、Desktop版にNetplanは不要であり、技術的にはNMは単独でネットワークを管理できるように見える。Canonicalが23.10以降Desktop版にもNetplanを統合した主な理由は、Desktop／Server／Cloud／IoT全てのUbuntu派生で「`/etc/netplan/`を見ればネットワーク設定がわかる」という運用上の統一を実現するためであったと説明されている[^6]。

Desktop版で先の例と同様にブリッジを構成するには、nmcliを使用して行うのが正しい手続きである[^8][^9]。まず既存の接続設定を確認する。

```shellsession
$ # 接続の一覧を表示
$ nmcli connection show

$ # 特定の接続の詳細を表示（IPアドレス、ゲートウェイ、DNS等）
$ nmcli connection show enp3s0
```

```shellsession
$ # ブリッジインターフェースを作成
$ sudo nmcli connection add type bridge ifname br0 con-name bridge-br0

$ # 物理NICをブリッジのスレーブに追加
$ sudo nmcli connection add type ethernet ifname enp3s0 master br0 con-name bridge-slave-enp3s0

$ # IPアドレスを設定
$ sudo nmcli connection modify bridge-br0 ipv4.method manual
$ sudo nmcli connection modify bridge-br0 ipv4.addresses 192.168.8.222/24
$ sudo nmcli connection modify bridge-br0 ipv4.gateway 192.168.8.1
$ sudo nmcli connection modify bridge-br0 ipv4.dns "1.1.1.1"
$ # DHCPの場合は以下だけでよい
$ # sudo nmcli connection modify bridge-br0 ipv4.method auto

$ # 既存の接続を無効化し、ブリッジを有効化
$ sudo nmcli connection down enp3s0
$ sudo nmcli connection up bridge-br0
```

### 参考

[^1]: [About Netplan - Ubuntu Server documentation](https://ubuntu.com/server/docs/explanation/networking/about-netplan/)
[^2]: [A declarative approach to Linux networking with Netplan | Ubuntu](https://ubuntu.com/blog/a-declarative-approach-to-linux-networking-with-netplan)
[^3]: [YAML configuration - Netplan documentation](https://netplan.readthedocs.io/en/stable/netplan-yaml/)
[^4]: [Configuring networks - Ubuntu Server documentation](https://documentation.ubuntu.com/server/explanation/networking/configuring-networks/)
[^5]: [How to configure a VM host with a single network interface - Netplan documentation](https://netplan.readthedocs.io/en/stable/single-nic-vm-host/)
[^6]: [Netplan brings consistent network configuration across Desktop, Server, Cloud and IoT | Ubuntu](https://ubuntu.com/blog/netplan-configuration-across-desktop-server-cloud-and-iot)
[^7]: [How to integrate Netplan with desktop - Netplan documentation](https://netplan.readthedocs.io/en/stable/netplan-everywhere/)
[^8]: [Setting up a bridge network on Ubuntu 24.04 Desktop - Support and Help - Ubuntu Community Hub](https://discourse.ubuntu.com/t/setting-up-a-bridge-network-on-ubuntu-24-04-desktop/51734)
[^9]: [NetworkConnectionBridge - Community Help Wiki](https://help.ubuntu.com/community/NetworkConnectionBridge)
