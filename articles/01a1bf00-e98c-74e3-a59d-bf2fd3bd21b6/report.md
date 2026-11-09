# win2go起動がホストの永続領域に与える変更(調査報告)

対象ホストはUbuntu 24.04が稼働するMSI B760 GAMING PLUS WIFI DDR4(MS-7D98、AMI BIOS M.A0 2026-08-19、Secure Boot有効、TPM 2.0はIntel PTT)である。このホストからすべてのドライブを取り外し、Rufus 4.15で作成したWindows To Go(Windows 11 Home 26H2、ビルド26300.9457、`win2go.raw`、sha256 `adef24d0…`)をUSBから起動したときに、OS起動ディスクに依存しない永続領域に起こる変更を、同等構成のVMで測定し、Windows自身のイベントログとホストの構成情報で裏付けた。あわせて、USBマスストレージからの起動と運用が成立することを確認した。

対象とした永続領域は、OSが標準インターフェイスを通じて書き込める次の5つである。

1. UEFI変数ストア(NVRAM。ブートエントリ、Secure Boot変数、OS固有変数)
2. TPMの不揮発領域
3. RTC(CMOSクロック)
4. SPIフラッシュ上のファームウェア(UEFIカプセルによる更新)
5. ブロックデバイス(本シナリオでは取り外し済み)

## 1. 結論

| 領域 | 変更の有無 | 内容 |
| --- | --- | --- |
| UEFI変数 | あり | Windows Boot Managerのブートエントリ追加と`BootOrder`先頭への配置、`SbatLevel`の引き上げ、`dbx`の拡張(ハッシュ71件追加)、`certdb`の更新、Windows固有変数12個の追加。`PK`/`KEK`/`db`は無変化 |
| TPM | あり | WindowsがTPMをクリアしたうえで再プロビジョニング。永続ハンドル3個、NVインデックス6個を作成し、ロックアウト認証値と辞書攻撃対策の閾値を変更 |
| RTC | あり | 初回起動のタイムゾーン設定時にローカル時刻(JST、UTC+9時間)で上書き |
| ファームウェア本体 | なし | カプセル更新の痕跡なし。このボードのESRT GUIDに対するWindows Updateの配布物は存在しない |
| ブロックデバイス | 対象外 | 取り外し済み。参考として、接続したままの内蔵ディスクはWindows本体の起動では無変更、回復環境に入った場合はディスク署名4バイトが書かれる |

これらの変更がこのホストに及ぼす影響は限定的である。`SbatLevel`の引き上げはホストのshim(SBAT世代4)とgrub(世代5)の要件内であり、Ubuntuの起動は阻害されない。`dbx`はfwupdで最新に保たれており、Windowsが追記する71件はすべて登録済みのため変化しない。TPMはホスト上のLinuxが使用していない(LUKSなし、tpm2-tools未導入)ため機能上の損失はないが、TPMの内容はWindowsの所有状態に書き換わる。RTCはUbuntu側の時刻同期でUTCに戻る。復旧手順は第6節に示す。

利用上の注意として、初回起動(OOBE)をVMの内蔵ディスク(SATAなど)として済ませたイメージをスティックへ書き込んでUSB起動する手順は成立しない(スティックに書き込んでUSBから初回起動する通常の手順なら該当しない)。詳細は第4.2節に示す。VMでの検証中に観測したWindowsの停止はQEMUのUSBエミュレーションに固有の事象で、実機には該当しない。その根拠と検証上の回避策は補遺(第8節)に示す。

## 2. 検証方法

