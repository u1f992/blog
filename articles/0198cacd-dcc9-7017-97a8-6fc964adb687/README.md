## ラップトップにプリインストールされたOEM版Windows 11をKVM上にインストールし直して利用する

Linuxで作業するのも慣れてきたけど、Windowsが必要なこともまれにある……。

Windows 11のインストールメディアのISOイメージは[Microsoftのページ](https://www.microsoft.com/ja-jp/software-download/windows11)からダウンロードできる。もとのPCで回復メディアを作ってもいいのかな。あえてそうする必要はなさそう。

Stable virtio-win ISOを用意しておく。virtio-winのダウンロード先はたらい回し式になっている。

- https://github.com/virtio-win/kvm-guest-drivers-windows Fedoraのページ見てね
  - https://docs.fedoraproject.org/en-US/quick-docs/creating-windows-virtual-machines-using-virtio-drivers/index.html virtio-win-pkg-scriptsのページ見てね
    - https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md

メモリやCPUの使用数は上限を提示されるので、ほどほどに指定する。RAM:12288MB/16GB、CPU:6/8にした。

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

virt-managerで「インストールの前に設定をカスタマイズする」を有効にしてXMLを編集する。名前空間の設定が重要。

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

### ディスクの設定

SATAディスクのディスクバスを~~VirtIO~~ SCSIに変更する。［ハードウェアを追加 > コントローラー］を選択、「種類」を「SCSI」に、「モデル」を「VirtIO SCSI」に設定して［完了］をクリック。

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

virtio-winのインストールのため、Windowsインストールメディア用のほかにCD-ROMデバイスがもう1つ必要。SATA CD-ROMデバイスを追加して、ISOを選択する。

### NIC

「デバイスのモデル」を「virtio」に変更する。

### VM上のWindowsとホストのCPU内蔵グラフィックを共有したい

- [Intel GVT-g - ArchWiki](https://wiki.archlinux.org/title/Intel_GVT-g)
- [Ubuntu+KVM+GVT-gで仮想GPUを仮想環境に割り当てる #Ubuntu - Qiita](https://qiita.com/edidi-n/items/ad8f2d6fab84d958f2e7)
- [openSUSE Tumbleweed上のKVM仮想マシンでIntel iGPUを共有する(GVT-g)その１ - それすらもコアの果て](https://blog.zgock-lab.net/2019/01/23/gvtg/)
- [openSUSE Tumbleweed上のKVM仮想マシンでIntel iGPUを共有する(GVT-g)その２ - それすらもコアの果て](https://blog.zgock-lab.net/2019/01/26/gvtg2/)
- [KVM環境でIntel iGPUグラフィックを仮想マシンにパススルー(というか共有)する - naba_san’s diary](https://naba-san.hatenablog.com/entry/2022/09/19/005709)
- [libvirt で GPU の仮想化を有効にしてみる - delete from hateblo.jp where 1=1;](https://deletefrom.hateblo.jp/entry/2023/09/26/024129)

今回はIntel Core i8-8665U（第8世代）。11世代以降は別途調べ直し

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

`--auto`がそれ

```
  -a, --auto
          Automatically start device on parent availability
```

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

- hostdevのdisplayをonに変更
- `<graphics>`と`<video>`を削除
- 以下を追加

```
    <graphics type='spice'>
      <listen type='none'/>
      <gl enable='yes'/>
    </graphics>
    <video>
      <model type='none'/>
    </video>
```

virtio-winのディスクから以下のドライバをインストールする

- NetKVM
- Balloon
- vioscsi
