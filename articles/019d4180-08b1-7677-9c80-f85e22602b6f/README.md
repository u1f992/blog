## VMのDHCP割当結果を知りたい

ブリッジでホストと同じネットワークに参加しているゲストのIPアドレスを知りたい。ゲストはDHCPからIPアドレスを得ており、ゲストには特にゲストエージェントなどは入っていないものとする。

```shellsession
$ virsh -c qemu:///system list --all
$ virsh -c qemu:///system domiflist VM_NAME
$ for i in $(seq 1 254); do ping -c1 -W0.1 192.168.8.$i &>/dev/null & done; wait
$ ip neigh show dev br0 | grep VM_NIC_MAC
```

サブネット下の全アドレスにpingを飛ばすことで、IPアドレス→MACアドレスの対応表であるところのARPテーブルを更新して、MACでフィルタすればIPアドレスを得られる。

以下は失敗した他の方法のメモ

libvirtのDHCPリースから取得する。今回はVMがlibvirtのDHCPを通らずブリッジで直接参加しているため動作しない。`--source arp`とすることでlibvirtの管理するARPテーブルから得ることもできるが、今回のケースでは同じ結果。

```
virsh -c qemu:///system domifaddr VM_NAME
```

VM内のQEMUゲストエージェントから取得する方法。今回はインストールしておらず動作しない。またゲストエージェントが起動している必要がある点にも注意。

```
virsh domifaddr --source agent
```

nmapによるネットワークスキャン。Ubuntu Serverのデフォルト構成ではnmapは入っていない。

```
sudo nmap -sn 192.168.8.0/24
```
