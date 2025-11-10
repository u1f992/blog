## ハードディスクのバックアップとマウント

```
$ sudo lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0         7:0    0  73.9M  1 loop /snap/core22/2139
loop1         7:1    0     4K  1 loop /snap/bare/5
loop2         7:2    0  73.9M  1 loop /snap/core22/2133
loop3         7:3    0 249.2M  1 loop /snap/firefox/7084
loop4         7:4    0 249.1M  1 loop /snap/firefox/7177
loop5         7:5    0  11.1M  1 loop /snap/firmware-updater/167
loop6         7:6    0   516M  1 loop /snap/gnome-42-2204/202
loop7         7:7    0  18.5M  1 loop /snap/firmware-updater/210
loop8         7:8    0 516.2M  1 loop /snap/gnome-42-2204/226
loop9         7:9    0  10.8M  1 loop /snap/snap-store/1270
loop10        7:10   0  91.7M  1 loop /snap/gtk-common-themes/1535
loop11        7:11   0  50.8M  1 loop /snap/snapd/25202
loop12        7:12   0  50.9M  1 loop /snap/snapd/25577
loop13        7:13   0   576K  1 loop /snap/snapd-desktop-integration/315
sda           8:0    0 476.9G  0 disk 
├─sda1        8:1    0   260M  0 part 
├─sda2        8:2    0    16M  0 part 
├─sda3        8:3    0 474.7G  0 part 
└─sda4        8:4    0     2G  0 part 
nvme0n1     259:0    0   1.8T  0 disk 
├─nvme0n1p1 259:1    0     1G  0 part /boot/efi
└─nvme0n1p2 259:2    0   1.8T  0 part /
```

バックアップ。`-n`でbadがなければ`-r3`は実行しなくてよい。

```
sudo ddrescue -f -n /dev/sda ~/sda.img ~/sda.log
sudo ddrescue -d -r3 /dev/sda ~/sda.img ~/sda.log

-f: 既存ファイル上書き許可
-n: まず読み取れる部分を素早くコピー
-d: 直接ディスクアクセス（カーネルキャッシュを避ける）
-r3: 読み取りエラーが出た場合、最大3回再試行
```

物理ディスクは取り出しておく。umountはnot mountedとなっても構わない。

```
sudo umount /dev/sda*
sudo eject /dev/sda
echo 1 | sudo tee /sys/block/sda/device/delete  # 数秒待ち、物理的に取り外す
```

パーティションテーブルをみる

```
sudo fdisk -l ~/sda.img
ディスク /home/mukai/sda.img: 476.94 GiB, 512110190592 バイト, 1000215216 セクタ
単位: セクタ (1 * 512 = 512 バイト)
セクタサイズ (論理 / 物理): 512 バイト / 512 バイト
I/O サイズ (最小 / 推奨): 512 バイト / 512 バイト
ディスクラベルのタイプ: gpt
ディスク識別子: D97043EE-FCE3-473E-BE03-C25CB8864E16

デバイス              開始位置   最後から    セクタ サイズ タイプ
/home/mukai/sda.img1      2048     534527    532480   260M EFI システム
/home/mukai/sda.img2    534528     567295     32768    16M Microsoft 予約領域
/home/mukai/sda.img3    567296  996118527 995551232 474.7G Microsoft 基本データ
/home/mukai/sda.img4 996118528 1000214527   4096000     2G Windows リカバリ環境
```

ループバックに割付してラベル確認

```
$ sudo losetup --partscan --find --show ~/sda.img
例：/dev/loop14
$ sudo blkid /dev/loop14p3
例：/dev/loop14p3: LABEL="Windows" BLOCK_SIZE="512" UUID="D4628FAC628F9242" TYPE="ntfs" PARTLABEL="Basic data partition" PARTUUID="1625de04-f6a6-44db-a8c4-7a0c2c0c0142"
```

ラベルのディレクトリを作ってマウント

```
sudo mkdir -p /mnt/Windows
sudo mount -o ro /dev/loop14p3 /mnt/Windows
```

アンマウント時は逆の手順で

```
sudo umount /mnt/Windows
sudo rmdir /mnt/Windows
sudo losetup -d /dev/loop14
```

img直はサイズが大きすぎるので、qcow2に変換する。

```
sudo apt install qemu-utils
qemu-img convert -c -O qcow2 ~/sda.img ~/sda.qcow2
```

マウント。nbd（Network Block Device）を使う。max_partは各デバイスのパーティション数の上限。ラベル確認はループバックと同じようにできる。

```
sudo modprobe nbd max_part=8
sudo qemu-nbd --connect=/dev/nbd0 ~/sda.qcow2

sudo blkid /dev/nbd0*

sudo mkdir -p /mnt/Windows
sudo mount /dev/nbd0p3 /mnt/Windows
```

アンマウント

```
sudo umount /mnt/Windows
sudo rmdir /mnt/Windows
sudo qemu-nbd --disconnect /dev/nbd0
```
