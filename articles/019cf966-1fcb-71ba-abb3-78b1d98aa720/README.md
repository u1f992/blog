## リモートのリソースでKVMを動作させる

サーバー（Ubuntu Server 24.04）に必要なのはlibvirtdと管理用のCLIとしてlibvirt-clients（virsh）。共有ドライブを使用するならvirtiofsdが必要。サーバー側ですでにSSHは有効化されており、SSHクライアント側でvirshなりvirt-managerなりで操作する前提。サーバー側ではブリッジを構成しておけば、VMに直接接続できるようになる。

<figure>
<figcaption>サーバー側</figcaption>

```shellsession
$ sudo apt install qemu-kvm libvirt-daemon-system virtiofsd
$ sudo usermod -aG libvirt $(whoami)
```

- -a (append)：ユーザーを既存のグループに追加する。これがないと、指定したグループ以外のすべての補助グループから外されてしまう。
- -G (groups)：補助グループを指定する。

なおlibvirtグループはインストール時に作成されているはず。グループはログインし直すまで反映されないので再起動。

</figure>

クライアント側でvirshだけ使えるようにしたければlibvirt-clientsをインストールする。

virt-managerでは［ファイル(F)＞接続を追加(A)...］から追加できる。

virt-managerで新規作成する際のISOメディアのデフォルトパスは`/var/lib/libvirt/images/`

### VMインストール時にDHCPが失敗する場合

Ubuntu Serverのインストーラー（subiquity）はsystemd-networkdでネットワークを管理するが、DHCPv4のClient-IDとしてSMBIOS UUIDベースのDUID（hardware-type 255）を送信する。一部のDHCPサーバーはこの形式を処理できず応答しない。

tcpdumpで確認すると、正常な端末のClient-IDが`ether xx:xx:xx:xx:xx:xx`（7バイト）であるのに対し、VMは`hardware-type 255`の19バイトのDUIDを送信していることがわかる。

```shellsession
$ # ホスト側でDHCPトラフィックを監視
$ sudo tcpdump -i enp3s0 -vvv port 67 or port 68
```

インストーラー環境ではnetplanの設定変更（`dhcp-identifier: mac`）は反映されない。インストーラーが独自にsystemd-networkdを管理しており？、`/run/systemd/network/`も空の状態である。直接systemd-networkdの設定を作成する必要がある。

<figure>
<figcaption>VM側（インストーラーのシェル）</figcaption>

```shellsession
$ cat > /run/systemd/network/10-dhcp.network << 'EOF'
[Match]
Name=enp1s0

[Network]
DHCP=yes

[DHCPv4]
ClientIdentifier=mac
EOF
$ systemctl restart systemd-networkd
```

</figure>

これによりClient-IDがMACアドレスベースに変わり、DHCPサーバーから応答を得られるようになる。インストール完了後の環境ではnetplanで`dhcp-identifier: mac`を指定すればよい（[過去のセットアップ](../0199d804-fa2f-7925-82e1-003224f2d920/README.md)）。

