## ThinkPad P52 (20MA)

中古で買った。簡易NASがほしかったのと、冬はブレーカーを落としがちなのでバッテリーが搭載されているマシンをWireGuardサーバーにしたかった。M.2 NVMe SSDを2基＋SATA HDD/SSDを1基搭載できるのでOS用のディスク以外の2基でRAIDを構成できる。

とりあえず初回起動チェックでバッテリーの明らかな劣化はなさそう。

バッテリーを取り外したところにあるシリアル番号をLenovoサポートに入力したが情報を得られない。ディスクは工場出荷時状態の復元ではなく素のWindows 11をクリーンインストールされているらしく、Lenovoのツールがインストールされていない。マシン自体からシリアル番号を検出するためにLenovo Service Bridgeをインストールした。シリアル番号はこれで検出された。「PF-xxx」のうちハイフンは省いたものを入力するべきだった。

Windows 11 ProがインストールされているがBitLockerは有効化されていない。

コントロール パネル＞ハードウェアとサウンド＞電源ボタンの動作の変更＞現在利用可能ではない設定を変更します＞高速スタートアップを有効にする　のチェックを外して「変更の保存」をクリック。Shiftを入力しながらシャットダウンして完全シャットダウン。

メモ：SATAケーブルと2つ目のM.2スロットのSSDのネジは付属していない。M.2 SSDのスロットに付いていた黒いリボンは剥がした。M.2 SSDの下にあったサーマルパッドを触ったら端が少し欠けた。

[ハードディスクのバックアップとマウント](../019a6ca6-0d53-7974-b579-3093debccc70/README.md)

```
$ sudo lsblk >lsblk.old.log 2>&1
$ sudo lsblk >lsblk.log 2>&1
$ diff lsblk.old.log lsblk.log
27a28,32
> sdf           8:80   0 238.5G  0 disk 
> ├─sdf1        8:81   0   100M  0 part 
> ├─sdf2        8:82   0    16M  0 part 
> ├─sdf3        8:83   0 237.6G  0 part /media/mukai/BCC4988BC4984992
> └─sdf4        8:84   0   779M  0 part 
$ sudo ddrescue -f -n /dev/sdf ~/sdf.img ~/sdf.log
$ sudo umount /dev/sdf*
$ sudo eject /dev/sdf
$ echo 1 | sudo tee /sys/block/sdf/device/delete
$ mkdir ~/sdf
$ sudo losetup --partscan --find --show ~/sdf.img
/dev/loop3
$ sudo mount /dev/loop3p3 ~/sdf
$ ls ~/sdf
'$Recycle.Bin'            'Program Files'               Windows
'Documents and Settings'  'Program Files (x86)'         hiberfil.sys
 Drivers                   ProgramData                  inetpub
 DumpStack.log.tmp         Recovery                     pagefile.sys
 Intel                    'System Volume Information'   swapfile.sys
 PerfLogs                  Users
$ sudo umount ~/sdf
$ rmdir ~/sdf
$ sudo losetup -d /dev/loop3
```

完全シャットダウンしたので`-o ro`でなくてもマウントできるようになっている。そもそも特に残したい情報があるわけでもないが念の為。

問題なさそうなのでQCOW2に圧縮する。

```
$ qemu-img convert -c -O qcow2 ~/sdf.img ~/sdf.qcow2
```