| 項目 | 内容 |
| --- | --- |
| VM | QEMU 8.2.2 + libvirt、q35、OVMF 2024.02-2ubuntu0.10(`OVMF_VARS_4M.ms.fd`: Secure Boot有効、Microsoft 2011/2023 CA登録済み)、swtpm TPM 2.0、e1000e、USBコントローラはxHCI(`qemu-xhci`)。セッションC2のみEHCI(`usb-ehci`) |
| 手順 | Linuxドメイン(Ubuntu 24.04.5)を新規作成して2回起動し基準値を取得 → Linuxディスクを取り外し → win2goの作業コピーから起動 → Linuxディスクを再接続して再計測 |
| 計測点 | ホスト側: NVRAMファイル`probe_VARS.fd`を各停止時点で解析(N0〜N15)。ゲスト側: Linuxからefivars全変数、`efibootmgr`、`mokutil`、`tpm2_getcap`/`tpm2_nvreadpublic`(L1〜L4)。RTC: QEMUのRTCデバイスの`date`をホストUTCと比較。Windows側: 初回ログオン時に書き出したイベントログ、`manage-bde`、`Get-Tpm`、`bcdedit /enum firmware`など(別のUSBディスクへ出力) |
| 作業コピーの改変 | `Windows\Panther\unattend.xml`にOOBE自動化(ローカルアカウント`probe`、地域設定、プライバシー画面省略)とログ書き出しスクリプトの起動を追加。Rufusが書いた`SanPolicy=4`と`BypassNRO`は維持。セッションA/A2では第8.3節のunattend側の回避策を追加 |
| 対照 | Linux連続起動間の差分(雑音)は`MTC`カウンタのみ。Ubuntu自身の初回起動はshimによる`Ubuntu`エントリと`SbatLevel`の作成、`secureboot-db`によるdbx更新(76 → 17912バイト)を行う |
| ホスト情報 | DMI、`/sys/firmware/efi/esrt`、efivars、`fwupdmgr get-devices`、shim/grubのSBATセクション、`timedatectl`、`lsblk`を読み取り専用で収集 |

## 3. 領域別の結果

### 3.1 UEFI変数(NVRAM)

Windows起動セッション(27分)でホスト側NVRAMに生じた差分は次のとおりである。

| 変数 | 変化 | 根拠 |
| --- | --- | --- |
| `Boot000N` "Windows Boot Manager" | 新規作成。`BootOrder`の先頭に配置 | N2c → N3。削除後の再起動で再作成(N4 → N5、N10 → N11、N13 → N14)。Windows側`bcdedit /enum firmware`でも`displayorder`先頭が`{bootmgr}` |
| `SbatLevel` | `sbat,1,2023012900 / shim,2 / grub,3 / grub.debian,4` → `sbat,1,2025051000 / shim,4 / grub,5 / grub.debian,4 / grub.peimage,2 / grub.proxmox,2` | N2c → N3。Windows側Kernel-Bootイベント292の`FwLevel`に同じ値 |
| `dbx` | 17912 → 21348バイト(SHA-256ハッシュ71件を、所有者GUIDがMicrosoftの署名リスト1個として追記) | N2c → N3、L2 → L3の`mokutil --dbx`差分、Windows側`Get-SecureBootUEFI dbx` = 21348バイト |
| `certdb` | 空(サイズ4) → 90バイト。`CurrentPolicy`の署名者ダイジェスト1件 | N2c → N3。内容の復号は`host-facts/dbx-compare.txt` |
| 追加(BS属性のみ、OSから不可視) | `BootDebugPolicyApplied`、`BootingDeviceTypeInfo`、`ConfigCIPolicyIndiv`(48 B)、`CurrentActivePolicy`、`RevocationList`(1975 B)、`UnlockID`(32 B)、`SbatLevel` | ホスト側解析のみで観測。Linuxのefivarsには現れない |
| 追加(RT属性、OSから可視) | `CurrentPolicy`、`OfflineUniqueIDEKPub`(TPM EK公開鍵256 B)、`OfflineUniqueIDEKPubCRC`、`UnlockIDCopy`(32 B)、`PBRDevicePath`(536 B) | L2 → L3、L3 → L4 |
| `PK`、`KEK`、`db` | 無変化 | N2c → N3、L2 → L3 |

この表には、Windowsが自ら書いた変数だけを載せている。VMでWindows起動中に`Ubuntu`エントリが消えた現象は、QEMUがfw_cfgでブート順を指定したときにOVMFが一致しないエントリを削除する挙動によるもので、Windowsの書き込みではない。その根拠は、ディスクなしの空起動でも同エントリは残り、Linux起動時にはWindowsエントリが同様に削除されたことである。

