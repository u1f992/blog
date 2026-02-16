## Z390-A PRO (MS-7B98)におけるWoL有効化

- https://support.ask-corp.jp/hc/ja/articles/360046270034-MSI%E8%A3%BD%E3%83%9E%E3%82%B6%E3%83%BC%E3%83%9C%E3%83%BC%E3%83%89%E3%81%A7%E3%81%AEWake-On-LAN-WOL-%E3%81%AE%E8%A8%AD%E5%AE%9A%E6%96%B9%E6%B3%95%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6

- `Settings\Advanced\Power Management Setup\ErP Ready`を`Disabled`に、
- `Settings\Advanced\Wake Up Event Setup\Resume By PCI-E Device`と`Resume By Intel Onbord LAN/CNVi`を`Enabled`に

OS側の設定も必要。

```
$ ip link show  # 有線LANのインターフェースを探す
$ sudo ethtool eno1 | grep Wake-on
	Supports Wake-on: pumbg
	Wake-on: d  # disabled
$ nmcli connection show | grep eno1
netplan-eno1    10838d80-caeb-349e-ba73-08ed16d4d666  ethernet   eno1 
$ sudo nmcli connection modify "netplan-eno1" 802-3-ethernet.wake-on-lan magic
$ sudo nmcli connection up "netplan-eno1"
$ sudo ethtool eno1 | grep Wake-on
	Supports Wake-on: pumbg
	Wake-on: g
```

どの時点からか不明だがWoLで起動できなくなってしまった。NICのLEDはシャットダウン後も点灯しているから、通電はしている。

Windows VMをLANに接続するためにブリッジを構成したタイミングか？

```
$ nmcli connection show
NAME            UUID                                  TYPE       DEVICE  
br0             1e7c2819-85c0-4ab7-8c42-6f8824193805  bridge     br0     
br0-slave       cec74fdd-9635-466e-9fea-f273a73ced2c  ethernet   eno1    
lo              fcd773a0-ea24-44b0-a69b-6f1ce6f1b177  loopback   lo      
wg0             8d63beb9-0361-4c7d-9b68-80886eb9aada  wireguard  wg0     
docker0         d764a08b-05dd-493e-be39-70471b25a1af  bridge     docker0 
virbr0          75b9b5c5-c9d7-4739-899e-1e403a69cef8  bridge     virbr0  
aterm-82478d-g  b7af2bb2-4afd-47f5-8ff6-d2a9b6cd3174  wifi       --      
netplan-eno1    10838d80-caeb-349e-ba73-08ed16d4d666  ethernet   --  
$ nmcli connection show "br0-slave" | grep wake
802-3-ethernet.wake-on-lan:             default
802-3-ethernet.wake-on-lan-password:    --
$ sudo nmcli connection modify "br0-slave" 802-3-ethernet.wake-on-lan magic
$ sudo nmcli connection up "br0-slave"
$ nmcli connection show "br0-slave" | grep wake
802-3-ethernet.wake-on-lan:             magic
802-3-ethernet.wake-on-lan-password:    --
```

起動しない。数日前にカーネルを6.14→6.17に更新したので、6.14で起動してみる。次回起動時だけGRUBメニューを30秒間表示させる

```
$ sudo sed -i 's/GRUB_TIMEOUT_STYLE=hidden/GRUB_TIMEOUT_STYLE=menu/' /etc/default/grub
$ sudo sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=30/' /etc/default/grub
$ sudo update-grub
$ systemctl reboot
```

```
Advanced options for Ubuntu > Ubuntu, with Linux 6.14.0-37-generic

$ uname -r
6.14.0-37-generic
```

> 戻し方
> 
> ```
> $ sudo sed -i 's/GRUB_TIMEOUT_STYLE=menu/GRUB_TIMEOUT_STYLE=hidden/' /etc/default/grub
> $ sudo sed -i 's/GRUB_TIMEOUT=30/GRUB_TIMEOUT=0/' /etc/default/grub
> $ sudo update-grub
> ```

6.14に切り替えて起動した後シャットダウンしても起動しない。

BIOSの設定は正しい。

そもそもスターター（LAN内に置いているWireGuardサーバー）から見えているか？

```
こちらのPCで
$ sudo tcpdump -i eno1 'ether proto 0x0842 or udp port 9 or udp port 7' -vv

スターターから
$ wakeonlan 00:d8:61:ff:58:01
```

何も表示されない。

```
こちらのPCで
$ sudo tcpdump -i br0 'ether proto 0x0842 or udp port 9 or udp port 7' -vv

スターターから
$ wakeonlan 00:d8:61:ff:58:01
```

何も表示されない。

```
スターターで
mukai@thinkpad-p52:~$ sudo tcpdump -i enp0s31f6 'ether proto 0x0842 or udp port 9 or udp port 7' -vv &
[2] 6743
mukai@thinkpad-p52:~$ tcpdump: listening on enp0s31f6, link-type EN10MB (Ethernet), snapshot length 262144 bytes
wakeonlan 00:d8:61:ff:wakeonlan 00:d8:61:ff:58:01
Sending magic packet to 255.255.255.255:9 with 00:d8:61:ff:58:01
mukai@thinkpad-p52:~$ 13:53:28.235209 IP (tos 0x0, ttl 64, id 18991, offset 0, flags [DF], proto UDP (17), length 130)
    thinkpad-p52.51664 > 255.255.255.255.discard: [bad udp cksum 0xc12d -> 0xc6fe!] UDP, length 102
wakeonlan 00:d8:61:ff:58:01
Sending magic packet to 255.255.255.255:9 with 00:d8:61:ff:58:01
mukai@thinkpad-p52:~$ 13:53:31.472039 IP (tos 0x0, ttl 64, id 19644, offset 0, flags [DF], proto UDP (17), length 130)
    thinkpad-p52.46190 > 255.255.255.255.discard: [bad udp cksum 0xc12d -> 0xdc60!] UDP, length 102
^C
```

確かに出ているが、こちらでは受信できていない。

スターターからサブネットブロードキャストで送る

```
こちらのPCで
$ sudo tcpdump -i br0 'ether proto 0x0842 or udp port 9 or udp port 7' -vv

スターターで
$ wakeonlan -i 192.168.0.255 00:d8:61:ff:58:01

こちらのPCが反応した
$ sudo tcpdump -i br0 'ether proto 0x0842 or udp port 9 or udp port 7' -vv
tcpdump: listening on br0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
22:55:15.678128 IP (tos 0x0, ttl 64, id 22640, offset 0, flags [DF], proto UDP (17), length 130)
    192.168.0.6.39568 > 192.168.0.255.discard: [udp sum ok] UDP, length 102
```

WoLスクリプトを修正してこちら（"br0-slave" 802-3-ethernet.wake-on-lan magic／6.14で起動中）をシャットダウン。再度WoLを実行

起動した！（GRUBで6.14選択）255.255.255.255宛のブロードキャストがルーターを通過せず、マジックパケットが届いていなかった。

上の「戻し方」でGRUBメニューを無効化して再起動

```
$ uname -r
6.17.0-14-generic
```

br0-slaveの設定も戻す

```
$ sudo nmcli connection modify "br0-slave" 802-3-ethernet.wake-on-lan default
$ sudo nmcli connection up "br0-slave"
$ systemctl poweroff
```

ここからWoLで起動することを確認した。

なぜブロードキャスト転送が失敗するようになっていたのだろう。ファームウェア遠隔更新の影響を受けたのだろうか……？
