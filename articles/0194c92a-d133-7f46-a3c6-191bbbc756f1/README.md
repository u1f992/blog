## ディスクのフルバックアップイメージをマウントする

```
$ mkdir -p /path/to/mount
$ kpartx -av /path/to/hdd.img
$ mount -o ro /dev/mapper/loop0pX /path/to/mount
```

### アンマウント手順

```
$ umount /path/to/mount
$ kpartx -d /path/to/hdd.img
$ rm -rf /path/to/mount
```
