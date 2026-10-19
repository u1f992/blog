## mdadm構成を解除する

```
$ lsblk --fs
NAME                      FSTYPE            FSVER    LABEL          UUID                                   FSAVAIL FSUSE% MOUNTPOINTS
sda                                                                                                                       
└─sda1                    linux_raid_member 1.2      thinkpad-p52:0 ce3ece66-3cca-33bd-0900-42188cd3632c                  
  └─md0                   ext4              1.0                     315df42b-07cf-4f0e-89f0-f29d14047349      3.4T     0% /srv/storage
nvme1n1                                                                                                                   
├─nvme1n1p1               vfat              FAT32                   8613-A39D                                   1G     1% /boot/efi
├─nvme1n1p2               ext4              1.0                     f3b2cca0-9ace-47f8-a6a3-48c8948dd896      1.6G    10% /boot
└─nvme1n1p3               LVM2_member       LVM2 001                EhzFRa-y8J5-FZOw-oV41-OgM3-kEwl-tnMskA                
  └─ubuntu--vg-ubuntu--lv ext4              1.0                     31cd4152-36fb-4d96-b3f6-3f814fa8b53f     84.6G     8% /
nvme0n1                                                                                                                   
└─nvme0n1p1               linux_raid_member 1.2      thinkpad-p52:0 ce3ece66-3cca-33bd-0900-42188cd3632c                  
  └─md0                   ext4              1.0                     315df42b-07cf-4f0e-89f0-f29d14047349      3.4T     0% /srv/storage
```

自動マウントを解除する

```
$ cat /etc/fstab | grep 315df42b
UUID=315df42b-07cf-4f0e-89f0-f29d14047349  /srv/storage  ext4  defaults,noatime  0  2

$ sudo vim /etc/fstab  # 該当行削除

$ sudo systemctl daemon-reload
```

現在のマウントの解除

```
$ systemctl list-units --type=mount --type=automount --all --no-pager | grep srv-storage
  srv-storage.mount                                                          loaded    active   mounted /srv/storage
$ sudo fuser -vm /srv/storage
                     USER        PID ACCESS COMMAND
/srv/storage:        root     kernel mount /srv/storage
$ sudo umount /srv/storage
$ findmnt /srv/storage
```

アレイを停止する。`/proc/mdstat`に`md0`が現れなくなった。

```
$ sudo mdadm --stop /dev/md0
mdadm: stopped /dev/md0
$ cat /proc/mdstat
Personalities : [raid1] [raid0] [raid6] [raid5] [raid4] [raid10] 
unused devices: <none>
```

スーパーブロックを消去。この操作で`md0`のデータは消失し、`FSTYPE`が空になる。

```
$ sudo mdadm --zero-superblock /dev/sda1 /dev/nvme0n1p1
$ lsblk --fs /dev/sda /dev/nvme0n1
NAME        FSTYPE FSVER LABEL UUID FSAVAIL FSUSE% MOUNTPOINTS
sda                                                
└─sda1                                             
nvme0n1                                            
└─nvme0n1p1
```

設定ファイルの再生性。次のコマンドは標準出力に表示するだけでファイルを変更しない。出力にARRAY行がないことを確認する。

```
$ sudo /usr/share/mdadm/mkconf
```

なければ再生成に進める。

```
$ sudo /usr/share/mdadm/mkconf force-generate
$ cat /etc/mdadm/mdadm.conf  # 先ほどと同一内容のはず
$ sudo update-initramfs -u
```

再起動後、解除されていることを確認。

```
$ cat /proc/mdstat
$ lsblk --fs
```