ホストでは、これらの変更は次の形で現れる。現在の`BootOrder`は`0001`(ubuntu)のみで、win2go起動後はWindows Boot Managerのエントリが追加され先頭に置き換わる。USBを外した後は、そのエントリが指すパーティションGUIDが存在しないためファームウェアは次の`ubuntu`に進む。現在の`SbatLevel`は`sbat,1,2023012900 / shim,2 / grub,3 / grub.debian,4`で、Windowsの書き込みにより2025年版へ引き上げられる。ホストの`shimx64.efi`のSBATは`shim,4`、`grubx64.efi`は`grub,5`と`grub.peimage,2`であり、引き上げ後の要件を満たす。計測用Linuxはホストと同一パッケージ版(shim-signed 1.58+15.8-0ubuntu1、grub-efi-amd64-signed 1.202.5+2.12-1ubuntu7.3)で、dbx拡張と`SbatLevel`引き上げの後にSecure Boot有効のまま起動できた(L3、L4)。一方、grubのSBAT世代が4以下の起動メディア(2025年2月より前のgrub)は、以後このホストではshimに拒否される。ホストの`db`にはすでにWindows UEFI CA 2023、Microsoft UEFI CA 2023、Option ROM UEFI CA 2023が登録済み(fwupd)で、`KEK`にもKEK CA 2023があるため、WindowsによるCAの追加登録は発生しない。

`dbx`へのWindowsの追記は、fwupdで`dbx`を最新に保っているホストでは変化を生じない。Windowsが書く内容はUEFI Forumが配布するSecure Boot改訂リストに含まれるハッシュであり、LinuxではfwupdがLVFSの「UEFI dbx」更新として同じリストを`dbx`に適用する。UEFI仕様のSetVariable()はEFI_SIGNATURE_LIST形式の変数への追記で既存のEFI_SIGNATURE_DATAを重複して追加しないことを要求しているため、fwupd側のリストがWindows同梱のリスト以上に新しければ、Windowsの更新で追加されるエントリはない。Windows同梱のリストのほうが新しい場合に限り、その差分が追記される。VMでもこの挙動を観測した。71件を追記済みのNVRAMに対して、後続のWindowsセッションも同じdbx更新を適用した(セッション7とAのTPM-WMIイベント1034「セキュア ブート Dbx 更新プログラムが正常に適用されました」)が、`dbx`は21348バイトのまま変わらなかった(N3〜N15)。

このホストはその条件を満たしている。Windowsが追記した71件はすべて現在の`dbx`(445件)に含まれる。445件は出荷時の`dbxDefault`(431件。fwupdはLVFSの改訂リスト20250902と識別する)と、fwupdが2026-10-19に改訂リスト20260707を適用して追記した14件から成り、71件のうち57件は前者に、14件は後者に含まれる。`secureboot-db`パッケージ(371件)の内容も出荷時の431件に含まれており、同サービスはこのホストで追記を行っていない(ジャーナルに挿入の記録がない)。

`certdb`はfwupdの更新対象ではなく、Windowsが`CurrentPolicy`を初めて書くときに、fwupdの状態と無関係に変化する。`certdb`はEDK2系ファームウェアの内部変数で、PK、KEK、db、dbx以外の時刻ベース認証付き変数について署名者のダイジェストを記録する。更新するのはファームウェアだけで、OSからの書き込みは拒否する。VMでの90バイトへの変化は、Windows Boot ManagerがMicrosoft署名の認証付き変数`CurrentPolicy`(タイムスタンプ2016-09-14)を新規作成した際に、ファームウェアがその署名者のダイジェスト(32バイト)を1件記録したものである。この記録の効果は、以後`CurrentPolicy`を更新できる署名者を同一のものに限定することにとどまり、起動イメージの検証には関与しない。ホストのファームウェアでは、efivarsに`certdb`が存在しない。EDK2の`certdb`はRT属性を持ちLinuxから見えるので、ホストのファームウェアは同名の仕組みを持たないか、OSから見えない形で保持している。どちらの場合でも、ホストで生じうる変化は`CurrentPolicy`の署名者記録1件である。

### 3.2 TPM

