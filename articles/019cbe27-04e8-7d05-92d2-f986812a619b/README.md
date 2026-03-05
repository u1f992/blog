## Ubuntu Serverにおけるファームウェア（BIOS／UEFI）更新

Ubuntu DesktopのFirmware Updaterに相当するCLIの仕組みを調べておきたい。

Ubuntu Serverには`fwupd`（ファームウェア更新デーモン）が標準搭載されている。

```shellsession
$ # メタデータ取得
$ sudo fwupdmgr refresh

$ # 更新確認
$ sudo fwupdmgr get-updates

$ # 更新適用（再起動後に自動フラッシュ）
$ sudo fwupdmgr update
```

- [LVFS](https://fwupd.org/)（Linux Vendor Firmware Service）からファームウェアをダウンロード
  - Dell、HP、Lenovo、Intelなど各社が参加。ただし対応はまちまちで、Linux対応を謳っていない製品については期待できない。
- OEM署名済みの UEFI Capsule をEFI System Partitionに配置
- 再起動時にUEFIファームウェアがCapsuleを検証・適用

ベンダーがLVFSにファームウェアを登録していない場合、`fwupdmgr get-updates`を使用しても`No updatable devices`と表示される。この場合でも、配布形態によってはチャンスがある。

### UEFI Capsule形式（.cab/.cap）

ベンダーがUEFI Capsule形式で配布している場合、直接`fwupdmgr`でインストールできる。Windows用の自己解凍形式でも、展開すると実態はこの形式になっている可能性がある（後述）。

```shellsession
$ sudo fwupdmgr local-install firmware.cab
```

<details>
<summary>Capsuleの自作はできない</summary>

後述のように生のBIOSを得られるケースで、Capsuleを自作してやればよいのではと考えた。

これは実現できないようだ。UEFI Capsule Updateでは、ファームウェアがCapsuleのOEM暗号署名を検証する。署名がないCapsuleは検証に失敗し、適用が拒否される。当たり前だがOEMの署名鍵は非公開であり、第三者がCapsuleに署名することはできない。

</details>

### ベンダー独自ツール形式

AMI Aptio系BIOSでは、ベンダー独自ツールであるAMI AFU（Aptio Flash Update）を使用するケースがある。

[Lenovo Legion T5-28IMB05](https://pcsupport.lenovo.com/jp/ja/products/desktops-and-all-in-ones/legion-series/legion-t5-28imb05/downloads/ds544035-bios-for-windows-10-64-bit-legion-r5-28imb05-desktop-legion-t5-28imb05-desktop?category=BIOS%2FUEFI)では、生のSPIフラッシュイメージ（.bin）とAMI AFUのWindows用バイナリをWindows用の自己解凍形式で提供している。

Windows用の自己解凍形式はある程度Linuxでも展開できる。今回はファイル内に「Inno Setup」という文字列を見つけて判別できた。

```shellsession
$ # 書庫形式の特定
$ docker run --rm -v "$PWD:/work" ubuntu:24.04 bash -c \
  "apt-get update -qq && apt-get install -y -qq binutils > /dev/null 2>&1 \
   && strings /work/*.exe | grep -iE 'inno setup|nsis|7-zip|WinRAR SFX|InstallShield'"

出力例：
  Inno Setup Setup Data (5.5.7) (u)
  Inno Setup Messages (5.5.3) (u)
```

他の一般的な形式と対応ツールは次の通り。不明の場合は`7z x`で試してみる。

| 文字列 | 書庫形式 | 展開ツール |
|--------|---------|-----------|
| `Inno Setup` | InnoSetup | `innoextract` |
| `Nullsoft` / `NSIS` | NSIS | `7z x` (p7zip) |
| `7-Zip` | 7-Zip SFX | `7z x` |
| `WinRAR SFX` | RAR SFX | `unrar x` |

```shellsession
$ # InnoSetup の場合の展開
$ docker run --rm -v "$PWD:/work" ubuntu:24.04 bash -c \
  "apt-get update -qq && apt-get install -y -qq innoextract > /dev/null 2>&1 \
   && cd /work && mkdir -p extracted && innoextract -d extracted *.exe"

$ # 展開結果の確認
$ find extracted -type f
```

この段階で、先に説明したUEFI Capsule形式を抽出できる可能性もある。Lenovo Legion T5-28IMB05では残念ながら生フラッシュイメージが含まれていた。

```shellsession
$ # ファイル形式の確認
$ file extracted/*/*.bin
  → "Intel serial flash for PCH ROM" なら生イメージ
```

AMI AFU自体は個別に提供されているツールであり、提供されているWindows版を使う必要は特にない。BIOSに対応するものを用意すればUEFIシェルから実行できる。

#### Aptioのバージョンを判別する

同梱のAFU バイナリ内のエラーメッセージから、対象BIOSのAptioバージョンを推定できる。

```shellsession
$ # AFUバイナリから Aptio バージョン判定文字列を抽出
$ docker run --rm -v "$PWD:/work" ubuntu:24.04 bash -c \
  "apt-get update -qq && apt-get install -y -qq binutils > /dev/null 2>&1 \
   && strings /work/extracted/*/AFUWIN.EXE | grep -i 'aptio'"

出力例：
  |%*s - Don't Check Aptio 4 and Aptio 5 platform.                    |
  Error: Using the wrong AFU version, Please use Aptio 4 AFU.
  Error: Using the wrong AFU version, Please use Aptio 5 AFU.
```

この出力は、AFUがイメージ読み込み時にAptio IV/Vを自動判定し、不一致なら対応するエラーを出す実装と推測できる。両方のメッセージが埋め込まれているということは、このAFUはIV/V両対応版であり、イメージもIVあるいはVであることがわかる。あとはマシンの世代から推定する。

- Aptio IV：〜2015年頃まで
- Aptio V：2016年頃以降

最終的には、AFU EFI版を実際に実行して拒否されるかどうかで判別するしかない。

#### AFUのダウンロード

AMI公式サイトで配布されている。[Support Docs Archives](https://www.ami.com/resource-type/support-docs/) → Topics: Aptio で絞り込み「Aptio V Firmware Update Utility」「Aptio 4 Firmware Update Utility」からそれぞれダウンロードできる。

- 直リンク（参考）：https://9443417.fs1.hubspotusercontent-na1.net/hubfs/9443417/Support/BIOS_Firmware_Update/Aptio_V_AMI_Firmware_Update_Utility.zip
- 直リンク（参考）：https://9443417.fs1.hubspotusercontent-na1.net/hubfs/9443417/Support/BIOS_Firmware_Update/Aptio4_AMI_Firmware_Update_Utility.zip

「AMI Firmware Update Utility – (AFU) utility for Aptio V, Aptio 4, and AMIBIOS, scriptable CLI utility for DOS and Windows.」からはVと4が同梱されたZIPをダウンロードできるが、Vについてはバイナリのタイムスタンプが古い（個別配布: 2025-06-17、同梱版: 2023-10-18）。4については同一。

- 直リンク（参考）：https://9443417.fs1.hubspotusercontent-na1.net/hubfs/9443417/Support/BIOS_Firmware_Update/AMIBIOS_and_Aptio_AMI_Firmware_Update_Utility.zip

#### EFIシェルから実行する

AFU EFI版（`AfuEfix64.efi`）はUEFIシェルから実行する。UEFIシェルはFATフォーマットのUSBメディアから起動できる。

```shellsession
$ # USBメモリをFAT32でフォーマット（デバイス名は環境に応じて変更）
$ sudo mkfs.vfat -F 32 /dev/sdX1

$ # マウントしてファイルを配置
$ sudo mount /dev/sdX1 /mnt
$ sudo mkdir -p /mnt/efi/boot

$ # UEFIシェルバイナリを起動用パスに配置
$ sudo cp efi-shell/usr/share/efi-shell-x64/shellx64.efi /mnt/efi/boot/bootx64.efi

$ # AFUバイナリとBIOSイメージをルートに配置
$ sudo cp AfuEfix64.efi /mnt/
$ sudo cp imageO4N.bin /mnt/

$ sudo umount /mnt
```

UEFIシェルバイナリはUbuntuの`efi-shell-x64`パッケージ（ソース: [edk2](https://github.com/tianocore/edk2)）として提供されている。EDK2はビルド済みバイナリを配布していないが、Ubuntuがedk2ソースからビルドしたものをパッケージとして配布している。debパッケージをダウンロードして中身を取り出せばよい。

```shellsession
$ apt-get download efi-shell-x64
$ dpkg-deb -x efi-shell-x64_*.deb efi-shell/
$ ls efi-shell/usr/share/efi-shell-x64/shellx64.efi
```

USBメモリから起動するには、マシンの電源投入時にブートメニュー（多くの場合F12キー）からUSBデバイスを選択する。UEFIシェルが起動したら、USBメディアのファイルシステムに移動してAFUを実行する。

```
Shell> fs0:
FS0:\> AfuEfix64.efi /?
```

AFUのreadmeに列挙されたオプションは汎用的なもので、プラットフォームごとに使用可能なオプションは異なる。UEFIシェル上で`AfuEfix64.efi /?`を実行し、そのマシンで有効なオプションを確認する。

#### イメージの領域構成を確認する

生SPIフラッシュイメージにはBIOS以外の領域（Intel ME、GbEなど）が含まれている場合がある。`coreboot-utils`パッケージの`ifdtool`でIntel Flash Descriptorを解析し、イメージに含まれる領域を確認できる。

```shellsession
$ docker run --rm -v "$PWD:/work" ubuntu:24.04 bash -c \
  "apt-get update -qq && apt-get install -y -qq coreboot-utils > /dev/null 2>&1 \
   && ifdtool -d /work/imageO4N.bin" | grep -A2 'Flash Region'

出力例：
  Flash Region 0 (Flash Descriptor): 00000000 - 00000fff
  Flash Region 1 (BIOS): 01000000 - 01ffffff
  Flash Region 2 (Intel ME): 00001000 - 00ffffff
  Flash Region 3 (GbE): 00fff000 - 00000fff (unused)
  Flash Region 4 (Platform Data): 00fff000 - 00000fff (unused)
```

この例ではFlash Descriptor、BIOS、Intel MEの3領域が有効。AFUの`/?`で表示されたオプションと照合し、書き込み対象を決定する。

| イメージ内の領域 | 対応するAFUオプション |
|-----------------|---------------------|
| BIOS | `/P`（Main BIOS）、`/B`（Boot Block）、`/N`（NVRAM） |
| Intel ME | `/ME` |
| Flash Descriptor | `/FDR`（`*1`） |
| GbE | `/GBER`（`*1`） |

`*1`: BIOSモジュールが対応を報告した場合のみ使用可能。`/?`に表示されなければ使えない。

オプションを省略するとMain BIOSのみが対象になる。ROM IDの不一致で拒否される場合は`/X`（ROM ID検証スキップ）を追加する。

書き込み完了後、マシンを再起動するとBIOSが更新される。

### flashrom

条件付きでflashromで直接書き込む方法もある。

- Kernel Lockdown：Secure Bootが有効な場合、カーネルが`integrity`モードでロックダウンされ、`/dev/mem`やI/Oポートへの直接アクセスがブロックされる（`/sys/kernel/security/lockdown`で確認できる）。Secure Bootを無効化するか、カーネルパラメータ`lockdown=none`で再起動すれば解除できる。
- PCH SPI Write Protection：Intel PCHがSPIフラッシュのBIOS領域を書き込み保護している場合がある。これはハードウェアレベルの保護で、OS側から解除できない。flashromが検出して報告する。保護の有無は機種・BIOS設定依存。

両方クリアできれば、直接ファームウェアを書き込める可能性がある。

```shellsession
$ sudo apt install flashrom

$ # 読み出し (バックアップ)
$ sudo flashrom -p internal -r backup.bin

$ # 書き込み
$ sudo flashrom -p internal -w new_bios.bin
```

