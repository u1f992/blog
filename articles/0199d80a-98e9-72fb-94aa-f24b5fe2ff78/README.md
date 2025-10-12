## CLIでUSBストレージの安全な取り外し

`/dev/sde`を取り外す例。デバイスは`lsblk`で確認できる。

```
$ sync  # 数秒待つ。ステータスLEDなどがあれば動作が終了したことを確認する
$ sudo umount /dev/sde*
$ echo 1 | sudo tee /sys/block/sde/device/delete  # 数秒待ち、物理的に取り外す
```

確認

```
$ dmesg | tail -n 10
...
usb 1-3.2: USB disconnect, device number XX
```