WindowsはTPMをクリアしたうえで所有権を取得する。Windows側SystemログのTPM-WMIイベント519「TPMがクリアされました。理由: SRK Pub not present or empty.」(22:09:49)と、直後のイベント1282(TBSデバイス識別子の生成)が記録されている。`Get-Tpm`は`TpmOwned: True`、`AutoProvisioning: Enabled`、`LockoutMax: 31`、`LockoutHealTime: 10 minutes`を示す。

Linuxゲストから計測したTPM状態の変化は次のとおりである。

| 項目 | 変化前 | 変化後 |
| --- | --- | --- |
| 永続ハンドル | `0x81010001`、`0x81010016`(EK、ファームウェア側で作成) | 左記に加え`0x81000001`(SRK)、`0x81000002`、`0x81000009` |
| NVインデックス | なし | `0x1410001`〜`0x1410003`(カウンタ、各8 B)、`0x1800100`(8 B)、`0x1880001`(8 B、ポリシー保護)、`0x1880011`(32 B) |
| `lockoutAuthSet` | 0 | 1 |
| `ownerAuthSet` / `endorsementAuthSet` | 0 / 0 | 0 / 0 |
| 最大認証失敗回数 / ロックアウト間隔 / 復旧間隔 | 3 / 1000秒 / 1000秒 | 31 / 600秒 / 86400秒 |

ホストのTPMはIntel PTT(CSME内のファームウェアTPM)で、不揮発データはSPIフラッシュのME領域に保持されるため、上記の変更はそこに書き込まれる。TPM 2.0の仕様上、クリアと所有権取得の結果(所有者階層の消去、SRKとNVの作成、ロックアウト認証値の設定)は実装に依存しない。クリアにより所有者階層の既存オブジェクトとNVインデックスは消去されるが、ホストのLinuxはTPMを使用していない(dm-crypt/LUKSボリュームなし、tpm2-tools未導入、`systemd-tpm2-setup`はstatic)ため、機能上の影響はない。ファームウェアが作成したEKはplatform階層で永続化されており、VMの計測でもクリア後に残存した。

### 3.3 RTC

QEMUのRTCデバイスの値をホストUTCと比較した結果、初回起動では差0時間から、起動1.5分後(specializeパスでのタイムゾーン設定時点)に+9.00時間へ書き換えられた(セッション3、6、7、Aで再現)。Windows側ではKernel-Generalイベント25が`RealTimeIsUniversal=False`、Time-Serviceイベント52が「32399秒のオフセットで時刻を設定」、Kernel-Bootイベント238の`EfiTime`がJST相当の値を示し、RTCをUTCとして読んだ後にローカル時刻へ書き戻したことと一致する。タイムゾーンが設定済みの2回目以降の起動では、起動後10分の観測でRTCの書き換えは発生しなかった(セッションA2)。

ホストは`RTC in local TZ: no`(UTC運用)である。win2goの初回起動後にUbuntuを起動すると、同期前の時刻が9時間進んだ状態になり、systemd-timesyncdの同期後にカーネルがRTCをUTCで書き戻す。

### 3.4 ファームウェア本体(UEFIカプセルによる更新)

Windowsがファームウェアを書き換える手順は、ESRTに登録されたデバイスに対してWindows Updateがカプセルを配布し、`OsIndications`変数を設定して再起動時に適用するものである。VMでは、`OsIndications`変数の作成なし、ESPに`EFI\UpdateCapsule`なし、Windows側のPnPデバイス一覧にFirmwareクラスなしを確認した。

ホストのESRTには2エントリがあり、fwupdが示すGUIDはSystem Firmware `67fb6ccf-64fc-5ba2-ae5a-7927e1b8d083`とUEFI Device Firmware `ee85a886-1ed7-d62e-0fc1-9d6ccc9677eb`である。Microsoft Updateカタログをこの2つのGUIDで検索した結果はいずれも「該当なし」で、Windows Updateがこのボードに配布するファームウェアは存在しない。`OsIndicationsSupported`は`0x1b`(FMPカプセル対応、ファイル経由のカプセル配送は非対応)であり、配布物が存在しない以上、この手順でSPIフラッシュは書き換わらない。MSIのBIOS更新は同社のツール(M-Flashなど)による手動操作で、Windowsの起動だけでは発生しない。

