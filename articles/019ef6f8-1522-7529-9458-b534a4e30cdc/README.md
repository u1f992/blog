## AIエージェントに全部使わせるVM　virshによるVMの管理

- https://www.debian.org/distrib/ - a local QEMU virtual machine, in qcow2 or raw formats.

まずゴールデンディスクを適当な保管先へダウンロード。初期状態では3GBに設定されている。

```shellsession
$ mkdir ~/Documents/debian-13
$ cd ~/Documents/debian-13
$ curl --location --remote-name https://cloud.debian.org/images/cloud/trixie/latest/debian-13-nocloud-amd64.qcow2
$ qemu-img info debian-13-nocloud-amd64.qcow2
image: debian-13-nocloud-amd64.qcow2
file format: qcow2
virtual size: 3 GiB (3221225472 bytes)
disk size: 390 MiB
cluster_size: 65536
Format specific information:
    compat: 1.1
    compression type: zlib
    lazy refcounts: false
    refcount bits: 16
    corrupt: false
    extended l2: false
Child node '/file':
    filename: debian-13-nocloud-amd64.qcow2
    protocol type: file
    file length: 390 MiB (408813568 bytes)
    disk size: 390 MiB
```

これをバッキングファイルにして必要なサイズのオーバーレイを作成する。仮想サイズはオーバーレイ作成時の末尾引数で指定するので、ベース側を`resize`する必要はない。`-f`は作成するオーバーレイのフォーマット、`-b`はバッキングファイル、`-F`でそのバッキングファイルのフォーマットを指定する。バッキングファイルパスはオーバーレイに焼き込まれ、相対パスはオーバーレイのパスから解決されるため、ファイル移動に注意。

```shellsession
$ qemu-img create -f qcow2 -b debian-13-nocloud-amd64.qcow2 -F qcow2 debian-13-overlay.qcow2 64G
Formatting 'debian-13-overlay.qcow2', fmt=qcow2 cluster_size=65536 extended_l2=off compression_type=zlib size=68719476736 backing_file=debian-13-nocloud-amd64.qcow2 backing_fmt=qcow2 lazy_refcounts=off refcount_bits=16
$ qemu-img info debian-13-overlay.qcow2 | grep --extended-regexp "virtual size|backing file"
virtual size: 64 GiB (68719476736 bytes)
backing file: debian-13-nocloud-amd64.qcow2
backing file format: qcow2
```

libvirt-qemuユーザーに、対象のオーバーレイまでのトラバース権限（`x`）があることを確認する。なければ`sudo setfacl -m u:libvirt-qemu:x /path/to`で付与。

```shellsession
$ getfacl /
getfacl: 絶対パス名から先頭の '/' を削除

# file: .
# owner: root
# group: root
user::rwx
group::r-x
other::r-x  <-- otherにあるのでlibvirt-qemuも通れる

$ getfacl /home
getfacl: 絶対パス名から先頭の '/' を削除

# file: home
# owner: root
# group: root
user::rwx
group::r-x
other::r-x

$ getfacl /home/mukai
getfacl: 絶対パス名から先頭の '/' を削除

# file: home/mukai
# owner: mukai
# group: mukai
user::rwx
user:libvirt-qemu:--x  <-- すでにあった。以前設定したのだろう
group::r-x
mask::r-x
other::---

$ getfacl /home/mukai/Documents/
getfacl: 絶対パス名から先頭の '/' を削除

# file: home/mukai/Documents/
# owner: mukai
# group: mukai
user::rwx
user:libvirt-qemu:--x
group::r-x
mask::r-x
other::r-x

$ getfacl /home/mukai/Documents/debian-13
getfacl: 絶対パス名から先頭の '/' を削除

# file: home/mukai/Documents/debian-13
# owner: mukai
# group: mukai
user::rwx
group::rwx
other::r-x
```

なおディスク自体へのrwは、dynamic_ownership = 1であれば不要。通常はデフォルト値がコメントアウトされている。

```shellsession
$ sudo grep -nE '^\s*#?\s*dynamic_ownership' /etc/libvirt/qemu.conf
539:#dynamic_ownership = 1
```

`--os-variant`に適合する値の一覧は次で調べられる。

```shellsession
$ virt-install --osinfo list | grep debian
debian13, debiantrixie
...
```

CPU 8／RAM 16GB／ブリッジネットワーク参加でVMを追加。ユーザーが`libvirt`グループに入っていれば`sudo`なしで実行可能。`--video vga`がないとGRUBと再起動がループした。`--noreboot`がないと定義と同時にVMが起動する。`--noautoconsole`は自動接続の抑制。あとからコンソールにアタッチするとそれ以前のメッセージは表示されないので、起動と同時にアタッチしたい。

```shellsession
$ virt-install \
    --name debian-13 \
    --memory 16384 \
    --vcpus 8 \
    --cpu host-passthrough \
    --os-variant debian13 \
    --import \
    --disk path=/home/mukai/Documents/debian-13/debian-13-overlay.qcow2,format=qcow2,bus=virtio \
    --network bridge=br0,model=virtio \
    --video vga \
    --graphics none \
    --console pty,target_type=serial \
    --noreboot \
    --noautoconsole
```

```shellsession
$ virsh list --all          # VM一覧
$ virsh domstate debian-13  # 起動状態
$ virsh dominfo debian-13   # VMの情報

$ virsh start --console debian-13  # 起動と同時にシリアルコンソールにアタッチ（終了はCtrl + ]…と表示されるが実際には何故かCtrl + [だった）

$ virsh console debian-13   # シリアルコンソールに接続

$ virsh shutdown debian-13  # 通常シャットダウン
$ virsh destroy debian-13   # 強制停止

$ virsh undefine debian-13  # VMを削除
```

