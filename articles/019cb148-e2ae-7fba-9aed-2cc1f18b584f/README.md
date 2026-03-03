## 光学ディスクメディアのバックアップ

```shellsession
$ lsblk >lsblk.old 2>&1
$ lsblk >lsblk.new 2>&1
$ diff -u lsblk.old lsblk.new
--- lsblk.old   2026-03-03 10:24:03.582146114 +0900
+++ lsblk.new   2026-03-03 10:24:20.609746675 +0900
@@ -14,6 +14,7 @@
 loop12        7:12   0  48.1M  1 loop /snap/snapd/25935
 loop13        7:13   0   576K  1 loop /snap/snapd-desktop-integration/315
 loop14        7:14   0   576K  1 loop /snap/snapd-desktop-integration/343
+sr0          11:0    1  1024M  0 rom  
 nvme0n1     259:0    0   1.8T  0 disk 
 ├─nvme0n1p1 259:1    0     1G  0 part /boot/efi
 └─nvme0n1p2 259:2    0   1.8T  0 part /
```

[GNU ddrescue Manual](https://www.gnu.org/software/ddrescue/manual/ddrescue_manual.html) - 10 Copying CD-ROMs and DVDsより

```shellsession
$ ddrescue -n -b2048 /dev/sr0 cdimage mapfile

$ # リトライ
$ ddrescue -d -r1 -b2048 /dev/sr0 cdimage mapfile
```

初回ないし2回目でbad-sector sizeがゼロであることを祈る。

### 長期保存のための圧縮と検証

ddrescue manualはバックアップの圧縮に[lzip](http://www.nongnu.org/lzip/lzip.html)を推奨している。lzip形式は[lziprecover](http://www.nongnu.org/lzip/lziprecover.html)と組み合わせることでFEC（前方誤り訂正）による修復が可能になる。

ディレクトリの場合

```shellsession
$ tar cf - mybackup | lzip -o mybackup.tar.lz

$ # FECリカバリファイルを生成
$ lziprecover -Fc -v --fec-file=mybackup.tar.lz.fec mybackup.tar.lz
```

単ファイルの場合

```shellsession
$ lzip -k cdimage.iso

$ # FECリカバリファイルを生成
$ lziprecover -Fc -v --fec-file=cdimage.iso.lz.fec cdimage.iso.lz
```

検証

```shellsession
$ # FECファイルを使って整合性を検証
$ lziprecover -Ft --fec-file=mybackup.tar.lz.fec mybackup.tar.lz

$ # FECファイルを使って修復
$ lziprecover -Fr --fec-file=mybackup.tar.lz.fec mybackup.tar.lz
```

展開

```shellsession
$ # ディレクトリの場合
$ lzip -cd mybackup.tar.lz | tar xf -

$ # 単ファイルの場合（cdimage.iso.lz → cdimage.iso）
$ lzip -dk cdimage.iso.lz
```

Ubuntu 24.04のlziprecover 1.24にはFECオプションがない。1.26をDockerでビルドして使う。

```shellsession
$ # ソースコードをホスト側でダウンロード
$ curl -LO http://download.savannah.nongnu.org/releases/lzip/lziprecover/lziprecover-1.26.tar.gz

$ docker run --rm --mount type=bind,src="$PWD",dst=/work ubuntu:24.04 bash -c '
    set -e
    apt-get update -qq && apt-get install -y -qq g++ make >/dev/null 2>&1
    cd /tmp
    tar xf /work/lziprecover-1.26.tar.gz
    cd lziprecover-1.26
    ./configure >/dev/null && make -s
    archive=$(find /work -maxdepth 1 -name "*.tar.lz")
    ./lziprecover -Fc -v --fec-file="${archive}.fec" "$archive"
    chown '"$(id -u):$(id -g)"' "${archive}.fec"
  '
```