### 3.5 ブロックデバイス

本シナリオでは全ドライブを取り外すため対象外である。参考として、512 MiBのNTFSイメージをSATA内蔵ディスクとして同時接続した計測では、Windows本体が起動した3セッションで書き込み0バイト、ハッシュ一致であり、Rufusの`SanPolicy=4`(OfflineInternal)が内蔵ディスクをオフラインに保つ。起動に失敗して回復環境(WinRE)に入ったセッションでは、オフセット0x1B8に4バイトのMBRディスク署名が書き込まれた。unattendのSanPolicyはWinREには適用されない。

## 4. USBマスストレージからの起動と運用の確認

### 4.1 確認結果

| セッション | 構成 | 結果 |
| --- | --- | --- |
| C2 | EHCI(USB 2.0) + USBマスストレージ(removable)、Rufus既定のunattend(デバイス暗号化は自動で開始)、初回起動 | OOBE完了、再起動を経て起動69分後に初回ログオン、75分後にデスクトップ到達。その後もGUIが応答(表示の省電力からマウス操作で復帰、タスクバーの時計が現在時刻)。Windows側Systemログのdiskイベント51/153は0件、`manage-bde -status`は初回ログオン時点で変換72.4%。暗号化変換の書き込みは2時間にわたり停止なく継続(累計22.7 GB)し、起動ディスクへのコマンドタイムアウトとポートリセット(起動・再起動時のデバイス列挙を除く)は0件。ACPIシャットダウンは完了せず強制停止(第8.3節) |
| A | xHCI + USBマスストレージ(removable)、初回起動。第8.3節のunattend側の回避策を適用 | OOBE完了、起動9分後にデスクトップ到達。その後8分間GUIが応答(スタートメニュー開閉、時計進行、ウィジェットの天気取得)。ACPIシャットダウン15秒で完了 |
| A2 | 同上、2回目のコールドブート | 起動1.3分後にデスクトップ到達。10分後もGUIが応答。ACPIシャットダウン15秒で完了 |

Windows側ログ(セッションA)で、起動ディスクは`BusType: USB`、`IsBoot: True`である。C2はRufusが書いたイメージをOOBE自動化以外改変せずにUSBマスストレージから起動して運用に至った例であり、xHCIのセッションで観測した停止がUSB起動や自動暗号化そのものに由来しないことを示す(第8節)。

### 4.2 初回起動後にストレージ接続の種別(USBマスストレージと内蔵ディスク)を変えない

VMでSATA内蔵ディスクとしてOOBEを完了したコピーをUSBマスストレージとして起動したセッション8、およびUSBマスストレージとしてOOBEを完了したコピーをSATA内蔵ディスクとして起動したセッション5は、いずれもWindowsの起動に失敗して自動修復画面に至った。OOBEのspecializeパスで、起動に不可欠なドライバ構成(USBマスストレージならusbstor、SATAならstorahci)が初回起動時の接続種別に合わせて確定するためである。

実機では、`win2go.raw`をそのままスティックに書き込み、実機のUSBポートから初回起動する通常の手順なら、この問題は起こらない。問題になるのは、VMに内蔵ディスク(SATA、virtioなど)として接続して初回起動を済ませたイメージをスティックへ書き込む手順である。VMで事前に初回起動まで済ませたい場合は、本調査のセッションAのようにUSBマスストレージとして接続して行う。

## 5. win2goメディア自体への変更(付記)

ホストの永続領域ではないが、同時に確認した事実を記す。Rufus既定のままでは、Windows 11 HomeはOOBE中にOSボリュームへデバイス暗号化を自動適用する。Windows側BitLocker管理ログのイベント4146「Device Encryption initialized automatically for volume C:」、768「encryption was started … XTS-AES 128」、796「software-based encryption」(22:09:40〜44)と、`manage-bde -status`の「変換状態: 暗号化を実行中です(75.3%)、保護状態: 保護はオフです、キーの保護機能: 見つかりません」がこれを示す。ホスト側でも`blkid`がパーティション3を`BitLocker`と判定し、`cryptsetup bitlkDump`はVMKがクリアキー保護であることを示した。この暗号化がWindows To Goメディアにとって持つ意味は第8.4節で扱う。

