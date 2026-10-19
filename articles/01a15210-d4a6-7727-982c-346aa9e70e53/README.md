## BtrfsによるRAID1

`sda`と`sdb`でBtrfsによるRAID1を構成したい。後日同容量のHDDをもう1台追加して2台までの故障に耐える構成にする予定がある。

現在のディスクの状況を確認[^exclude-7]。

[^exclude-7]: `--exclude 7`はメジャー番号7であるloopデバイスを除外するオプション。

```
$ lsblk --exclude 7
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda           8:0    0  7.3T  0 disk 
sdb           8:16   0  7.3T  0 disk 
sdc           8:32   1    0B  0 disk 
sdd           8:48   1 14.4G  0 disk 
└─sdd1        8:49   1 14.4G  0 part 
nvme0n1     259:0    0  1.8T  0 disk 
├─nvme0n1p1 259:1    0    1G  0 part /boot/efi
└─nvme0n1p2 259:2    0  1.8T  0 part /
```

btrfsがインストールされているか確認。パッケージ名は`btrfs-progs`。

```
$ btrfs --version
btrfs-progs v6.6.3
```

過去に使用されたディスクには、ディスクパーティションの先頭や末尾に識別用のマジックバイトやヘッダといった署名が付与されることがある。これらは問題の原因になるので確認して削除する。今回は未使用のディスクなので該当なしだった。

```
$ sudo wipefs /dev/sda /dev/sdb
$ sudo lsblk --fs /dev/sda /dev/sdb
NAME
    FSTYPE FSVER LABEL UUID FSAVAIL FSUSE% MOUNTPOINTS
sda
sdb
```

削除する場合は`sudo wipefs --all /dev/sda /dev/sdb`を実行する。mdadmやLVMのものだった場合は、それらから適切に降ろされているか確認しておくとよい。

RAID1の構成。

```
$ sudo mkfs.btrfs --metadata raid1 --data raid1 /dev/sda /dev/sdb
btrfs-progs v6.6.3
See https://btrfs.readthedocs.io for more information.

NOTE: several default settings have changed in version 5.15, please make sure
      this does not affect your deployments:
      - DUP for metadata (-m dup)
      - enabled no-holes (-O no-holes)
      - enabled free-space-tree (-R free-space-tree)

Label:              (null)
UUID:               7ed13eca-d834-42a9-b408-814c1e0dde68
Node size:          16384
Sector size:        4096
Filesystem size:    14.55TiB
Block group profiles:
  Data:             RAID1             1.00GiB
  Metadata:         RAID1             1.00GiB
  System:           RAID1             8.00MiB
SSD detected:       no
Zoned device:       no
Incompat features:  extref, skinny-metadata, no-holes, free-space-tree
Runtime features:   free-space-tree
Checksum:           crc32c
Number of devices:  2
Devices:
   ID        SIZE  PATH    
    1     7.28TiB  /dev/sda
    2     7.28TiB  /dev/sdb
```

マウントポイントを作成し、`/etc/fstab`に追記する

```
$ sudo mkdir /data
$ sudo vim /etc/fstab

UUID=7ed13eca-d834-42a9-b408-814c1e0dde68  /data  btrfs  defaults,nofail,noauto,x-systemd.automount,x-gvfs-show  0  0
```

- `nofail`：ディスク故障時に起動が止まらないようにする（故障状態では`sudo mount -o degraded /data`が必要）
- `noauto,x-systemd.automount`：最初のアクセスまで実際のマウントを遅延させる
- `x-gvfs-show`：Nautilusのサイドバーに並べる
- `0 0`：前者`fs_freq`は`dump`コマンドというレガシーツールの対象指定。後者`fs_passno`は`fsck`を実行する順番を示す。Btrfsでは0にするよう推奨されている[^no-fs-passno]

[^no-fs-passno]: https://btrfs.readthedocs.io/en/latest/fsck.btrfs.html / [e7e0fc3](https://github.com/kdave/btrfs-progs/blob/e7e0fc3a952161ead7c2b06b037c5e93f5bf81dd/Documentation/fsck.btrfs.rst?plain=1#L16-L18)

自動マウントを有効化

```
$ sudo systemctl daemon-reload
$ sudo systemctl start data.automount
$ sudo chown "$(id -u):$(id -g)" /data
```

確認。`autofs`と`btrfs`が出ていれば自動マウント経由で正しくマウントされている。

```
$ findmnt /data
TARGET
      SOURCE    FSTYPE OPTIONS
/data systemd-1 autofs rw,relatime,fd=103,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=12889
/data /dev/sda  btrfs  rw,relatime,space_cache=v2,subvolid=5,subvol=/
$ sudo btrfs filesystem usage /data
Overall:
    Device size:                  14.55TiB
    Device allocated:              4.02GiB
    Device unallocated:           14.55TiB
    Device missing:                  0.00B
    Device slack:                    0.00B
    Used:                        288.00KiB
    Free (estimated):              7.28TiB      (min: 7.28TiB)
    Free (statfs, df):             7.28TiB
    Data ratio:                       2.00
    Metadata ratio:                   2.00
    Global reserve:                5.50MiB      (used: 0.00B)
    Multiple profiles:                  no

Data,RAID1: Size:1.00GiB, Used:0.00B (0.00%)
   /dev/sda        1.00GiB
   /dev/sdb        1.00GiB

Metadata,RAID1: Size:1.00GiB, Used:128.00KiB (0.01%)
   /dev/sda        1.00GiB
   /dev/sdb        1.00GiB

System,RAID1: Size:8.00MiB, Used:16.00KiB (0.20%)
   /dev/sda        8.00MiB
   /dev/sdb        8.00MiB

Unallocated:
   /dev/sda        7.28TiB
   /dev/sdb        7.28TiB
```

### 3台目の追加

Btrfsでは、RAID1を構成するディスク数ごとRAID1C3、RAID1C4のバリアントに明示的に変更する必要がある。

署名の削除は上の通り行ったあと、ファイルシステムにデバイスを追加する。

```
$ sudo btrfs device add /dev/sdX /data
```

データとメタデータの両方を`raid1c3`へ変換する。全データを書き直すので格納量に応じて長時間かかる。

```
$ sudo btrfs balance start --background -dconvert=raid1c3 -mconvert=raid1c3 /data
$ sudo btrfs balance status /data
```

完了後、Data、Metadata、Systemが`RAID1C3`になり、ratioが3.00になっていることを確認する。

```
$ sudo btrfs filesystem usage /data
```
