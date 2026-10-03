## libvirtで管理するWindows VMをセットアップする

ホストにvirt-managerとvirtiofsdをインストールする。ブリッジネットワークを予め構成する。

- [Windows 11 のダウンロード](https://www.microsoft.com/ja-jp/software-download/windows11)

```shellsession
$ sha256sum Windows11_Client_x64_ja-jp_26300_9457.iso 
923ec1a2ec46ccbe607fc81beaf9753bfbb6fc62220b7b8bffd56e66f6de3a0c  Windows11_Client_x64_ja-jp_26300_9457.iso
```

- [virtio-win/virtio-win-pkg-scripts](https://github.com/virtio-win/virtio-win-pkg-scripts)@[b3c54dd](https://github.com/virtio-win/virtio-win-pkg-scripts/tree/b3c54dd86b0763bc8c137c0b874c52ca300a49cd)

```shellsession
$ sha256sum virtio-win-0.1.302.iso 
303f7ae40dad495d6ae474fdc571df58958a4dbc5c37a522d80f9a203867949d  virtio-win-0.1.302.iso
```



```
ファイル(F)＞新しい仮想マシン(N)

新しい仮想マシンの作成
ステップ 1 / 5
---
接続(O): QEMU/KVM

オペレーティングシステムのインストール方法の選択
(x) ローカルのインストールメディア (ISO イメージまたは CD-ROM ドライブ)(L)

アーキテクチャーオプション
アーキテクチャー(A): x86_64

次へ(B)
---

ステップ 2 / 5
---
ISO または CDROM インストールメディアの選択(I):
/var/lib/libvirt/images/Windows11_Client_x64_ja-jp_26300_9457.iso

インストールするオペレーティングシステムの選択(H):
［（自動検出結果）Microsoft Windows 11］
[x] インストールメディアまたはソースから自動検出します(U)

次へ(B)
---

ステップ 3 / 5
---
メモリと CPU の設定:
メモリ(M): 65536
CPU(P): 8

次へ(B)
---
ここではホストの50%を目安に設定。65536 MiB = 64 GiB

ステップ 4 / 5
[x] この仮想マシンにストレージを割り当てる(E)
(x) 仮想マシン用にディスクイメージを作成する(R)
64 GiB

次へ(B)
---
Windows 11の最低要件が64 GBとされている。
[Windows 11 の仕様とシステム要件 | Microsoft Windows](https://www.microsoft.com/ja-jp/windows/windows-11-specifications)

ステップ 5 / 5
---
名前(N): win11
OS: Microsoft Windows 11
インストール: ローカルCDROM/ISO
メモリー: 65536 MiB
CPU: 8
ストレージ: 64.0 GiB /var/lib/libvirt/images/win11.qcow2
[x] インストールの前に設定をカスタマイズする(U)

ネットワークの選択(E)
ブリッジデバイス…
デバイス名(V): br0

完了(F)
---
```

```
CPU 数
---
CPU
  論理ホスト CPU 数: 16
  仮想 CPU 割り当て(L): 8
設定(R)
  [x] ホスト CPU の設定をコピーする (U) (host-passthrough)
トポロジー(P)
  [x] CPU トポロジーの手動設定(Y)
  ソケット数(T): 1
  コア数(E): 8
  スレッド数(S): 1

適用(A)
---

SATA ディスク 1
---
ディスクバス(U): SCSI

適用(A)
---

ハードウェアを追加(D)＞コントローラー
---
種類(T): SCSI
モデル(M): VirtIO SCSI

完了(F)
---

ハードウェアを追加(D)＞ストレージ
---
(x) カスタムストレージの選択または作成(S)
/var/lib/libvirt/images/virtio-win-0.1.302.iso
デバイスの種類(D): CD-ROM デバイス
バスの種類(B): SATA

完了(F)
---

NIC
---
ネットワークソース(N): ブリッジデバイス…
デバイス名(V): br0
デバイスのモデル(L): virtio
リンクの状態(S): [ ] アクティブ

適用(A)
---
ローカルアカウントでセットアップするためにはインターネットから切断する必要がある。

メモリー
---
[x] Enable shared memory

適用(A)
---
virtiofsによるストレージ共有のために必要

ハードウェアを追加(D)＞ファイルシステム
---
ドライバー(D): virtiofs
ソースパス(S): /home/mukai/Public
ターゲットパス(R): share

完了(F)
---
ターゲットパスはドライブ名として使用される
```

<details>
<summary>起動前のXML</summary>

```xml
<domain type="kvm">
  <name>win11</name>
  <uuid>1520e33a-f81e-4e8f-acff-741d9d558133</uuid>
  <metadata>
    <libosinfo:libosinfo xmlns:libosinfo="http://libosinfo.org/xmlns/libvirt/domain/1.0">
      <libosinfo:os id="http://microsoft.com/win/11"/>
    </libosinfo:libosinfo>
  </metadata>
  <memory>67108864</memory>
  <currentMemory>67108864</currentMemory>
  <memoryBacking>
    <source type="memfd"/>
    <access mode="shared"/>
  </memoryBacking>
  <vcpu current="8">8</vcpu>
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
    <topology sockets="1" cores="8" threads="1"/>
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
      <source file="/var/lib/libvirt/images/Windows11_Client_x64_ja-jp_26300_9457.iso"/>
      <target dev="sdb" bus="sata"/>
      <readonly/>
    </disk>
    <disk type="file" device="cdrom">
      <driver name="qemu" type="raw"/>
      <source file="/var/lib/libvirt/images/virtio-win-0.1.302.iso"/>
      <target dev="sdc" bus="sata"/>
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
    <controller type="scsi" model="virtio-scsi"/>
    <filesystem type="mount">
      <source dir="/home/mukai/Public"/>
      <target dir="share"/>
      <driver type="virtiofs"/>
    </filesystem>
    <interface type="bridge">
      <source bridge="br0"/>
      <mac address="52:54:00:69:8a:05"/>
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
    <graphics type="spice" port="-1" tlsPort="-1" autoport="yes">
      <image compression="off"/>
    </graphics>
    <sound model="ich9"/>
    <video>
      <model type="qxl"/>
    </video>
    <redirdev bus="usb" type="spicevmc"/>
    <redirdev bus="usb" type="spicevmc"/>
  </devices>
</domain>
```

</details>

［インストールの開始］をクリックすると仮想マシンが起動する。

```
Press any key to boot from CD or DVD......

BdsDxe: No bootable option or device was found.
BdsDxe: Press any key to enter the Boot Manager Menu.
```

で停止するので［仮想マシン(M)＞シャットダウン(S)＞強制的に電源OFF(F)＞はい(Y)］で停止して、スナップショットを作成。

```
Press any key to boot from CD or DVD...
すばやく何らか入力する

Windows 11 セットアップ
言語設定を選択
---
インストールする言語　日本語 (日本)
時刻と通過の形式　日本語 (日本)

次へ(N)
---

キーボード設定を選択
---
キーボードまたは入力方式　Microsoft IME
キーボードの種類　日本語キーボード (106/109 キー)

次へ(N)
---

セットアップオプションの選択
---
次を希望します:　(x) Windows 11 のインストール
[x] ファイル、アプリ、設定など、全てが削除されることに同意します(A)

次へ(N)
---

プロダクト キーを入力してください
---
次へ(N)
---
予め用意したリテール版のプロダクトキーを入力

適用される通知とライセンス条項
---
同意する(A)
---

Windows 11 をインストールする場所の選択
---
ドライバーのロード(L)＞参照
CD ドライブ (E:) virtio-win-0.1.302
vioscsi＞w11＞amd64
OK

「Red Hat VirtIO SCSI pass-through controller」を選択
インストール(I)

ディスク 0 の未割り当て領域 64.0 GB
次へ(N)
---

インストール準備完了
---
インストール(I)
---
```

```
国または地域を選択してください
---
日本

はい
---

使用するキーボード レイアウトまたは入力方式を選択してください
---
Microsoft IME

次へ
---

2つ目のキーボード レイアウトを追加しますか?
---
スキップ
---

ネットワークに接続しましょう
---
Shift+F10
start ms-cxh:localonly
---

Microsoftアカウント
---
---
この時点ではパスワードは未設定のほうが取り回しがよい

デバイスのプライバシー設定の選択
---
位置情報　はい
デバイスの検索　いいえ
診断データ　必須のみ
手書き入力とタイプ入力　はい
パーソナライズされたオファー　はい

同意
---
既定のまま
```

デスクトップが表示されたらデバイスの暗号化を無効化。

```
設定＞プライバシーとセキュリティ＞デバイスの暗号化＞デバイスの暗号化　オフ
オフにする
```

シャットダウンしてスナップショットを作成

```
SATA CDROM 2
---
Remove
---

SATA CDROM 1
---
ソースパス(P): /var/lib/libvirt/images/virtio-win-0.1.302.iso

適用(A)
---
```

ディスクからvirtio-win-guest-toolsを実行。

```
Virtio-win-guest-tools Setup
Welcome to Virtio-win guest tools setup
---
[x] I agree to the license terms and conditions

Install
---

Virtio-win-driver-installer Setup
Welcome to the Virtio-win-driver-installer Setup Wizard
---
Next
---

End-User License Agreement
---
[x] I accept the terms in the License Agreement

Next
---

Custom Setup
---
Next
---

Ready to install Virtio-win-driver-installer
---
Install
---

Completed the Virtio-win-driver-installer Setup Wizard
---
Finish
---

Virtio-win-guest-tools Setup
Installation Successfully
---
Close
---
```

シャットダウンしてスナップショット作成

```
SATA CDROM 1
---
ソースパス(P):

適用(A)
---

NIC
---
リンクの状態(S): [x] アクティブ

適用(A)
---
```

```
設定＞Windows Update
更新プログラムのチェック
すべてダウンロードしてインストール
今すぐ再起動する
```

シャットダウンしてスナップショット作成

再起動してネットワークの接続を待つ。

Win+R `cmd /c curl -L https://github.com/winfsp/winfsp/releases/download/v2.1/winfsp-2.1.25156.msi -o "%USERPROFILE%\Desktop\winfsp-2.1.25156.msi"`

```
WinFsp 2025 Setup
Welcome to the WinFsp 2025 Setup Wizard
---
Next
---

Custom Setup
---
Next
---

Ready to install WinFsp 2025
---
Install
---

Completed the WinFsp 2025 Setup Wizard
---
Finish
---
```

インストーラーはShift+Delete

```
タスクマネージャー＞サービス＞VirtioFsSvc＞サービス管理ツールを開く(V)
VirtIO-FS Service＞プロパティ(R)

スタートアップの種類(E): 自動

適用(A)
OK
```

再起動してZ:ドライブが見えていたら成功。シャットダウンしてスナップショット作成

SPICE側の設定は表示>画面の拡大縮小>常に行う＋仮想マシンのウィンドウを自動的にリサイズ　に設定。

SSH Serverを有効化する。まずはパスワードを設定。

設定＞アカウント＞サインイン オプション＞パスワード＞追加

自動ログインを有効化。netplwizで「ユーザーがこのコンピューターを使うには、ユーザー名とパスワードの入力が必要(E)」チェックボックスが表示されなかった。まずregeditで`HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device DevicePasswordLessBuildVersion`を2から0変更。そのあとnetplwizでチェックボックスを外せる。再起動して無効化されていることを確認。

- [Windows 11マシンでSSH Serverを有効化](../019cea7e-8067-765e-a399-1e570d927076/README.md)

謎のタイミングで初期セットアップが表示された

```
はじめに
こんにちは
---
開始する
---

サイトをピン留めしてすばやくアクセスする
---
>
---

外観を変更する
---
>
---

PCを更新する
---
>
---

準備が完了しました。

[x]で閉じる
```

シャットダウンしてスナップショット作成

- [VMのDHCP割当結果を知りたい](../019d4180-08b1-7677-9c80-f85e22602b6f/README.md)
- [鍵認証によるSSH接続をセットアップする](../019bb9d8-575c-7540-a95d-e63e62606895/README.md)

鍵を登録してシャットダウンして、スナップショット作成。VMのMACでDHCP固定割当も設定しておくとよい。

WindowsのOpenSSH Serverでは、「昇格」済みのセッションに入る。ここらへんのWindowsの詳しい権限の仕組みはよくわかっていないが、常に「管理者として実行」されている状態と考えるとよい。

- [gsudoは「降格」もできる](../01a0ff97-1618-705d-834d-c7a8210be085/README.md)

Win+R `cmd /c curl -L https://github.com/gerardog/gsudo/releases/download/v2.6.1/gsudo.setup.x64.msi -o "%USERPROFILE%\Desktop\gsudo.setup.x64.msi"`

```
gsudo v2.6.1 Setup
Welcome to the gsudo v2.6.1 Setup Wizard
---
Next
---

Destination Folder
---
C:\Program Files\gsudo\

Next
---

Ready to install gsudo v2.6.1
---
Install
---
```

インストーラーはShift+Delete。シャットダウンしてスナップショットを作成。

```
PS > wsl --install
```

「既定では、インストールされている Linux ディストリビューションは Ubuntu になります。」[WSL のインストール | Microsoft Learn](https://learn.microsoft.com/ja-jp/windows/wsl/install)とあるが、実際にはディストリビューションはインストールされなかった。2回目の`wsl --install`でインストールされた。

```
PS > wsl
Linux 用 Windows サブシステムにインストールされているディストリビューションはありません。
この問題を解決するには、以下の手順に従ってディストリビューションをインストールしてください:

'wsl.exe --list --online' を使用して利用可能な配布を一覧表示する
および 'wsl.exe --install <Distro>' を使用してインストールしてください。

PS > wsl --install
ダウンロードしています： Ubuntu
...
```

必要に応じてsudoersを設定しておくといい。VMの中のさらにコンテナなのだし。

```
$ sudo visudo -f /etc/sudoers.d/mukai
mukai ALL=(ALL:ALL) NOPASSWD: ALL
```

WSLの初回利用時に「Linux 用 Windows サブシステムにようこそ」というウィンドウが表示された。

シャットダウンしてスナップショットを作成。