## 6. ホストでの復旧手順

win2go起動後にホストへドライブを戻した際、元の状態に戻すために必要な操作は次のとおりである。

| 領域 | 操作 |
| --- | --- |
| ブートエントリ | Ubuntuで`efibootmgr -v`によりWindows Boot Managerのエントリ番号を確認し、`sudo efibootmgr -b <番号> -B`で削除、`sudo efibootmgr -o 0001`で順序を戻す |
| `SbatLevel` | Secure Boot有効のままでは下げられない。ホストのshim/grubは要件を満たすため操作不要 |
| `dbx` | ホストでは変化しない(第3.1節)。操作不要 |
| Windows固有変数 | RT属性のものはUbuntuから`chattr -i`の後に削除可能。BS属性のみのもの(合計約2.2 KB)はOSから操作できず残る。動作への影響はない |
| TPM | ロックアウト認証値をWindowsが保持するため、Linuxから`tpm2_clear`は実行できない。ファームウェア設定のTPMクリア、またはPPI(`echo 5 | sudo tee /sys/class/tpm/tpm0/ppi/request`の後に再起動して確認)で初期化する |
| RTC | 時刻同期後に自動でUTCに戻る。即時に戻す場合は`sudo hwclock --systohc --utc` |

## 7. 根拠データの所在(`probe/measure/`)

- `N*-vars.txt`、`N*-vars-verbose.txt`、`N*-nvram.sha256`: ホスト側NVRAMの各時点の解析結果とハッシュ(N0初期、N2c Windows起動直前、N3セッション1後、N15最終)
- `L1`〜`L4/`: Linuxゲストからの計測(efivars一覧、`efibootmgr`、`mokutil`、TPM)
- `diff-L2-L3.txt`、`diff-L3-L4.txt`、`SUMMARY.txt`: 差分
- `rtc-s3.log`、`rtc-s6.log`、`rtc-s7.log`、`rtc-sA.log`: RTC計測
- `win7/20261107-220951-firstlogon/`: SATAセッション7のWindows側書き出し(`manage-bde-status.txt`、`get-tpm.txt`、`bcdedit-firmware.txt`、`secureboot-vars.txt`、`pnp-firmware-class.txt`、`bitlocker-management.txt`など)。`parsed-system-tpm.txt`、`parsed-system-kernel.txt`、`parsed-kernel-boot-op.txt`はイベントログの抽出結果
- `winA/20261107-224045-firstlogon/`: USBセッションAのWindows側書き出し(`system-storage.utf8.txt`にdiskイベント51/153、`manage-bde-status.txt`、`disks.txt`)
- `winC1/20261109-104924-firstlogon/`、`winC2/20261109-115905-firstlogon/`: 補遺のセッションC1、C2のWindows側書き出し(diskイベント、`manage-bde-status.txt`、`disks.txt`)
- `host-facts/`: ホストのDMI、ESRT、efivars、SBATセクション、fwupdデバイス一覧と更新履歴(`fwupd-history.txt`)、`dbx`の内容比較(`dbx-compare.txt`)、`secureboot-db`サービスの出力、Microsoft Updateカタログ検索結果(`catalog-*.html`)、計測用Linuxのパッケージ版
- `win-tpm-wmi-events.txt`: セッション7とAのTPM-WMIイベント(dbx更新適用のイベント1034を含む)
- `iostat-s9.jsonl`、`iostat-c1.jsonl`、`iostat-c2.jsonl`: 補遺のセッションのホスト側ブロック統計(30秒間隔)
- `usbtrace/`: 補遺のQEMU USBトレースと解析結果(`s9-usb-trace.log`、`c1-port1-resets-context.txt`、`c1-reset1-bootdisk-window.txt`、`c1-xfer-before-resets.txt`、`c1-stall-summary.txt`、`c1-windows-side-summary.txt`、`c2-ehci-resets.txt`、`c2-windows-side-summary.txt`、`c2-write-rate.txt`、`c2-shutdown-resets-context.txt`、`c2-shutdown-io-and-cpu.txt`)。全量トレースは`s9-usb-trace.log`、`c1-usb-trace.log`、`c2-usb-trace.log`
- `intdisk*-*.sha256`、`intdisk-inspect.log`: 内蔵ディスク試験
- `shot-loop-*.log`: 画面記録の時系列(各時刻の色数。`sA`、`sA2`がUSB起動の確認、`s9`、`c1`、`c2`が補遺のセッション)
- `../unattend-for-stick.xml`(`probe/`直下): 第8.3節の回避策を含むunattend.xml

