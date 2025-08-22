## ラップトップにプリインストールされたOEM版Windows 11をKVM上にインストールし直して利用する

Linuxで作業するのも慣れてきたけど、Windowsが必要なこともまれにある……。

Windows 11のインストールメディアのISOイメージは[Microsoftのページ](https://www.microsoft.com/ja-jp/software-download/windows11)からダウンロードできる。もとのPCで回復メディアを作ってもいいのかな。あえてそうする必要はなさそう。

OEM版のWindowsは次の情報でライセンス認証されている。

<dl>
<dt>SLIC（Software Licensing Description Table）</dt><dd>Windows Vista / 7時代に使われていたACPIテーブル。OEMライセンス自動認証用の情報が含まれており、インストールメディアと照合される仕組みになっている。</dd>
<dt>MSDM（Microsoft Data Management Table）</dt><dd>Windows 8以降に導入されたACPIテーブルで、OEMプリインストール版のWindowsのプロダクトキーを格納している。</dd>
<dt>SMBIOS（System Management BIOS）</dt><dd>ハードウェア構成情報を提供する仕組み。Type 0にはBIOS/UEFI のベンダ名、バージョン、リリース日など、Type 1にはメーカー名、製品名、バージョン、シリアル番号、UUID などが格納されている。</dd>
</dl>

これらを以下のようにダンプして使用する（[参考1](https://gist.github.com/Informatic/49bd034d43e054bd1d8d4fec38c305ec)、[参考2](https://gist.github.com/Informatic/49bd034d43e054bd1d8d4fec38c305ec?permalink_comment_id=4936740#gistcomment-4936740)）。SLICは存在しない場合があり、その場合はダンプせずに無視して構わない。

```
# cat /sys/firmware/acpi/tables/SLIC > slic.bin
# cat /sys/firmware/acpi/tables/MSDM > msdm.bin
# dmidecode -t 0 -u | awk '/^\t\t[0-9A-F][0-9A-F]( |$)/' | xxd -r -p > smbios_type_0.bin
# dmidecode -t 1 -u | awk '/^\t\t[0-9A-F][0-9A-F]( |$)/' | xxd -r -p > smbios_type_1.bin
```

AppArmorによって、libvirtからこれらのファイルを参照できない場合がある（Ubuntu 24.04）。なんかエラー出てるけど自分で触った部分ではないので放っておく。

```
$ sudo cp /etc/apparmor.d/abstractions/libvirt-qemu /etc/apparmor.d/abstractions/libvirt-qemu.org
$ sudo nano /etc/apparmor.d/abstractions/libvirt-qemu
$ tail -n 5 /etc/apparmor.d/abstractions/libvirt-qemu
  # Support for this override will be removed in a future release
  ### DEPRECATED ###
  include if exists <local/abstractions/libvirt-qemu>

/home/mukai/** r,
$ sudo apparmor_parser -r /etc/apparmor.d/abstractions/libvirt-qemu
AppArmor parser error for /etc/apparmor.d/abstractions/libvirt-qemu in profile /etc/apparmor.d/abstractions/openssl at line 13: syntax error, unexpected TOK_MODE, expecting TOK_OPEN
```

メモリやCPUの使用数は上限を提示されるので、ほどほどに指定する。

virt-managerで「インストールの前に設定をカスタマイズする」を有効にしてXMLを編集する。

```xml
<domain type='kvm' xmlns:qemu='http://libvirt.org/schemas/domain/qemu/1.0'>
  <!-- ... -->
  <qemu:commandline>
    <qemu:arg value="-acpitable"/>
    <qemu:arg value="file=/home/mukai/win11/slic.bin"/>
    <qemu:arg value="-acpitable"/>
    <qemu:arg value="file=/home/mukai/win11/msdm.bin"/>
    <qemu:arg value="-smbios"/>
    <qemu:arg value="file=/home/mukai/win11/smbios_type_0.bin"/>
    <qemu:arg value="-smbios"/>
    <qemu:arg value="file=/home/mukai/win11/smbios_type_1.bin"/>
  </qemu:commandline>
</domain>
```

Windowsにはソケット数の制限があり（[参考1](https://qiita.com/rxg03350/items/e76a6a858f6b9ac267b3#3161-cpu%E6%95%B0%E3%81%AE%E8%A8%AD%E5%AE%9A%E5%A4%89%E6%9B%B4)、[参考2](https://learn.microsoft.com/en-us/answers/questions/4032319/what-is-the-maximum-number-of-cpu-and-cores-suppor)）、virt-managerの初期構成では指示したコア数をすべて別ソケットに割り当てる（例：6コア割当→6ソケット各1コア）。そのため、CPUトポロジーを明示してやらないと性能が出ない。この制限の具体的な数値について、公式な情報が見つからない。コミュニティ回答によると、Windows 10にならって次の通りだろうとのこと。

- Maximum CPU sockets:
  - Home - 1
  - Pro - 2
  - Education - 2
  - Pro for Workstations - 4
  - Enterprise - 2
- Maximum CPU cores:
  - Home - 64
  - Pro - 128
  - Education - 128
  - Pro for Workstations - 256
  - Enterprise - 256

通常のPCは1ソケットであり、変な構成のシミュレーションでなければ、6コア割当なら1ソケット6コアに直せばよい。

virtio-winのインストールのため、Windowsインストールメディア用のほかにCD-ROMデバイスがもう1つ必要。

べつによいが、virtio-winのダウンロード先はたらい回し式になっている。

- https://github.com/virtio-win/kvm-guest-drivers-windows Fedoraのページ見てね
  - https://docs.fedoraproject.org/en-US/quick-docs/creating-windows-virtual-machines-using-virtio-drivers/index.html virtio-win-pkg-scriptsのページ見てね
    - https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md

Stable virtio-win ISOを用意しておく。SATA CD-ROMデバイスを追加して、ISOを選択する。SATAディスクのディスクバスをVirtIOに変更する。

Windows用のVirtIO GPUはまだ微妙らしい。ビデオはQXLのままにする。

上部の［インストールの開始］をクリックする。先ほどディスクバスをVirtIOにしたことで、ドライバをインストールするまでディスクを見つけられない状態になっている。「インストールの種類を選んでください」画面では［カスタム］を選択してドライバを読み込む。

VM上のWindowsとホストのCPU内蔵グラフィックを共有したい

- [Ubuntu+KVM+GVT-gで仮想GPUを仮想環境に割り当てる #Ubuntu - Qiita](https://qiita.com/edidi-n/items/ad8f2d6fab84d958f2e7)
- [openSUSE Tumbleweed上のKVM仮想マシンでIntel iGPUを共有する(GVT-g)その１ - それすらもコアの果て](https://blog.zgock-lab.net/2019/01/23/gvtg/)
- [openSUSE Tumbleweed上のKVM仮想マシンでIntel iGPUを共有する(GVT-g)その２ - それすらもコアの果て](https://blog.zgock-lab.net/2019/01/26/gvtg2/)
- [KVM環境でIntel iGPUグラフィックを仮想マシンにパススルー(というか共有)する - naba_san’s diary](https://naba-san.hatenablog.com/entry/2022/09/19/005709)
- [libvirt で GPU の仮想化を有効にしてみる - delete from hateblo.jp where 1=1;](https://deletefrom.hateblo.jp/entry/2023/09/26/024129)
