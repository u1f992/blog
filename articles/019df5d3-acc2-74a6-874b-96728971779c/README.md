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