## 8. 補遺: VMで観測したWindowsの停止とその扱い

### 8.1 観測した問題

Rufus既定のunattend(`SanPolicy=4`と`BypassNRO`のみ)でUSBマスストレージ(xHCI)から初回起動したセッション1、3、4、9、C1は、いずれも起動後5〜7分でGUIが静止し、ACPIシャットダウン要求に4分以上応答しなかった。SATA接続で同じイメージを起動したセッション6、7では発生しなかった。

ホスト側のブロック統計(セッション9、C1)では、停止は徐々に遅くなる経過ではなく突然のI/O消失として現れる。起動ディスクへの書き込みは停止直前の3分間で約5.6 GBあり、QEMUのブロック層での書き込み完了時間は平均0.2 ms、フラッシュ要求は1回で、ブロック層に未完了I/Oは残っていない。停止後はゲストのCPU使用量が0.08コア相当に落ち、以後26分間(セッション9)、起動ディスクへの読み書き要求は発生しなかった。QEMUのUSBトレースでは、停止後もエミュレートされたUSBディスクはWindowsが毎秒発行するTEST UNIT READYに正常応答しており、マウス操作で画面の電源管理も復帰する。したがって停止はデバイス側の応答不能ではなく、Windowsのストレージスタックが起動ディスクへのI/O発行をやめた状態である。

停止に先立つ共通の経過は、起動ディスクに対するコマンドタイムアウトとUSBポートリセットの反復である。C1では起動後1.3分から停止直前の10:51:12まで、約20秒から1分の間隔で25回のポートリセットが記録され、Windows側Systemログにはdiskイベント153(I/O再試行)6件とイベント51(ページング操作中のエラー)47件が残っている。イベント153の記録時刻6件のうち5件(10:45:32、10:45:53、10:46:46、10:47:49、10:49:19)は、トレース上のポートリセット時刻と秒単位で一致する。この反復がデバイス暗号化の変換書き込み(使用済み領域約15 GB。C1の初回ログオン時点で74.0%)と重なった後に、Windowsは起動ディスクへのI/O発行を停止した。暗号化を抑止した以外は同一構成のセッションA/A2では、同種のイベント51が161回および153が18回記録されたにもかかわらず停止は起こらなかった。

### 8.2 実機では起こり得ない根拠

タイムアウトの発生点は、エミュレートされたUSBデバイスの内部にある。C1のトレース(usb-storageとxHCIの全転送イベント)で各ポートリセットの直前を確認すると、起動ディスクへの読み出しコマンドはコマンド送信とデータ転送まで正常に完了した後、ステータス応答の読み取り要求がデバイス内で保留のまま完了していない。Windowsはこの要求を20秒後にタイムアウトと判定してポートリセットを行い、コマンドを再発行する。この間、QEMUのブロック層には未完了I/Oがなく、ディスクイメージはNVMe上のファイルで、ホスト側の処理遅延は介在しない。つまりこれはUSBマスストレージのプロトコル状態処理の不具合であり、ストレージの転送速度や応答性に依存して起こる事象ではない。

