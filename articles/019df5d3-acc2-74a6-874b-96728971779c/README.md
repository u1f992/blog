## Z390-A PROのBIOS更新

```shellsession
$ sudo dmidecode -s bios-version
1.80
$ sudo dmidecode -s bios-release-date
12/25/2019
```

- https://us.msi.com/Motherboard/Z390-A-PRO/support#bios

7B98v1F（2024-08-09）まで公開されている

- [追加したUSBデバイスを追跡する](../019ccfef-65ab-7879-92d3-ba2881b62a03/README.md)

```shellsession
$ sudo udevadm monitor --subsystem-match=block --udev

$ sudo umount /dev/sdf* 2>/dev/null

$ sudo parted /dev/sdf --script mklabel msdos
$ sudo parted /dev/sdf --script mkpart primary fat32 1MiB 100%

$ sudo mkfs.vfat -F 32 /dev/sdf1

$ sudo mkdir /mnt/sdf1
$ sudo mount /dev/sdf1 /mnt/sdf1
$ sudo unzip ~/Downloads/7B98v1F.zip -d /mnt/sdf1/
$ sudo umount /mnt/sdf1
$ sudo rmdir /mnt/sdf1
```

How_to_flash_the_BIOS.pdfに従って更新。

```shellsession
$ sudo dmidecode -s bios-version
1.F0
$ sudo dmidecode -s bios-release-date
07/10/2024
```

BIOSの設定が飛んで、WoLで起動しなくなっていることを確認した。

- [Z390-A PRO (MS-7B98)におけるWoL有効化](../articles/0199d851-4ce7-724f-a0c9-6df368692ac3/README.md)

> - https://support.ask-corp.jp/hc/ja/articles/360046270034-MSI%E8%A3%BD%E3%83%9E%E3%82%B6%E3%83%BC%E3%83%9C%E3%83%BC%E3%83%89%E3%81%A7%E3%81%AEWake-On-LAN-WOL-%E3%81%AE%E8%A8%AD%E5%AE%9A%E6%96%B9%E6%B3%95%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6
> 
> - `Settings\Advanced\Power Management Setup\ErP Ready`を`Disabled`に、
> - `Settings\Advanced\Wake Up Event Setup\Resume By PCI-E Device`と`Resume By Intel Onbord LAN/CNVi`を`Enabled`に

`Settings\Advanced\Power Management Setup\ErP Ready`は`Disabled`だったが、`Settings\Advanced\Wake Up Event Setup\Resume By PCI-E Device`と`Resume By Intel Onbord LAN/CNVi`は`Disabled`になっていた。修正してWoLで起動するようになったことを確認。
