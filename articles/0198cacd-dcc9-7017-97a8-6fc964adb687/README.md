## ラップトップにプリインストールされたOEM版Windows 11をKVM上にインストールし直して利用する

Linuxで作業するのも慣れてきたけど、Windowsが必要なこともまれにある……。

- ThinkPad X1 Carbon (7th Gen, 2019)
  - メモリ：16GB、プロセッサー：Intel Core i7-8665U
- ホスト：Ubuntu 24.04
- ゲスト：Windows 11 24H2

ホストにvirt-managerとvirtiofsdをインストールする。後ほどファイル共有で使用する。

virt-managerのインストールはUbuntuのコミュニティドキュメントに含まれている。[KVM/Installation - Community Help Wiki](https://help.ubuntu.com/community/KVM/Installation)（最終更新日：2020年3月23日）

Windows 11のインストールメディアのISOイメージは[Microsoftのページ](https://www.microsoft.com/ja-jp/software-download/windows11)からダウンロードできる。もとのPCで回復メディアを作ってもいいのかな。ハードウェア構成が変わるのであえてそうする必要はなさそう。

Stable virtio-win ISOを用意しておく。virtio-winのダウンロード先はたらい回し式になっている。

- https://github.com/virtio-win/kvm-guest-drivers-windows Fedoraのページ見てね
  - https://docs.fedoraproject.org/en-US/quick-docs/creating-windows-virtual-machines-using-virtio-drivers/index.html virtio-win-pkg-scriptsのページ見てね
    - https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md

virt-managerで新規VMを作成する。

- ［ローカルのインストールメディア (ISOイメージまたはCD-ROMドライブ)］＞［次へ］
- ［ISOまたはCDROMインストールメディアの選択］にダウンロード済みのWindows 11ディスクイメージを指定＞［次へ］
- ［メモリとCPUの設定］＞［次へ］
  - ホストの50%程度のリソースに留めないとホストのパフォーマンスが低下し総合的に性能向上しない、としばしば聞く
  - 今回は8192MiB／4個を指定した
- ［仮想マシン用にディスクイメージを作成する］＞［次へ］
  - 実機のケースだが、あまりに少ないとWindows Updateに失敗しているのを見たことがある
  - 今回は128GB割り当てた
- ［インストールの前に設定をカスタマイズする］のチェックを必ず入れる＞［完了］

### ライセンス情報をダンプ

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

「概要」からXMLを編集する。名前空間の設定が重要。変更後は［適用］をクリックする。

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

### CPUトポロジーの手動設定

Windowsにはソケット数の制限があり（[参考1](https://qiita.com/rxg03350/items/e76a6a858f6b9ac267b3#3161-cpu%E6%95%B0%E3%81%AE%E8%A8%AD%E5%AE%9A%E5%A4%89%E6%9B%B4)、[参考2](https://learn.microsoft.com/en-us/answers/questions/4032319/what-is-the-maximum-number-of-cpu-and-cores-suppor)）、virt-managerの初期構成では指示したコア数をすべて別ソケットに割り当てる（例：4コア割当→4ソケット各1コア）。そのため、CPUトポロジーを明示してやらないと性能が出ない。この制限の具体的な数値について、公式な情報が見つからない。コミュニティ回答によると、Windows 10にならって次の通りだろうとのこと。

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

通常のPCは1ソケットであり、変な構成のシミュレーションでなければ、4個割当なら1ソケット4コアに直せばよい。

### ディスクの設定

SATAディスクにVirtIOを使用することでI/O速度が改善する。

「SATA ディスク 1」のディスクバスを「SCSI」に変更する。［ハードウェアを追加 > コントローラー］を選択、「種類」を「SCSI」に、「モデル」を「VirtIO SCSI」に設定して［完了］をクリック。

ディスクバスには「VirtIO」という選択肢もある。「SCSI」との違いは次の通りで、「VirtIO」指定は旧方式と読み取れる。

<ul>
<li>
<a href="https://forum.proxmox.com/threads/virtio-vs-scsi.52893/post-245981">VirtIO vs SCSI | Proxmox Support Forum</a>
<blockquote>
<p>What I can tell is that the scsi virtio is better maintained and virtio-blk is the older one.</p>
</blockquote>
</li>
<li>
<a href="https://blog.zgock-lab.net/2019/01/26/gvtg2/">openSUSE Tumbleweed上のKVM仮想マシンでIntel iGPUを共有する(GVT-g)その２ - それすらもコアの果て</a>
<blockquote>
<p>今回はvirtioを使用するため、ディスクの設定をデフォルトのSATAから変更します</p>
<p>詳細オプションから「SCSI」を選択します</p>
<p>ここで「virtio」を選択可能ですが、現在はレガシーな手法とされており、VirtIO SCSIコントローラを使用して制御するのが推奨されています</p>
<p>（中略）</p>
<p>「ハードウェアを追加」からVirtIO SCSIコントローラを追加します</p>
<p>ここで明示的に追加しないと、libvirtがlsilogicエミュレーションのコントローラを勝手に追加しますのでかならず明示的に追加してください</p>
</blockquote>
</li>
</ul>

### virtio-win用にCD-ROMデバイスを追加

virtio-winのインストールのため、Windowsインストールメディア用のほかにCD-ROMデバイスがもう1つ必要。［ハードウェアを追加 > ストレージ］を選択、SATA CD-ROMデバイスを追加して、ISOを選択する。

### NIC

「デバイスのモデル」を「virtio」に変更する。

「リンクの状態：アクティブ」のチェックを外す。インストール時にインターネットに接続されているとWindows Updateを自動適用し、再起動の回数が増える。今回の構成だとこの再起動が不安定なようで、「Windowsが正しく読み込まれませんでした」という画面に落ちて正しくインストールが完了できないようだ（複数回発生、毎回同じフェーズで失敗しているかは不明）。

ただし執筆時点のWindows 11 Home/Proはインストール時にインターネット接続が必要ということになっているようで、途中で進行不能になる。インストール中に後述のハックが必要。

### ファイル共有の準備

メモ：[SPICE > Download > Guest > Windows binaries](https://www.spice-space.org/download.html#windows-binaries)で配布されているSpice WebDAVは使い方がわからなかった。性能的にもvirtiofsのほうが有用そう。

- https://blog.sergeantbiggs.net/posts/file-sharing-with-qemu-and-virt-manager/
- https://donbulinux.hatenablog.jp/entry/2024/07/12/150851

virtiofsを動作させる要件として、［メモリー］に移動し［Enable shared memory］を有効化。［ハードウェアを追加 > ファイルシステム］「Driver」は「virtiofs」に設定し、共有したいホスト上のパスを指定。`/home/mukai/Public`など。「ターゲットパス」はパスではないので要注意。Windowsゲストではドライブ名として使用される。「share」とでもしておけばよろしい。

> The target path is a bit of a misnomer. It’s not actually a path, just an identifier that we use as a mount point in our guest file system.

### VM上のWindowsとホストのCPU内蔵グラフィックを共有したい

今回はIntel Core i7-8665U（第8世代）。11世代以降は別途調べ直し

- [Intel GVT-g - ArchWiki](https://wiki.archlinux.org/title/Intel_GVT-g)
  - [Ubuntu+KVM+GVT-gで仮想GPUを仮想環境に割り当てる #Ubuntu - Qiita](https://qiita.com/edidi-n/items/ad8f2d6fab84d958f2e7)
  - [openSUSE Tumbleweed上のKVM仮想マシンでIntel iGPUを共有する(GVT-g)その１ - それすらもコアの果て](https://blog.zgock-lab.net/2019/01/23/gvtg/)
  - [openSUSE Tumbleweed上のKVM仮想マシンでIntel iGPUを共有する(GVT-g)その２ - それすらもコアの果て](https://blog.zgock-lab.net/2019/01/26/gvtg2/)
  - [KVM環境でIntel iGPUグラフィックを仮想マシンにパススルー(というか共有)する - naba_san’s diary](https://naba-san.hatenablog.com/entry/2022/09/19/005709)
  - [libvirt で GPU の仮想化を有効にしてみる - delete from hateblo.jp where 1=1;](https://deletefrom.hateblo.jp/entry/2023/09/26/024129)

### カーネルパラメータの設定

```
$ sudo nano /etc/default/grub

# GRUB_CMDLINE_LINUXに追記
GRUB_CMDLINE_LINUX="intel_iommu=on i915.enable_gvt=1 i915.enable_guc=0"

# 反映
$ sudo update-grub
```

<dl>
<dt><code>intel_iommu=on</code></dt><dd>IOMMUの有効化。安全に実デバイスをVMへ割り当てるための機構。</dd>
<dt><code>i915.enable_gvt=1</code></dt><dd>GVT-gホスト対応を有効化。i915はモジュール名。</dd>
<dt><code>i915.enable_guc=0</code></dt><dd>GuC＝スケジューラ/サブミッション（＋一部電源管理）をGPU内のマイコンで処理。HuC＝エンコード系のメディア処理をオフロードして省電力・低負荷化。GVT-gでは無効にしたほうが安定するらしい。</dd>
</dl>

### モジュールをロード

```
# 存在チェック
$ sudo modprobe --dry-run --verbose kvmgt vfio-iommu-type1 mdev

$ echo "kvmgt" | sudo tee /etc/modules-load.d/kvmgt.conf
$ echo "vfio-iommu-type1" | sudo tee /etc/modules-load.d/vfio-iommu-type1.conf
$ echo "mdev" | sudo tee /etc/modules-load.d/mdev.conf
```

ここで一度再起動。

mdevctlを使えば仮想GPUの自動確保もやってもらえる。

```
$ sudo apt --yes install mdevctl
$ mdevctl types
0000:00:02.0
  i915-GVTg_V5_4
    Available instances: 1
    Device API: vfio-pci
    Name: GVTg_V5_4
    Description: low_gm_size: 128MB, high_gm_size: 512MB, fence: 4, resolution: 1920x1200, weight: 4
  i915-GVTg_V5_8
    Available instances: 2
    Device API: vfio-pci
    Name: GVTg_V5_8
    Description: low_gm_size: 64MB, high_gm_size: 384MB, fence: 4, resolution: 1024x768, weight: 2
$ sudo mdevctl define --auto --uuid $(uuidgen) --parent 0000:00:02.0 --type i915-GVTg_V5_8
```

~~`--auto`がそれ~~

```
  -a, --auto
          Automatically start device on parent availability
```

mdevctl 1.3.0の自動起動の設定では`/usr/sbin/mdevctl`を参照しているが（[参考](https://github.com/mdevctl/mdevctl/blob/48e26971b0a21464e0432dcdc36f3cd10a1629c8/60-mdevctl.rules)）、Ubuntu 24.04では`/usr/bin/mdevctl`にインストールされるので自動起動が失敗している。[報告済み](https://bugs.launchpad.net/ubuntu/+source/mdevctl/+bug/2121264)

```
$ which mdevctl
/usr/bin/mdevctl
$ journalctl -u systemd-udevd -b | grep mdevctl
 8月 23 08:00:36 mukai-ThinkPad-X1-Carbon-7th mdevctl[509]: /bin/sh: 1: /usr/sbin/mdevctl: not found
```

仕方ないのでとりあえずシンボリックリンクを追加

```
$ sudo ln -s /usr/bin/mdevctl /usr/sbin/mdevctl
```

再起動して`mdevctl list`で起動していることを確認。

カツカツな設定（weight:4/fence:4）にすると失敗する。ここで`golden_hw_state failed with error -2`は実際にはエラーではないらしい（[参考](https://github.com/intel/gvt-linux/issues/212)）

```
mukai@mukai-ThinkPad-X1-Carbon-7th:~$ sudo dmesg | grep -i gvt
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-6.14.0-27-generic root=UUID=e21f1775-eca7-40bf-9752-96720ff71178 ro intel_iommu=on i915.enable_gvt=1 i915.enable_guc=0 quiet splash vt.handoff=7
[    0.058214] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-6.14.0-27-generic root=UUID=e21f1775-eca7-40bf-9752-96720ff71178 ro intel_iommu=on i915.enable_gvt=1 i915.enable_guc=0 quiet splash vt.handoff=7
[    5.412043] i915 0000:00:02.0: Direct firmware load for i915/gvt/vid_0x8086_did_0x3ea0_rid_0x02.golden_hw_state failed with error -2
[   77.118191] gvt: fail to alloc low gm space from host
[   77.118382] gvt: failed to create intel vgpu: -28
```

割り当てられたIDは次のコマンドで確認できる。

```
$ mdevctl list -d
ae6411d7-151d-485d-98e7-fa377c478da0 0000:00:02.0 i915-GVTg_V5_8 auto

$ sudo mdevctl start --uuid ae6411d7-151d-485d-98e7-fa377c478da0
$ sudo systemctl restart libvirtd
```

### virt-managerでの指定

［ハードウェアを追加 > MDEVホストデバイス］を選択、先ほどのUUIDのデバイスを選択して［完了］をクリック。

```xml
<hostdev mode="subsystem" type="mdev" managed="yes" model="vfio-pci" display="off" ramfb="off">
  <source>
    <address uuid="ae6411d7-151d-485d-98e7-fa377c478da0"/>
  </source>
</hostdev>
```

［概要］のXMLタブを開く。名前空間の設定が重要（ライセンス情報の参照時に追加した）。

```xml
<domain type='kvm' xmlns:qemu='http://libvirt.org/schemas/domain/qemu/1.0'>
  <!-- ... -->
  <qemu:override>
    <qemu:device alias="hostdev0">
      <qemu:frontend>
        <qemu:property name="x-igd-opregion" type="bool" value="true"/>
      </qemu:frontend>
    </qemu:device>
  </qemu:override>
</domain>
```

UEFI（OVMF）のゲストではDMA-BUFディスプレイが表示されない。「[extract the OpROM](http://120.25.59.132:3000/vbios_gvt_uefi.rom) from the kernel patch ([source](https://www.reddit.com/r/VFIO/comments/av736o/creating_a_clover_bios_nonuefi_install_for_qemu/ehdz6mf/)) and feed it to QEMU as an override.」してやる必要がある（[参考](https://wiki.archlinux.org/title/Intel_GVT-g)）。

<details>
<summary>ビルドしてやりたかったが起動しなかった</summary>

`i915ovmf.rom`をビルドする。2月11日以降のArch Linuxの変更でビルドできなくなっているので、それ以前のコンテナでビルドする。

```
$ docker run -it --rm archlinux:base-devel-20250209.0.306557 bash

# pacman -Sy --noconfirm git sudo python acpica
# useradd -m builder
# passwd -d builder
# echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
# su - builder
$ git clone https://aur.archlinux.org/i915ovmf.git
$ cd i915ovmf
$ makepkg -s --noconfirm
$ mkdir output
$ bsdtar -xvf i915ovmf-*.pkg.tar.zst -C output
x .BUILDINFO
x .MTREE
x .PKGINFO
x var/
x var/lib/
x var/lib/libvirt/
x var/lib/libvirt/qemu/
x var/lib/libvirt/qemu/drivers/
x var/lib/libvirt/qemu/drivers/i915ovmf.rom
```

別ターミナルから

```
$ docker ps
$ docker cp <コンテナID>:/home/builder/i915ovmf/output ./i915ovmf
$ sudo mkdir -p /var/lib/libvirt/qemu/drivers
$ sudo cp ./i915ovmf/var/lib/libvirt/qemu/drivers/i915ovmf.rom /var/lib/libvirt/qemu/drivers/
```

</details>

http://120.25.59.132:3000/vbios_gvt_uefi.rom からダウンロードして適当な場所に置く。`sha256:33e540db0838fd49236087d2cda21f4eaa38672f6b2ac56f45351799858de085`

```xml
<!-- ... -->
  <qemu:override>
    <qemu:device alias="hostdev0">
      <qemu:frontend>
        <!-- ... -->
        <qemu:property name="romfile" type="string" value="/home/mukai/win11/vbios_gvt_uefi.rom"/>
        <!-- ... -->
      </qemu:frontend>
    </qemu:device>
  </qemu:override>
<!-- ... -->
```

RAMFBディスプレイを有効化

```xml
<!-- ... -->
  <qemu:override>
    <qemu:device alias="hostdev0">
      <qemu:frontend>
        <!-- ... -->
        <qemu:property name="driver" type="string" value="vfio-pci-nohotplug"/>
        <qemu:property name="ramfb" type="bool" value="true"/>
        <!-- ... -->
      </qemu:frontend>
    </qemu:device>
  </qemu:override>
<!-- ... -->
```

「Output using SPICE with MESA EGL」に従う。注意書きが少ないから。

- XML上で先程のmdevデバイスのdisplayを`on`に変更
- ［ディスプレイ Spice］に移動して［リッスンタイプ］を［なし］、［Open GL］のチェックを入れる
- ［ビデオ QXL］に移動して［モデル］を［None］に変更

---

最終的なインストール前のXMLは次の通り。

```xml
<domain xmlns:qemu="http://libvirt.org/schemas/domain/qemu/1.0" type="kvm">
  <name>win11</name>
  <uuid>3ec8e879-7140-42cb-9024-8af9504056e9</uuid>
  <metadata>
    <libosinfo:libosinfo xmlns:libosinfo="http://libosinfo.org/xmlns/libvirt/domain/1.0">
      <libosinfo:os id="http://microsoft.com/win/11"/>
    </libosinfo:libosinfo>
  </metadata>
  <memory>8388608</memory>
  <currentMemory>8388608</currentMemory>
  <vcpu current="4">4</vcpu>
  <os firmware="efi">
    <type arch="x86_64" machine="q35">hvm</type>
    <boot dev="hd"/>
  </os>
  <features>
    <acpi/>
    <apic/>
    <hyperv>
      <relaxed state="on"/>
      <vapic state="on"/>
      <spinlocks state="on" retries="8191"/>
    </hyperv>
    <vmport state="off"/>
  </features>
  <cpu mode="host-passthrough">
    <topology sockets="1" cores="4" threads="1"/>
  </cpu>
  <clock offset="localtime">
    <timer name="rtc" tickpolicy="catchup"/>
    <timer name="pit" tickpolicy="delay"/>
    <timer name="hpet" present="no"/>
    <timer name="hypervclock" present="yes"/>
  </clock>
  <pm>
    <suspend-to-mem enabled="no"/>
    <suspend-to-disk enabled="no"/>
  </pm>
  <devices>
    <emulator>/usr/bin/qemu-system-x86_64</emulator>
    <disk type="file" device="disk">
      <driver name="qemu" type="qcow2" discard="unmap"/>
      <source file="/var/lib/libvirt/images/win11.qcow2"/>
      <target dev="sda" bus="scsi"/>
    </disk>
    <disk type="file" device="cdrom">
      <driver name="qemu" type="raw"/>
      <source file="/home/mukai/win11/Win11_24H2_Japanese_x64.iso"/>
      <target dev="sdb" bus="sata"/>
      <readonly/>
    </disk>
    <controller type="usb" model="qemu-xhci" ports="15"/>
    <controller type="pci" model="pcie-root"/>
    <controller type="pci" model="pcie-root-port"/>
    <controller type="pci" model="pcie-root-port"/>
    <controller type="pci" model="pcie-root-port"/>
    <controller type="pci" model="pcie-root-port"/>
    <controller type="pci" model="pcie-root-port"/>
    <controller type="pci" model="pcie-root-port"/>
    <controller type="pci" model="pcie-root-port"/>
    <controller type="pci" model="pcie-root-port"/>
    <controller type="pci" model="pcie-root-port"/>
    <controller type="pci" model="pcie-root-port"/>
    <controller type="pci" model="pcie-root-port"/>
    <controller type="pci" model="pcie-root-port"/>
    <controller type="pci" model="pcie-root-port"/>
    <controller type="pci" model="pcie-root-port"/>
    <interface type="network">
      <source network="default"/>
      <mac address="52:54:00:38:29:da"/>
      <model type="virtio"/>
      <link state="down"/>
    </interface>
    <console type="pty"/>
    <channel type="spicevmc">
      <target type="virtio" name="com.redhat.spice.0"/>
    </channel>
    <input type="tablet" bus="usb"/>
    <tpm model="tpm-crb">
      <backend type="emulator"/>
    </tpm>
    <graphics type="spice">
      <image compression="off"/>
      <gl enable="yes" rendernode="/dev/dri/by-path/pci-0000:00:02.0-render"/>
      <listen type="none"/>
    </graphics>
    <sound model="ich9"/>
    <video>
      <model type="none"/>
    </video>
    <redirdev bus="usb" type="spicevmc"/>
    <redirdev bus="usb" type="spicevmc"/>
    <controller type="scsi" model="virtio-scsi"/>
    <disk type="file" device="cdrom">
      <driver name="qemu" type="raw"/>
      <source file="/home/mukai/win11/virtio-win-0.1.271.iso"/>
      <target dev="sdc" bus="sata"/>
      <readonly/>
    </disk>
    <filesystem type="mount">
      <source dir="/home/mukai/Public"/>
      <target dir="share"/>
      <driver type="virtiofs"/>
    </filesystem>
    <hostdev mode="subsystem" type="mdev" managed="yes" model="vfio-pci" display="on" ramfb="off">
      <source>
        <address uuid="ae6411d7-151d-485d-98e7-fa377c478da0"/>
      </source>
    </hostdev>
  </devices>
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
  <memoryBacking>
    <source type="memfd"/>
    <access mode="shared"/>
  </memoryBacking>
  <qemu:override>
    <qemu:device alias="hostdev0">
      <qemu:frontend>
        <qemu:property name="x-igd-opregion" type="bool" value="true"/>
        <qemu:property name="romfile" type="string" value="/home/mukai/win11/vbios_gvt_uefi.rom"/>
        <qemu:property name="driver" type="string" value="vfio-pci-nohotplug"/>
        <qemu:property name="ramfb" type="bool" value="true"/>
      </qemu:frontend>
    </qemu:device>
  </qemu:override>
</domain>
```

［インストールの開始］をクリックすると仮想マシンが起動する。「Press any key to boot from CD or DVD...」と表示されたらすばやく何らかのキーを入力してインストール画面に入る。

「vioscsi」ドライバをインストールするまでディスクを見つけられない。virtio-winのディスクからインストールする。

途中まで進めるとネットワークに繋げと要求されて進行不能になるが、ここまでNICのリンクを切っている上ドライバーもインストールしていない。`Shift+F10`・`start ms-cxh:localonly`で回避（[参考](https://x.com/witherornot1337/status/1906050664741937328)）。ここで、ユーザー名がホームディレクトリ名になり、パスワードは空でも通る。インストールが完了したらそのままシャットダウンしスナップショットを作成しておくとよい。

ディスクドライブ1のWindowsのインストールディスクを割当解除し、追加した2つめのディスクドライブを削除、1つめのディスクドライブにvirtio-winのディスクを割り当て直す。

マシンを再起動して、virtio-winディスクに含まれているvirtio-win-guest-tools.exeをインストールする。virtioドライバー一式がインストールされ、ゲストエージェントもインストールされる。シャットダウンしてスナップショットを作成。

virtio-winのディスクを取り外す（ディスクドライブは残しISOの割当を除去）。NICのリンクを有効化して再起動。Windows Updateを適用する。Windows Updateに要求される再起動を終えたらもう一度Windows Updateを確認してアップデートがないことを確認したらシャットダウン（ここでも「更新プログラムを構成しています」と出たら再度起動してシャットダウン。更新の半端なところで止めるのはなんだかよくなさそう）。スナップショットを作成。Windows Updateのダウンロード・インストール進行中に何度か画面がチカチカして（グラフィックドライバがインストールされている？）`dxdiag`やタスク マネージャーでもGPUが見えていることが確認できるようになる。

ファイル共有を有効化するために[WinFsp](https://winfsp.dev/)をインストールする（[参考](https://donbulinux.hatenablog.jp/entry/2024/07/12/150851)）。これはWindowsでFUSE的な機能を提供する仕組み。Win+Rで「プログラムの実行」を開き、`cmd /c curl -L https://github.com/winfsp/winfsp/releases/download/v2.0/winfsp-2.0.23075.msi -o "%USERPROFILE%\Desktop\winfsp-2.0.23075.msi"`でブラウザを開かずにダウンロードして、エクスプローラーを開かずに起動できる。最新のダウンロードパスは逐次確認すること。インストール後にインストーラーはShift+Delで消しておく（なにか失敗してOneDriveにバックアップされると嫌）。タスクマネージャーの「サービス」から「VirtioFsSvc」を探し、右クリック > サービス管理ツールを開く。「VirtIO-FS Service」のプロパティを開き、スタートアップの種類を「自動」に変更して適用。再起動してZ:ドライブが自動で見えていたら成功。現れるまで少し時間がかかるかも。シャットダウンしてスナップショットを作成。

これでVMの用意は完了した。おすすめ→電源プランをパフォーマンス優先に変更、スリープ無効化、OneDriveアンインストール、開発者モードの有効化、BitLocker解除
