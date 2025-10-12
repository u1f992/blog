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