GRUBではキーボード操作が無効化されているが、5秒？待つと起動する。

起動後`-- Press any key to proceed --`で待ってくれるのだが、そのあとにログが流れて分かりづらかったことがあった。

TZ Asiz/Tokyoは299、UTCは485

rootパスワードを空にするとログインできないので、なんらか設定する。

ディスクを拡張

```
mukai@localhost:~/red-001-housing-shell$ lsblk                                                                                                                                                      
NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS                                                                                                                                                        
vda     254:0    0   64G  0 disk                                                                                                                                                                    
├─vda1  254:1    0  2.9G  0 part /                                                                                                                                                                  
├─vda14 254:14   0    3M  0 part                                                                                                                                                                    
└─vda15 254:15   0  124M  0 part /boot/efi  

  $ sudo apt update && sudo apt install -y cloud-guest-utils   # growpart
  $ sudo growpart /dev/vda 1        # vda1 を空き領域いっぱいに
  $ sudo resize2fs /dev/vda1        # ext4 をオンライン拡張
  $ df -h /                         # 60G超になれば完了
```

ユーザーの作成：

```shellsession
$ sudo adduser mukai
$ sudo usermod --append --groups sudo mukai
$ sudo visudo --file=/etc/sudoers.d/mukai
```

`mukai ALL=(ALL:ALL) NOPASSWD: ALL`

`sudo --reset-timestamp && sudo -n true && echo OK`で確認

一部のDHCPサーバーはMAC（`hardware-type 1`）ではなくDUID（`hardware-type 255`）で名乗るリクエストに応答しない。

```shellsession
$ sudo tcpdump -ni br0 -v -e '(port 67 or port 68) and ether host 52:54:00:e9:f1:2b'
tcpdump: listening on br0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
11:10:33.219693 52:54:00:e9:f1:2b > ff:ff:ff:ff:ff:ff, ethertype IPv4 (0x0800), length 328: (tos 0xc0, ttl 64, id 0, offset 0, flags [none], proto UDP (17), length 314)
    0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from 52:54:00:e9:f1:2b, length 286, xid 0xda14039a, secs 1023, Flags [none]
          Client-Ethernet-Address 52:54:00:e9:f1:2b
          Vendor-rfc1048 Extensions
            Magic Cookie 0x63825363
            DHCP-Message (53), length 1: Discover
            Client-ID (61), length 19: hardware-type 255, 56:50:4d:98:00:02:00:00:ab:11:a3:7f:df:e6:c3:13:ec:df
            Parameter-Request (55), length 13: 
              Subnet-Mask (1), Default-Gateway (3), Domain-Name-Server (6), Hostname (12)
              Domain-Name (15), MTU (26), Static-Route (33), NTP (42)
              URL (114), Unknown (119), Unknown (120), Classless-Static-Route (121)
              Unknown (162)
            MSZ (57), length 2: 1472
            SLP-NA (80), length 0""
^C
1 packet captured
3 packets received by filter
0 packets dropped by kernel
```

Netplanが制御していることがわかる。

```shellsession
root@localhost:~# networkctl status
● Interfaces: 1, 2
       State: degraded                         
Online state: online                           
     Address: fe80::5054:ff:fee9:f12b on enp1s0

Jun 24 01:53:29 localhost systemd[1]: Starting systemd-networkd.service - Network Configuration...
Jun 24 01:53:29 localhost systemd-networkd[454]: lo: Link UP
Jun 24 01:53:29 localhost systemd-networkd[454]: lo: Gained carrier
Jun 24 01:53:29 localhost systemd[1]: Started systemd-networkd.service - Network Configuration.
Jun 24 01:53:29 localhost systemd-networkd[454]: enp1s0: Configuring with /run/systemd/network/10-netplan-all-en.network.
Jun 24 01:53:29 localhost systemd-networkd[454]: enp1s0: Link UP
Jun 24 01:53:29 localhost systemd-networkd[454]: enp1s0: Gained carrier
Jun 24 01:53:30 localhost systemd-networkd[454]: enp1s0: Gained IPv6LL
root@localhost:~# cat /etc/netplan/90-default.yaml 
network:
    version: 2
    ethernets:
        all-en:
            match:
                name: en*
            dhcp4: true
            dhcp4-overrides:
                use-domains: true
            dhcp6: true
            dhcp6-overrides:
                use-domains: true
        all-eth:
            match:
                name: eth*
            dhcp4: true
            dhcp4-overrides:
                use-domains: true
            dhcp6: true
            dhcp6-overrides:
                use-domains: true
root@localhost:~# vim /etc/netplan/90-default.yaml
root@localhost:~# cat /etc/netplan/90-default.yaml 
network:
    version: 2
    ethernets:
        all-en:
            match:
                name: en*
            dhcp-identifier: mac
            dhcp4: true
            dhcp4-overrides:
                use-domains: true
            dhcp6: true
            dhcp6-overrides:
                use-domains: true
        all-eth:
            match:
                name: eth*
            dhcp4: true
            dhcp4-overrides:
                use-domains: true
            dhcp6: true
            dhcp6-overrides:
                use-domains: true

# sudo netplan apply
# networkctl status enp1s0     # routable になり
# ip -4 addr show enp1s0       # 192.168.8.x が付けば解決
```

手っ取り早くファイルを転送したい。

ホスト側で

```
$ ip -br addr
...
br0              UP             192.168.8.53/24  fe80::f4be:6da:ae9c:1828/64
...

$ sudo ufw allow from 192.168.8.0/24 to any port 8000 proto tcp
$ python3 -m http.server 8000

$ sudo ufw delete allow from 192.168.8.0/24 to any port 8000 proto tcp
```

ゲストで

```
# curl -O http://192.168.8.53:8000/FILE
```
