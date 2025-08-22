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



VM上のWindowsとホストのCPU内蔵グラフィックを共有したい

- [Ubuntu+KVM+GVT-gで仮想GPUを仮想環境に割り当てる #Ubuntu - Qiita](https://qiita.com/edidi-n/items/ad8f2d6fab84d958f2e7)
- [openSUSE Tumbleweed上のKVM仮想マシンでIntel iGPUを共有する(GVT-g)その１ - それすらもコアの果て](https://blog.zgock-lab.net/2019/01/23/gvtg/)
- [openSUSE Tumbleweed上のKVM仮想マシンでIntel iGPUを共有する(GVT-g)その２ - それすらもコアの果て](https://blog.zgock-lab.net/2019/01/26/gvtg2/)
- [KVM環境でIntel iGPUグラフィックを仮想マシンにパススルー(というか共有)する - naba_san’s diary](https://naba-san.hatenablog.com/entry/2022/09/19/005709)
- [libvirt で GPU の仮想化を有効にしてみる - delete from hateblo.jp where 1=1;](https://deletefrom.hateblo.jp/entry/2023/09/26/024129)

今回はIntel Core i8-8665U（第8世代）。11世代以降は別途調べ直し

### 1. ホストのカーネルパラメータとモジュールの設定

#### 1-A. カーネルパラメータの設定

```
$ sudo nano /etc/default/grub

# GRUB_CMDLINE_LINUXに追記
GRUB_CMDLINE_LINUX="i915.enable_gvt=1 i915.enable_guc=0 intel_iommu=on"

# 反映
$ sudo update-grub
```

<dl>
<dt><code>i915.enable_gvt=1</code></dt><dd>GVT-gホスト対応を有効化。i915はモジュール名。</dd>
<dt><code>i915.enable_guc=0</code></dt><dd>GuC＝スケジューラ/サブミッション（＋一部電源管理）をGPU内のマイコンで処理。HuC＝エンコード系のメディア処理をオフロードして省電力・低負荷化。GVT-gでは無効にしたほうが安定するらしい。</dd>
<dt><code>intel_iommu=on</code></dt><dd>IOMMUの有効化。安全に実デバイスをVMへ割り当てるための機構。</dd>
</dl>

#### 1-B. 起動時に明示的にkvmgtをロード

```
$ sudo nano /etc/modules-load.d/kvmgt.conf

# 1行追記
kvmgt
```

#### 1-C. KVMのMSR例外対策（Windows ゲストの安定化）

```
$ sudo nano /etc/modprobe.d/kvm.conf

# 1行追記
options kvm ignore_msrs=Y report_ignored_msrs=N
```

ここで一度再起動。`sudo dmesg | grep iommu`で確認。

### 2. GVT-g（mdev）の設定

まずはGPUのPCIアドレスを特定する。

```
$ lspci -nn -D | grep -i 'vga\|igd\|uhd'
0000:00:02.0 VGA compatible controller [0300]: Intel Corporation WhiskeyLake-U GT2 [UHD Graphics 620] [8086:3ea0] (rev 02)

$ find /sys/class/drm/card*
/sys/class/drm/card1
/sys/class/drm/card1-DP-1
/sys/class/drm/card1-DP-2
/sys/class/drm/card1-HDMI-A-1
/sys/class/drm/card1-eDP-1

$ readlink -f /sys/class/drm/card1/device
/sys/devices/pci0000:00/0000:00:02.0
```

対応しているGVT-g（mdv）を調べる。

```
$ ls /sys/devices/pci0000\:00/0000\:00\:02.0/mdev_supported_types/
i915-GVTg_V5_4  i915-GVTg_V5_8

$ cat /sys/devices/pci0000\:00/0000\:00\:02.0/mdev_supported_types/i915-GVTg_V5_4/description
low_gm_size: 128MB
high_gm_size: 512MB
fence: 4
resolution: 1920x1200
weight: 4

$ cat /sys/devices/pci0000\:00/0000\:00\:02.0/mdev_supported_types/i915-GVTg_V5_8/description
low_gm_size: 64MB
high_gm_size: 384MB
fence: 4
resolution: 1024x768
weight: 2
```

<dl>
<dt><code>low_gm_size／high_gm_size</code></dt><dd>vGPUの予約VRAM（最小/最大）容量</dd>
<dt><code>fence</code></dt><dd>ホスト側の枠数</dd>
<dt><code>weight</code></dt><dd>このタイプが消費する枠（そのものではない。ゲストでweight:4/fence:4を使い切ってもホストは無事）</dd>
</dl>

### 3. vGPUの作成

```
$ UUID="$(uuidgen)"
$ echo "$UUID" | sudo tee /sys/devices/pci0000\:00/0000\:00\:02.0/mdev_supported_types/i915-GVTg_V5_4/create
xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
$ ls -d /sys/devices/pci0000\:00/0000\:00\:02.0/* | grep "$UUID"
/sys/devices/pci0000:00/0000:00:02.0/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

メモ：削除は`echo 1 | sudo tee /sys/bus/mdev/devices/$UUID/remove`

vGPUはホストの電源を落とすたびに削除されるので、次のようなスクリプトでVMの起動にフックして作成されるようにする。

- [Intel GVT-g - ArchWiki](https://wiki.archlinux.org/title/Intel_GVT-g) 1.2.1 Option 1: libvirt QEMU hook

<blockquote>
<figure>
<figcaption>/etc/libvirt/hooks/qemu<figcaption>

```sh
#!/bin/sh
GVT_PCI=<GVT_PCI>
GVT_GUID=<GVT_GUID>
MDEV_TYPE=<GVT_TYPE>
DOMAIN=<DOMAIN name>
if [ $# -ge 3 ]; then
    if [[ " $DOMAIN " =~ .*\ $1\ .* ]] && [ "$2" = "prepare" ] && [ "$3" = "begin" ]; then
        echo "$GVT_GUID" > "/sys/devices/pci0000:00/$GVT_PCI/mdev_supported_types/$MDEV_TYPE/create"
    elif [[ " $DOMAIN " =~ .*\ $1\ .* ]] && [ "$2" = "release" ] && [ "$3" = "end" ]; then
        echo 1 > "/sys/devices/pci0000:00/$GVT_PCI/$GVT_GUID/remove"
    fi
fi
```

</figure>

Do not forget to make the file [executable](https://wiki.archlinux.org/title/Executable) and to quote each variable value e.g. `GVT_PCI="0000:00:02.0"`. You will also need to restart the libvirtd daemon so that it is aware of the new hook.

<div>

Note:

- If you use libvirt user session, you need to tweak the script to use privilege elevation commands, such as pkexec(1) or a no-password sudo.
- The XML of the domain is feed to the hook script through stdin. You can use `xmllint` and XPath expression to extract `GVT_GUID` from stdin, e.g.:<pre><code>GVT_GUID="$(xmllint --xpath 'string(/domain/devices/hostdev[@type="mdev"][@display="on"]/source/address/@uuid)' -)"</code></pre>

</div>
</blockquote>

`[[ ]]`がbash拡張なのでshebangは`#!/bin/bash`が正しそう。

libvirtをどちらで動かしているか確認する

```
$ virsh uri
qemu:///system
# or qemu:///session
```

`qemu:///system`なら書いてある通りにすればよい。

<details>
<summary><code>qemu:///session</code>なら</summary>

hooksのパスは`~/.config/libvirt/hooks/qemu`

権限を考慮して変更するとこんな感じ（`sudo tee`使用）

```
#!/bin/bash
GVT_PCI=<GVT_PCI>
GVT_GUID=<GVT_GUID>
MDEV_TYPE=<GVT_TYPE>
DOMAIN=<DOMAIN name>
if [ $# -ge 3 ]; then
    if [[ " $DOMAIN " =~ .*\ $1\ .* ]] && [ "$2" = "prepare" ] && [ "$3" = "begin" ]; then
        echo "$GVT_GUID" | sudo /usr/bin/tee "/sys/devices/pci0000:00/$GVT_PCI/mdev_supported_types/$MDEV_TYPE/create" >/dev/null
    elif [[ " $DOMAIN " =~ .*\ $1\ .* ]] && [ "$2" = "release" ] && [ "$3" = "end" ]; then
        echo 1 | sudo /usr/bin/tee "/sys/devices/pci0000:00/$GVT_PCI/$GVT_GUID/remove" >/dev/null
    fi
fi
```

`/etc/sudoers.d/libvirt-mdev`に追記

```
Cmnd_Alias MDEV_TEE_CMDS = \
    /usr/bin/tee /sys/devices/pci0000\:00/0000\:00\:02.0/mdev_supported_types/*/create, \
    /usr/bin/tee /sys/devices/pci0000\:00/0000\:00\:02.0/*/remove

mukai ALL=(root) NOPASSWD: MDEV_TEE_CMDS
```

</details>

権限を付与してデーモンを再起動する。

```
sudo chmod +x /etc/libvirt/hooks/qemu
sudo systemctl restart libvirtd
```

### 4. vGPUの割り当て

ディスプレイの「リッスン」を「なし」に変更、「OpenGL」にチェックを入れる。

ビデオはQXLのままにする。

ハードウェアを追加。「MDEVホストデバイス」から先ほどのUUIDのデバイスを選択。

上部の［インストールの開始］をクリックする。先ほどディスクバスをVirtIOにしたことで、ドライバをインストールするまでディスクを見つけられない状態になっている。「インストールの種類を選んでください」画面では［カスタム］を選択してドライバを読み込む。

`viogpudo`・`Balloon`のドライバーもインストール

Windowsのインストールが済んだら一旦VMを終了

MDEV xxxx…のXMLを開き、`display=on`に変更する。ビデオQXLをNoneに変更する。

概要のXMLから末尾に以下を追加

```
  <qemu:override>
    <qemu:device alias="hostdev0">
      <qemu:frontend>
        <qemu:property name="x-igd-opregion" type="bool" value="true"/>
        <qemu:property name="driver" type="string" value="vfio-pci-nohotplug"/>
        <qemu:property name="ramfb" type="bool" value="true"/>
      </qemu:frontend>
    </qemu:device>
  </qemu:override>
```

ChatGPTがいうには

```
- name="x-igd-opregion" type="bool" value="true"

Intel iGPU（IGD）用の “OpRegion（VBT 含む）” をゲストへ露出します。これにより物理出力のコネクタ情報などをゲスト側ドライバが取得でき、Windows での画面出力が有効化されます。IGD を mdev/VFIO で使う際に必須とされます。

- name="driver" type="string" value="vfio-pci-nohotplug"

QEMU の VFIO デバイスを**“nohotplug” 派生**に切り替えます。

これは後述の ramfb を使うために必須で、ramfb はファームウェア（fw_cfg）に依存しホットプラグと両立しないため、ramfb は nohotplug 版にだけ実装されています。

- name="ramfb" type="bool" value="true"

RAM Framebuffer（ramfb）を有効化。UEFI/ブート段階から簡易フレームバッファで画面表示でき、GPUドライバがロードされる前の POST/UEFI/ブート画面も見られるようになります（VNC/SPICE/egl-headless 等のグラフィクスと併用）。
```
