## ddでISOを焼く

忘れがち

```
$ lsblk > /tmp/lsblk-before.txt
  # 接続してから次のコマンド
$ diff /tmp/lsblk-before.txt <(lsblk)
  # 例：以前Ubuntuのインストールに使用したメディア
  # 15a16,20
  # > sda           8:0    1  28.9G  0 disk 
  # > ├─sda1        8:1    1   5.9G  0 part /media/mukai/Ubuntu 24.04.3 LTS amd64
  # > ├─sda2        8:2    1     5M  0 part 
  # > ├─sda3        8:3    1   300K  0 part 
  # > └─sda4        8:4    1    23G  0 part /media/mukai/writable
$ sudo umount /dev/sda*
$ sudo dd if=ubuntu-24.04.3-live-server-amd64.iso of=/dev/sda bs=4M status=progress oflag=sync
  # - `bs=4M`
  #   - システムコール回数に影響する。小さすぎるとバッファに余裕のあるシステムコール回数が増え遅くなる。大きすぎるとバッファに収まらず遅くなる
  #   - 未指定時は512になるので、指定はほぼ必須
  # - `oflag=sync`
  #   - 各書き込みを同期（sync）I/Oとして行う。速度を犠牲に書き込みの確実性を高める
$ sync
  # 数秒待つ。ステータスLEDなどがあれば動作が終了したことを確認する
$ sudo umount /dev/sda*
$ echo 1 | sudo tee /sys/block/sda/device/delete
  # 数秒待ち、物理的に取り外す
```