実機のUSBスティックとUSBホストコントローラには、このエミュレーション処理に相当するものがない。実機で同じ経過に入るには、スティック自体がWindowsのコマンドタイムアウトを超えて応答を返さない状態を、暗号化変換の間に何度も繰り返す必要がある。これは故障品の挙動であり、正常な製品の動作条件ではない。対照のセッションC2がこれを裏付ける。USBコントローラのエミュレーションをEHCI(USB 2.0)に替えた以外はセッション9、C1と同一の条件(同じイメージ、Rufus既定のunattend、usb-storageデバイス、自動暗号化あり)で、コマンドのタイムアウトとポートリセット(起動・再起動時のデバイス列挙を除く)は0件のまま、OOBEを完了してデスクトップに到達し、暗号化変換の書き込みは停止なく進行した。Windows側Systemログのdiskイベント51と153は0件(C1では47件と6件)で、初回ログオン時点の変換率は72.4%(C1は74.0%)と同じ段階にある。変換の書き込みはその後も2時間にわたり続き(累計22.7 GB)、xHCIのセッションが停止した書き込み量(7.4〜8.4 GB)の3倍近くに達しても停止は起きなかった。停止を分けたのはUSB起動でも暗号化でもなく、xHCIエミュレーション上で起きていたタイムアウトの反復である。

### 8.3 検証上の回避策

VMでUSBマスストレージ起動を確認する際の回避策は、USBコントローラをEHCI(USB 2.0)エミュレーションにすることである。libvirtでは`<controller type='usb' model='ehci'/>`を指定する。OVMFとWindowsの双方がEHCI配下のUSBマスストレージから起動でき、イメージには手を加えずに済む。代償は転送速度で、EHCIエミュレーションではOOBEと暗号化変換にxHCIの数倍の時間がかかる(C2ではデスクトップ到達まで75分。xHCIのセッションAでは9分)。C2ではACPIシャットダウンも完了しなかった。表示の省電力中に出した1回目の要求は表示の復帰にとどまり、2回目の要求の約1分後、起動ディスクへのコマンドがすべて完了した状態でWindowsがポートリセットを3回行い、その後は4基のvCPUが100%のまま画面とI/Oが停止したため強制停止した。QEMU側に未処理のコマンドはなく、xHCIで観測したステータス応答の保留とは別の事象である。起動から終了までの一巡をVMで確認する用途では、次のunattend側の回避策を用いる(セッションA/A2はACPIシャットダウンが15秒で完了)。

イメージ側で対処する場合は、停止の引き金となる変換書き込みを発生させなければよい。`Windows\Panther\unattend.xml`のoobeSystemパスに`Microsoft-Windows-SecureStartup-FilterDriver`の`PreventDeviceEncryption=true`と`Microsoft-Windows-EnhancedStorage-Adm`の`TCGSecurityActivationDisabled=1`を加えると、デバイス暗号化は開始されず(セッションAの`manage-bde -status`「BitLockerのバージョン: なし、変換状態: 暗号化は完全に解除されています」、ホスト側`blkid`の`ntfs`判定)、セッションA/A2のとおり起動と運用が成立する。`probe/unattend-for-stick.xml`はRufusが書いたunattend.xmlの内容にこの2コンポーネントを加えたもので、本調査ではNTFSボリューム(パーティション3)上の同ファイルをLinux側からudisksのループデバイスとntfs3で置き換えた。どちらの回避策もQEMUの問題を避けるためのものであり、実機でのwin2go起動に必要な手順ではない。

### 8.4 Rufusの機能としての議論の余地

Windows To Goメディアは一般にリムーバブルのフラッシュメディアに書き込まれる。Rufus既定の手順ではローカルアカウントで初回起動するため、自動で始まるデバイス暗号化はクリアキーのまま進み(第5節の`manage-bde -status`「保護状態: 保護はオフです、キーの保護機能: 見つかりません」)、データ保護にはならない。結果として残るのは、使用済み領域全体(本イメージで約15 GB)をスティックに書き直すことによるフラッシュの消耗だけである。RufusのWindows To Goダイアログにはデバイス暗号化を抑止する選択肢がないため、第8.3節の2コンポーネントを既定で加えることをRufusの機能として議論する余地はある。同趣旨の要望はRufusのissue #2877(2025-12-13、Windows To Go向けの「Disable BitLocker automatic device encryption」)として提起済みで、報告者はVMで再現できず、2026-01-11に保留(deferred)とされ、開発者は十分に検証済みのPRを求めている(2026-11-02にスレッドはロック)。本調査のセッション1、3、4、6、7、9、C1はこの自動暗号化をVMで再現しており、第8.3節の2コンポーネントで抑止できることをセッションA/A2で確認している。
