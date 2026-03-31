## VMのDNS割当結果を知りたい

ブリッジでホストと同じネットワークに参加しているゲストのIPアドレスを知りたい。ゲストはDNSからIPアドレスを得ており、ゲストには特にゲストエージェントなどは入っていないものとする。

```shellsession
$ virsh -c qemu:///system list --all
$ virsh -c qemu:///system domiflist VM_NAME
$ for i in $(seq 1 254); do ping -c1 -W0.1 192.168.8.$i &>/dev/null & done; wait
$ ip neigh show dev br0 | grep VM_NIC_MAC
```

サブネット下の全アドレスにpingを飛ばすことで、IPアドレス→MACアドレスの対応表であるところのARPテーブルを更新して、MACでフィルタすればIPアドレスを得られる。
