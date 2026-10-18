## PCの一部アップグレード検討

### 現在の構成

- MSI ATX対応マザーボードMSI Z390-A PRO Z390-A PRO 返品種別B
  - 資料: [ユーザーマニュアル E7B98v1.2](https://download-2.msi.com/archive/mnu_exe/mb/E7B98v1.2.pdf)、[データシート](https://storage-asset.msi.com/datasheet/original/mb/global/Z390-A-PRO.pdf)、[Intel 300 Series Chipset Family PCH Datasheet Vol.1](https://cdrdv2.intel.com/v1/dl/getContent/337347)
  - 型番 MS-7B98、ATX（30.5 cm × 24.4 cm）、LGA1151、Intel Z390
  - メモリ: DDR4 DIMM ×4、デュアルチャネル、最大128GB、non-ECC unbuffered、2133 / 2400 / 2666（OCで4400まで）、XMP対応
  - 拡張スロット: PCI_E1 = PCIe 3.0 x16（CPUレーン）、PCI_E4 = PCIe 3.0 x16形状でx4動作（PCHレーン）、PCI_E2 / E3 / E5 / E6 = PCIe 3.0 x1（PCHレーン）
  - M2_1: Key M、PCIe 3.0 x4またはSATA、2242〜22110。M.2 SATAデバイス装着時はSATA2が無効
  - CNVI_1: Key E、Intel CNViモジュール専用。JUSB2と帯域共有
  - ストレージ: SATA 6Gb/s ×6、RAID 0 / 1 / 5 / 10、Intel Optane Memory対応
  - USB背面: 3.1 Gen2 Type-A ×1、Type-C ×1、3.1 Gen1 Type-A ×2、2.0 ×2。内部ヘッダ: 3.1 Gen1 ×2（4ポート分）、2.0 ×2（4ポート分）
  - LAN: Intel I219-V。オーディオ: Realtek ALC892 7.1ch
  - 映像出力: VGA、DVI-D、DisplayPort。CPU内蔵グラフィックスが必要
  - 電源コネクタ: ATX 24pin ×1、CPU 8pin ×1（CPU_PWR1）、PCIe補助 6pin ×1（PCIE_PWR1）
  - ファンヘッダ: CPU_FAN1、PUMP_FAN1、SYS_FAN1〜5（4pin、PWM / DC自動判別）
  - その他: Nuvoton NCT6797、AMI UEFI 128Mb、TPMヘッダ、Thunderboltアドオンカードヘッダ、シリアル／パラレルヘッダ
  - チップセット Z390: DMI 3.0 x4、PCIe 3.0 最大24レーン（最大16ポート）、SATA 6Gb/s 最大6、USB合計14（3.1 Gen2 最大6 / Gen1 最大10）、Intel RST、CNVi
- intel(インテル) Core i9-9900KF BOX品 [振込不可]
  - 資料: [8th and 9th Generation Intel Core Processor Families Datasheet Vol.1](https://cdrdv2.intel.com/v1/dl/getContent/337344)。SKU固有値（クロック、キャッシュ）は`lscpu`の出力
  - Coffee Lake-S Refresh、LGA1151、8コア16スレッド、ベース3.6GHz、最大5.0GHz、L3 16MB、ステッピング13（R0）
  - TDP 95W（S-Processor Line 8-Core GT0 95W）、内蔵グラフィックスなし
  - メモリ: DDR4-2666 2チャネル、2DPCでも2666、16Gbダイの32GB 2Rx8 UDIMMに対応
  - PCIe 3.0 ×16（1x16 / 2x8 / 1x8+2x4）、DMI 3.0 x4
- Noctua NH-D15 サイドフロー型CPUクーラー
  - 資料: [インフォシート](https://cdn.noctua.at/media/noctua_nh_d15_infosheet_en_web.pdf)
  - 寸法 165 × 150 × 135 mm、NF-A15 PWM ×2装着時 165 × 150 × 161 mm。重量 1000 g、ファン込み 1320 g
  - 対応ソケット: Intel LGA1851 / 1700 / 1200 / 1150 / 1151 / 1155 / 1156、AMD AM4 / AM5
  - RAMクリアランス: シングルファン 64 mm、デュアルファン 32 mm。ケースのCPUクーラークリアランスが165 mm超なら前面ファンを上げて調整可
  - ファン: NF-A15 PWM、140 × 150 × 25 mm、4pin PWM、最大1500 rpm（L.N.A.使用時 1200 rpm）、最大24.6 dB(A)、MTTF 15万時間超
  - 装着可能ファン: 120 × 120 × 25 mm、140 × 150 × 25 mm、140 × 140 × 25 mm（120 mm穴）
  - 保証6年
- Crucial CT2K32G4DFD8266 288Pin DDR4-2666 SET 1.2Volt CL19 32GB*4
  - 資料: 実装DIMMのSPD読み取り値（`/sys/bus/i2c/devices/0-005x/eeprom`）
  - 32GB UDIMM ×4、合計128GB
  - DDR4-2666、CL19-19-19-43、1.2V、non-ECC、2Rx8、Micron 16Gbダイ（4バンクグループ × 4バンク、17行 / 10列）
  - 対応CL: 10〜20（Crucial刻印）、10〜23（Micron刻印）
  - モジュール高さ 32 mm、厚さ 2 mm／面
  - 個体: CT32G4DFD8266.C16FF ×2（2022年第19週製）、Micron 16ATF4G64AZ-2G6B1 ×2（2019年第18週製）
- Western Digital ウエスタンデジタル 内蔵SSD 2TB WD Black SN7100 (読取り最大 7,250MB/秒) M.2-2280 NVMe WDS200T4X0E-EC 【国内正規代理店品】
  - 資料: [データシート（2025年7月）](https://documents.sandisk.com/content/dam/asset-library/en_us/assets/public/sandisk/product/internal-drives/wd-black-ssd/data-sheet-wd-black-sn7100-nvme-ssd.pdf)
  - 型番 WDS200T4X0E-00CJA0、M.2 2280（80 × 22 × 2.38 mm、5.8 g）
  - PCIe Gen4 x4 NVMe、DRAMレス、TLC 3D NAND
  - シーケンシャル読み 7,250 MB/s、書き 6,900 MB/s。ランダム読み 1,000K IOPS、書き 1,400K IOPS
  - 耐久 1,200 TBW、保証5年（TBW到達が先ならそこで終了）
  - 動作温度 0〜85 ℃
  - 後方互換: PCIe Gen4 x2 / x1、Gen3 x4 / x2 / x1、Gen2 x4 / x2 / x1
- MSI PCI-Express 3.0 x16対応 グラフィックスボードMSI GeForce GTX 1650 VENTUS XS 4G OC GTX 1650 VENTUS XS 4G OC 返品種別B
  - 資料: [データシート](https://storage-asset.msi.com/datasheet/original/vga/global/GeForce-GTX-1650-VENTUS-XS-4G-OC.pdf)
  - NVIDIA GeForce GTX 1650、896コア、ブースト1740 MHz
  - 4GB GDDR5、128bit、8 Gbps
  - PCIe 3.0 x16
  - 消費電力 75 W、補助電源コネクタなし、推奨電源 300 W
  - 177 × 111 × 38 mm、443 g
  - 出力: DisplayPort 1.4 ×1、HDMI 2.0b ×1、DL-DVI-D ×1、最大3画面、HDCP 2.2
- Cooler Master V750 Gold MPY-7501-AFAAGV-JP [750W/GOLD認証] フルモジュラー式 PC電源ユニット V Goldシリーズ
  - 資料: 公式製品ページ（現行サイトでは削除済み。[2025-12-08時点のアーカイブ](https://web.archive.org/web/20251208045047/https://www.coolermaster.com/en-global/products/v750-gold/)）
  - 750W、80 PLUS Gold（typical 90%）、ATX 12V、Active PFC、Half-bridge LLC + DC-DC、フルモジュラー
  - コネクタ: ATX 24pin ×1、EPS 8pin ×1、EPS 4+4pin ×1、PCIe 6+2pin ×4、SATA ×12、ペリフェラル4pin ×4、FDD ×1
  - ファン: 135 mm FDB、最大1545 rpm。セミファンレス（20%負荷 0 dBA、50% 23.6 dBA、100% 32.5 dBA）
  - 160 × 150 × 86 mm
  - 入力 100〜240 V、50〜60 Hz、10〜5 A。ホールドアップ 17 ms、Power Good 100〜500 ms、MTBF 10万時間超
  - 保護: OVP / OPP / SCP / UVP / OTP / OCP。動作温度 0〜50 ℃。保証10年
- クーラーマスター　Ｓｉｌｅｎｃｉｏ　Ｓ６００　ＭＣＳ－Ｓ６００－ＫＮ５Ｎ－Ｓ００
  - 資料: [公式製品ページ](https://www.coolermaster.com/en-global/products/silencio-s600/)
  - 型番 MCS-S600-KN5N-S00（スチールパネル版）。ミドルタワー、478 × 209 × 470.5 mm（突起含む）、44.8 L
  - 対応マザー: Mini-ITX / Micro-ATX / ATX、拡張スロット7
  - クリアランス: CPUクーラー 167 mm、グラフィックカード 398 mm、電源 180 mm。裏配線スペース 18〜26 mm
  - ドライブベイ: 5.25" ×1（ODD版）、3.5" ×4、2.5" ×5
  - ファン: 前面 120 / 140 mm ×2、天面 120 / 140 mm ×2、背面 120 mm ×1。Silencio FP 120 PWM（800〜1400 rpm）が前面・背面に各1付属
  - ラジエータ: 前面 120 / 140 / 240 / 280 mm、天面 120 / 240 mm（ODDケージ取り外し、マザー部品高35 mmまで）、背面 120 mm
  - フロントI/O: USB 3.2 Gen1 ×2、ヘッドセット端子、SD / MMCリーダー。防塵フィルタ: 前面・天面・底面
  - 電源: ボトムマウント ATX PS2
- StarTech.com USB 3.0 4ポート増設PCIeカード 4個の専用5Gbpsチャネル UASP対応 SATA(15ピン) / ペリフェラル(4ピン) 電源付き PEXUSB3S44V
  - 資料: [データシート](https://media.startech.com/cms/pdfs/pexusb3s44v_datasheet.pdf)
  - PCIe 2.0 x4（x4以上のスロットが必要）
  - Renesas uPD720202 ×4、ポートごとに独立コントローラ、各5Gbps、合計20Gbps。UASP対応
  - 実装: PCIeスイッチ Pericom PI7C9X2G608GP の配下に uPD720202 ×4（`lspci`で確認）
  - USB-A ×4（4.5W）。補助電源 SATA 15pin または LP4、ポートあたり900 mA。USB BC 1.2（Apple Modeのみ）
  - 167 × 56 × 120 mm、92 g。標準ブラケット＋ロープロファイルブラケット付属。動作温度 0〜50 ℃。保証2年
- ＴＰＬＩＮＫ　Ａｒｃｈｅｒ　無線ＬＡＮ子機　［ａｘ／ａｃ／ｎ／ａ／ｇ／ｂ］　ＴＸ３０００Ｅ
  - 資料: [データシート](https://static.tp-link.com/2019/201912/20191220/Archer%20TX3000E%28UN%29_1.0%20Datasheet.pdf)
  - Wi-Fi 6 AX3000: 5GHz 2402 Mbps（11ax、160MHz）、2.4GHz 574 Mbps。11ac 1733 Mbps。2×2、1024-QAM、MU-MIMO、WPA3
  - チップ: Intel Wi-Fi 6（PCI ID 8086:2723 = AX200）
  - Bluetooth 5.0、USB 2.0（マザーのUSB 2.0ヘッダへ付属ケーブルで接続）
  - インタフェース PCIe x1（x1 / x4 / x8スロット）
  - 95.2 × 120.8 × 21.5 mm、ロープロファイルブラケット付属
  - アンテナ: 5 dBi ×2、マグネット台座、1 m RFケーブル
  - 送信出力 5GHz 28 dBm（FCC）/ 23 dBm（CE）EIRP、2.4GHz 24 / 20 dBm。動作温度 0〜40 ℃

### 要件

1. CPUの世代を更新したい。グラフィック内蔵が前提　仮：Core i9-14900KS
2. ある程度性能に制限が生じても、できるだけ部品は使いまわして安価にしたい。特にメモリは現状値上がりが激しくDDR5で128GBと同等の調達は現実的ではない
   - メモリの市場価格が後日下がった時点での更新の余地は残したい
3. dGPUの互換は問わない
4. ネットワークは有線を使用できればWi-Fiの互換は問わない
5. Ubuntu 26.04の動作が前提。まず問題ないとは思うが、極端に困難な構成は避けたい
6. USB拡張はフル機能で使用。これを実現できる構成を前提に、dGPUを接続する場合のトレードオフを明示する

### 更新表

要件1と要件2を同時に満たすソケットはLGA1700（Core第12〜14世代）になる。Intelの現行ソケットLGA1851とAMDのAM5はDDR5専用で、DDR4を使えるIntelのソケットはLGA1700が最後になるためだ。AMDのAM4もDDR4で128GBを載せられ、Ryzen 5000G系（5700Gなど）は内蔵GPUを持つが、Zen 3の8コアでPCIe 3.0止まりのため、同じ8コアでPCIe 3.0の9900KFからの世代更新としては差が小さい。したがって交換はCPUとマザーボードに留め、残りは流用する。

| 部品 | 現行 | 判定 | 更新後と条件 |
| --- | --- | --- | --- |
| CPU | Core i9-9900KF | 交換 | Core i9-14900KS（仮）。LGA1700、UHD Graphics 770内蔵、DDR4-3200 / DDR5-5600、PBP 150W / MTP 253W、最大6.2GHz |
| マザーボード | Z390-A PRO | 交換 | LGA1700、DDR4 DIMM×4、ATX。候補: ASUS TUF GAMING B760-PLUS WIFI D4、MSI B760 GAMING PLUS WIFI DDR4 |
| メモリ | DDR4-2666 32GB×4 | 流用 | 候補ボードの上限はASUSが192GB、MSIが128GB。14900KSのDDR4定格は3200なので2666は定格内 |
| CPUクーラー | NH-D15 | 流用 | LGA1700用マウントキットNM-i17xx-MP83を追加。購入証明があればNoctuaから無償入手でき、国内販売価格は980円 |
| SSD | WD Black SN7100 | 流用 | CPU直結のM.2がPCIe 4.0 x4になり、現在のGen3上限が外れる |
| グラフィックボード | GTX 1650 | 撤去 | 内蔵グラフィックスへ移行。候補ボードの映像出力はHDMIとDisplayPortで、現行のDVI-Dはなくなる。dGPUを接続する場合の条件は「dGPUを接続する場合のトレードオフ」の節 |
| 電源 | V750 Gold | 流用 | EPS 8pinと4+4pinの2本で、候補ボードのCPU電源8pin＋4pinに適合 |
| ケース | Silencio S600 | 流用 | ATX対応、CPUクーラー高167mmでNH-D15の165mmが収まる（現状と同じ） |
| USB増設カード | PEXUSB3S44V | 流用（要件6） | GTX 1650を撤去して空いたCPU直結のx16スロットへ。PCIe 2.0 x4の全帯域が出る。dGPUを接続する場合はチップセット側のx4スロットへ移り、MSIは全帯域のまま、ASUSはx1スロットを空けた場合に限り全帯域 |
| 無線LANカード | TX3000E | 撤去（任意で流用） | 有線は候補ボードの2.5GbE（Realtek RTL8125）。流用する場合はPCIe 3.0 x1スロットとUSB 2.0ヘッダ |

#### CPU（要件1）

- 14900KSの仕様: 8P+16Eの24コア32スレッド、最大6.2GHz、L3 36MB、UHD Graphics 770（32EU、最大1.65GHz）、メモリ最大192GB（[Intel ARK 237504](https://www.intel.com/content/www/us/en/products/sku/237504/intel-core-i9-processor-14900ks-36m-cache-up-to-6-20-ghz/specifications.html)）
- 14900KSは限定品で、国内の発売価格は124,980円（[ASCII](https://ascii.jp/elem/000/004/189/4189365/)）。2026年10月12日時点で[価格.com](https://kakaku.com/item/K0001613789/)には現在価格の登録がない。代替になる14900K（[Intel ARK 236773](https://www.intel.com/content/www/us/en/products/sku/236773/intel-core-i9-processor-14900k-36m-cache-up-to-6-00-ghz/specifications.html)）との違いは次のとおりで、コア構成、L2 32MB / L3 36MB、UHD Graphics 770、DDR4-3200 / DDR5-5600、PCIeレーン、Vmin Shiftの保証延長の対象である点は共通

| 項目 | Core i9-14900KS | Core i9-14900K |
| --- | --- | --- |
| 最大ターボ（Thermal Velocity Boost） | 6.2GHz | 6.0GHz |
| Turbo Boost Max 3.0 | 5.9GHz | 5.8GHz |
| Pコア / Eコア最大ターボ | 5.7 / 4.5GHz | 5.6 / 4.4GHz |
| PBP / MTP | 150W / 253W | 125W / 253W |
| 価格.com（2026年10月12日） | 価格登録なし | 最安83,980円（[価格.com](https://kakaku.com/item/K0001577321/)） |

- 差は単コアのターボ上限200MHzとPBP 25Wで、MTPはどちらも253W。NH-D15でPL1を下げて運用する前提では、全コア持続負荷の性能はどちらも電力制限で頭打ちになり、KSの上積みは短時間の軽負荷時に限られる
- Intelは2026年にLGA1700とRaptor Lakeの継続生産を表明している（[TechPowerUp](https://www.techpowerup.com/348019/14th-gen-core-raptor-lake-will-continue-to-be-abundantly-available-says-intel)）。GIGABYTEは2026年10月9日に、2027年早期予定のLGA1700新CPU向けBIOSをB760 / H610の全モデル（DDR4版とDDR5版の両方）へ提供開始した（[GIGABYTEプレスリリース](https://www.gigabyte.com/press/news/2460)）。候補に挙げるASUSとMSIの最新BIOS（ASUSは1836、MSIは7D98vMA）の更新内容に新CPUの記載はない
- Vmin Shift不安定問題への対処として、マイクロコード0x12F以降を含むBIOSとIntel Default Settings（Performanceプロファイル: PL1=PL2=253W）で運用する。対象SKUのBOX品は保証が5年に延長されている（[Intel サポート記事 000102331](https://www.intel.com/content/www/us/en/support/articles/000102331/processors.html)）
- 候補ボードはどちらもCPUなしでBIOSを書き換える機構を持たない。ASUSは仕様ページにBIOS FlashBackの記載がなく、MSIは仕様ページの背面パネル一覧にFlash BIOS Buttonがなく、マニュアルのBIOS更新節はCPUで起動した状態で使うM-FLASHのみ
- ASUS TUF GAMING B760-PLUS WIFI D4の[BIOS履歴](https://www.asus.com/motherboards-components/motherboards/tuf-gaming/tuf-gaming-b760-plus-wifi-d4/helpdesk_bios/): CPU対応表で14900KSの対応BIOSは1205（2023年6月26日）、1402（2023年9月21日）が第14世代向けマイクロコード更新、0x12Fが1820（2025年5月27日）、最新が1836（2026年5月26日）
- MSI B760 GAMING PLUS WIFI DDR4の[BIOS履歴](https://jp.msi.com/Motherboard/B760-GAMING-PLUS-WIFI-DDR4/support): 初版7D98vM0（2024年7月22日）からCPU対応表の14900KS（B0、150W、UHD Graphics 770）と14900Kに対応、0x12Bが7D98vM4（2024年10月15日）、0x12Fが7D98vM71（ベータ、2025年5月15日）、7D98vM8（2026年4月10日）は「Update Micro Code」とのみ記載、最新が7D98vMA（2026年9月10日）
- 更新手順: 購入したボードのBIOSが古い場合は14900KSで起動してからBIOSを最新にし、その後にIntel Default Settingsを設定する。ASUSで1205未満のBIOSのため14900KSが起動しない場合は、第12・13世代のCPUを借りて更新する

#### マザーボード（要件2・要件6）

- Z790のDDR4版は国内で終売が進んでいる（[MSI PRO Z790-P DDR4](https://www.ask-corp.jp/products/msi/motherboard/intel-z790/pro-z790-p-ddr4.html)、[ASRock Z790 Pro RS/D4](https://www.ask-corp.jp/products/asrock/motherboard/intel-z790/z790-pro-rs-d4.html)、[GIGABYTE Z790 S DDR4](https://www.ark-pc.co.jp/news/article/3004577)）。2026年10月12日時点の価格.comで価格登録が残るZ790のDDR4 ATXは[ASUS TUF GAMING Z790-PLUS WIFI D4](https://kakaku.com/item/K0001481980/)（1店舗、67,280円）で、B760の2倍を超える
- 同日時点で価格登録があるB760のDDR4 ATXのうち、比較したのは[ASUS TUF GAMING B760-PLUS WIFI D4](https://kakaku.com/item/K0001506404/)（28,500円）、[ASUS PRIME B760-PLUS D4](https://kakaku.com/item/K0001506407/)（18,309円）、[MSI B760 GAMING PLUS WIFI DDR4](https://kakaku.com/item/K0001662537/)（17,980円）、[GIGABYTE B760 GAMING X DDR4 GEN5](https://kakaku.com/item/K0001693585/)（価格.com表記はB760 GAMING X D4 GEN5、14,980円）の4枚。MSI PRO B760-P DDR4 IIとPRO B760-P WIFI DDR4は価格登録がない
- B760はCPU倍率のOCができないが、電力制限は変更でき、定格ターボの6.2GHzはそのまま使える。要件2が性能制限を許容しているので、Z790を探す理由はない
- 候補は、12フェーズ級のVRMとCPU電源8pin＋4pinを持つ2枚に絞る。[PRIME B760-PLUS D4](https://www.asus.com/motherboards-components/motherboards/prime/prime-b760-plus-d4/techspec/)はCPU電源が8pin1本で、VRMは製品概要に12+2 DrMOS（60A）とあるが、その段落はAMD向けの定型文で仕様表に記載がない。[GIGABYTE B760 GAMING X DDR4 GEN5](https://www.gigabyte.com/Motherboard/B760-GAMING-X-DDR4-GEN5/sp)はCPU電源が8pin1本で、VRMは製品概要に8+1+1（60A DrMOS）とあり仕様表に記載がない。チップセット側はPCIe 3.0 x1動作のx16形状スロット2本でx4スロットがなく、USBカードはCPU直結スロット固定になるが、仕様ページはそのスロットをグラフィックカードとNVMe SSD専用としている。Q-Flash Plus（CPUなしでBIOSを更新できる機構）を持つ点は候補2枚にない利点
- 候補2枚の比較。出典はASUSが[仕様](https://www.asus.com/motherboards-components/motherboards/tuf-gaming/tuf-gaming-b760-plus-wifi-d4/techspec/)と[サポートページ](https://www.asus.com/motherboards-components/motherboards/tuf-gaming/tuf-gaming-b760-plus-wifi-d4/helpdesk_download/)、MSIが[仕様](https://www.msi.com/Motherboard/B760-GAMING-PLUS-WIFI-DDR4/Specification)と[ユーザーマニュアル](https://download.msi.com/archive/mnu_exe/mb/B760GAMINGPLUSWIFIDDR4_EN.pdf)、BIOSは各社のBIOS履歴とCPU対応表、クーラーはNoctuaのボード別互換性ページ、価格は2026年10月12日の価格.com

| 項目 | ASUS TUF GAMING B760-PLUS WIFI D4 | MSI B760 GAMING PLUS WIFI DDR4 |
| --- | --- | --- |
| VRM | 12+1 DrMOS | 12フェーズ（仕様ページの表題） |
| CPU電源 | 8pin＋4pin | 8pin（CPU_PWR1）＋4pin（CPU_PWR2） |
| メモリ | DDR4×4、最大192GB | DDR4×4、最大128GB（2DPC 2Rは4000+まで） |
| CPU直結x16スロット | PCIe 5.0 x16 | PCIe 4.0 x16（PCI_E1） |
| チップセット側x4スロット（x16形状） | PCIe 3.0 x4。x1スロット2本と帯域共有で、x1スロット使用時はx2 | PCIe 4.0 x4（PCI_E3）。仕様にもマニュアルにも共有注記なし |
| x1スロット | PCIe 3.0 x1×2 | PCIe 3.0 x1×3 |
| M.2 | 3本（すべてPCIe 4.0 x4、M.2_1はCPU直結） | 2本（PCIe 4.0 x4。M.2_2はSATAモード可で、M.2 SATA SSD使用時はSATA8が無効） |
| SATA | 4 | 4 |
| 映像出力 | HDMI、DisplayPort | HDMI 2.1、DisplayPort 1.4 |
| 有線LAN | Realtek RTL8125 2.5GbE | Realtek RTL8125BG 2.5GbE |
| 無線 | Wi-Fi 6、Bluetooth 5.2。モジュールはIntel製（仕様にベンダーの記載はないが、サポートページのドライバがIntel Wi-FiとIntel Bluetoothのみ） | Intel Wi-Fi 6E、Bluetooth 5.3（Key-Eに実装済み） |
| 内部USBヘッダ | USB 3.2 Gen 2 Type-C×1、Gen 1 19pin×1、USB 2.0×2 | USB 3.2 Gen 1 Type-C×1、Gen 1 19pin×1、USB 2.0×2 |
| CPUなしでのBIOS更新 | なし | なし |
| 14900KS対応BIOS | 1205（2023年6月26日）以降 | 初版7D98vM0（2024年7月22日）以降 |
| マイクロコード0x12F | 1820（2025年5月27日） | 7D98vM71（ベータ、2025年5月15日）。正式版の更新内容に明記なし |
| 最新BIOS | 1836（2026年5月26日） | 7D98vMA（2026年9月10日） |
| NH-D15 | 対応、制約欄は空欄 | 対応、制約欄は空欄 |
| 価格.com最安 | 28,500円 | 17,980円 |

- 要件に関わる差はチップセット側x4スロットの共有の有無と価格で、どちらもMSI側が有利。共有の有無はdGPUを接続する場合に決定的になる（次節）。ASUS側の利点であるM.2の本数、PCIe 5.0 x16、最大192GBは、今回の構成（M.2は1本、dGPUなし、DDR4 UDIMMは32GBが最大）では使わない
- 要件6のUSB増設カードはPCIe 2.0 x4で4ポート合計20Gbpsを出すため、共有のないx4レーンが要る。GTX 1650を撤去して空くCPU直結のx16スロットに挿せば、どちらのボードでも共有なしでx4動作になる。チップセット側のx4スロットを使う場合、ASUSではx1スロットを空けておく必要があり、x1スロットにTX3000Eを挿すとUSBカードがx2（10Gbps）に落ちる。MSIのPCI_E3には共有の注記がなく、x1スロットと併用できる
- SATAは現行の6ポートから4ポートに減る

#### dGPUを接続する場合のトレードオフ（要件6）

dGPUはCPU直結のx16スロットを占有するので、USB増設カードはチップセット側のx4スロットへ移る。その条件は候補ボードで異なる。スロットの並びはASUSが[ユーザーマニュアル](https://dlcdnets.asus.com/pub/ASUS/mb/LGA1700/TUF_GAMING_B760-PLUS_WIFI_D4/E21224_TUF_GAMING_B760-PLUS_WIFI_D4_UM_WEB.pdf)、MSIがユーザーマニュアルの基板図による。

| 項目 | ASUS TUF GAMING B760-PLUS WIFI D4 | MSI B760 GAMING PLUS WIFI DDR4 |
| --- | --- | --- |
| スロットの並び（上から） | PCIEX16(G5)、PCIEX1(G3)_1、PCIEX1(G3)_2、PCIEX16(G3) | PCI_E1、PCI_E2（x1）、PCI_E3（x4）、PCI_E4（x1）、PCI_E5（x1） |
| 2スロット厚のGPUが塞ぐスロット | 直下のPCIEX1(G3)_1 | 直下のPCI_E2 |
| USB増設カードの行き先 | PCIEX16(G3)（PCIe 3.0 x4） | PCI_E3（PCIe 4.0 x4） |
| USB増設カードの帯域 | x1スロット2本が空いていればx4（20Gbps）。どちらかを使うとx2（10Gbps） | x4（20Gbps）。共有注記なし |
| TX3000Eとの両立 | 両立しない（挿すとUSB増設カードがx2に落ちる） | PCI_E4またはPCI_E5に挿して両立 |
| GPUのリンク | PCIe 5.0 x16 | PCIe 4.0 x16 |

- MSIならdGPU、フル機能のUSB増設カード、TX3000Eの3枚が同時に成立する。ASUSはdGPUとフル機能のUSB増設カードまでで、無線は要件4のとおり有線で代替する
- GPUのリンクは、現行のGPUがPCIe 4.0 x16で帯域不足にならないので差が出ない。x8接続のカード（下位モデルに多い）はMSIでPCIe 4.0 x8になる
- 電源: dGPUなしの持続負荷は約330W（CPU 253W、マザーボードとメモリ30〜40W、SSD、USB増設カードの給電20W、ファン）で、V750 Goldの残りは約400W。瞬間的な電力超過の余裕を残すと、GPUは最大消費電力250W級までが目安。GPU用コネクタはPCIe 6+2pin×4で12V-2x6（12VHPWR）はないため、12V-2x6のカードは付属の変換ケーブルで接続する
- ケース: Silencio S600のGPU長は398mmまで。吸気を絞った静音ケースなので、GPUの排熱がケース内温度を上げ、NH-D15の冷却余裕をさらに削る
- Ubuntu 26.04: AMDはamdgpu、IntelはxeとIntel製Wi-Fi同様にカーネル同梱。NVIDIAはUbuntuのnvidia-driverパッケージ（独自ドライバ）を追加で入れる。要件5の「極端に困難な構成」には当たらない
- GTX 1650を戻す場合は75W、補助電源なし、PCIe 3.0 x16なので、電源とケースの制約には当たらず、上のスロット条件だけが関わる

#### CPUクーラー

- 現在の構成に書いたNH-D15の対応ソケットは現行出荷品のインフォシートの値で、Noctuaのボード別互換性ページ（[ASUS](https://www.noctua.at/en/compatibility/by-components/motherboards/asus-tuf-gaming-b760-plus-wifi-d4)、[MSI](https://www.noctua.at/en/compatibility/by-components/motherboards/msi-b760-gaming-plus-wifi-ddr4)）では、2022年1月1日より前に購入したNH-D15はLGA1700用キットが別途必要（それ以降の購入分は同梱）。手元の個体はそれより前の購入なので持たない。NM-i17xx-MP83はNoctuaが購入証明（クーラーと、LGA1700のCPUまたはマザーボード）を条件に[注文フォーム](https://noctua.at/en/nm-i17xx-mp83-order-form)で無償提供している。国内の販売価格は980円（ツクモ）
- 14900KSは360mm簡易水冷でも高負荷時に100℃前後に達する（[Guru3D](https://www.guru3d.com/review/intel-core-i914900ks-review/page-31/)）。NH-D15で253Wを持続すれば全コア負荷では温度上限でクロックが下がる。要件2が性能制限を許容しているので、PL1を下げて運用する
- 同じボード別互換性ページで、ASUS TUF GAMING B760-PLUS WIFI D4とMSI B760 GAMING PLUS WIFI DDR4のどちらもNH-D15を対応品として載せており、制約欄（最上段のPCIe x16スロットへの張り出しなど）は空欄。DIMM側はデュアルファン時のRAMクリアランス32mmに対してモジュール高さ32mmなので、現状と同じ条件になる

- 反り防止器具（コンタクトフレームまたはシムワッシャー）はNM-i17xx-MP83と併用できる。NM-i17xx-MP83はNoctua製バックプレートを純正バックプレートの上に重ね、78mmピッチのクーラー取付穴4か所で固定する（[NH-D15取付マニュアル](https://cdn.noctua.at/media/noctua_nh_d15_manual_en_web.pdf)。純正バックプレートは外さないと明記）。コンタクトフレームは純正ILM（CPU固定金具）を外し、ILMのネジ穴で純正バックプレートに固定する（[Thermalright取付ガイド](https://download.thermalright.com/manuals/LGA1700-BCFBLACK.pdf)）。穴が別なので干渉せず、取付順序はフレームとCPUが先、クーラーが後
- 反り防止器具の候補は次のとおり。いずれもIntel標準のLGA1700 ILMを前提にした汎用品でボード別の対応表はなく、MSI B760 GAMING PLUS WIFI DDR4は標準ILMのATX基板として該当する。価格は2026年10月12日時点

| 品番 | 種別 | 入手と価格 | 付属品と特徴 |
| --- | --- | --- | --- |
| LGA1700-BCF BLACK V2（型番 TR-1700-BCF BLACK V2、JAN 4571388243885） | Thermalright、アルミ削り出しフレーム。国内代理店は[ディラック](https://dirac.co.jp/lga1700-bcf/)、製品保証1年 | 価格.comに出品あり | L型ドライバー付属。ILMの元ネジで固定。V1に付属していたグリスを省いた2024年6月追加の現行モデル |
| LGA1700-BCF GRAY / RED / BLUE（JAN 0814256004596 / 0814256004602 / 0814256005227） | 同上、V1の色違い | [ツクモ](https://shop.tsukumo.co.jp/goods/0814256004596/)と[オリオスペック](https://www.oliospec.com/shopdetail/000000012313/)で税込2,178円。ツクモはGRAYが残りわずか、BLACK（JAN 0814256004589）は販売終了 | L型ドライバーとグリスTF7 2g付属。50×70×6mm、20g |
| TG-CF-i13G（EAN 4260711990748） | Thermal Grizzly（der8auer設計）、陽極酸化アルミ。第12〜14世代対応（[製品ページ](https://www.thermal-grizzly.com/en/cpu-contact-frame/s-tg-cf-i13g)、[データシート](https://www.thermal-grizzly.com/media/43/ea/2a/1708697308/TG_Datasheet_CF1314th_EN_TGU20240223.pdf)） | [Amazon.co.jp](https://www.amazon.co.jp/-/en/Intel-13th-14th-GEN/dp/B0C6B233J2)で税込6,665円 | UNCネジ4本、六角レンチ、Torx T20レンチ付属。改良版の内側形状で締付トルクの指定が不要。IHSを0.2mmまで研磨したCPUも可。フレームの下に電子部品がないことの確認を求めている |
| NM-ISW1 | Noctua純正の1mmシムワッシャー4枚。ILMを外さず、ILMの下に挟んで固定圧を下げる（[取付マニュアル](https://cdn.noctua.at/preview/media/noctua_nm_isw1_manual_all.pdf)） | NH-D15 G2に同梱。単品は国内の販売店に掲載がない（英国eBayで£5.37） | Torx T20が必要（初代NH-D15には付属しない）。最大トルク0.6Nm。標準底面のクーラーで2〜3℃の改善が典型とNoctuaが明記 |

- 保証: ディラックとThermal Grizzlyは、標準ILMの取り外しが改造にあたりマザーボードの保証が失われると明記している。NoctuaはNM-ISW1について「一般的に安全で長期の悪影響は確認されていない」としつつ、ソケットの改変は利用者の自己責任と明記している
- 効果: 初代NH-D15は標準的な底面形状で、Noctuaの見積もりは2〜3℃。[Igor's Lab](https://igorslab.de/en/cpu-temperatures-within-limits-thermal-grizzly-thermalright-jeyi-and-feng-zao-lga1700-frames-in-comparison-test/3)のThermalrightフレーム比較では純正ILM比で4〜5℃
- 選び方: 価格と入手性ではLGA1700-BCF BLACK V2、工具とトルク管理の確実性ではTG-CF-i13G、改造を避けるならNM-ISW1

#### メモリ更新の余地（要件2）

- LGA1700ではDDR4とDDR5がボード単位で排他になる。DDR5へ移る時点での交換はマザーボードとメモリだけで、CPU、クーラー、電源、ケース、SSDは引き継げる
- LGA1700のDDR5ボードには64GB DIMMに対応するものがあり（[GIGABYTE Z790 UD仕様](https://www.gigabyte.com/Motherboard/Z790-UD-rev-10/sp): 4枚で256GB。Intel公称の最大192GBを超えるボードメーカー側の対応）、2枚で128GBを組める
- DDR4とDDR5の両方のスロットを持つ[ASRock H610M Combo](https://www.tomshardware.com/pc-components/motherboards/asrock-releases-new-intel-motherboard-with-support-for-both-ddr4-and-ddr5-memory-the-h610-combo-features-both-types-of-dimm-slots-but-you-cant-mix-generations)はDDR4側が2スロットで最大64GBのため、現行の128GBを載せられない

#### Ubuntu 26.04（要件5）

- 必要なドライバはいずれもカーネル同梱で、i915（UHD 770）、r8169（Realtek RTL8125）、iwlwifi（候補ボードのIntel製Wi-Fiと、流用する場合のTX3000EのAX200）が該当する。Raptor Lakeのマイクロコードはintel-microcodeパッケージからも適用される
- 8P+16EのPコアとEコアの振り分けは、intel_pstateのITMT対応を通じてカーネルのスケジューラが行う

### 外れる部品のリセール相場（2026年10月12日時点）

交換で外れるCore i9-9900KF（R0ステッピング、SRG1A、BOX品）とZ390-A PROの売却相場。店舗買取は各店の買取上限価格で、状態や付属品で減額される。

| 店舗買取 | Core i9-9900KF BOX | Z390-A PRO |
| --- | --- | --- |
| [パソコン工房](https://www.pc-koubou.jp/kaitori/re/item_310020_id_260.html) | 12,000円 | 5,000円（[マザーボード買取価格表](https://www.pc-koubou.jp/kaitori/re/motherboard_pricelist.html)） |
| [じゃんぱら](https://www.janpara.co.jp/buy/search/detail/?ITMCODE=244231) | 37,000円（R0）、26,000円（P0）。掲載時期は不明 | 掲載なし |
| [ドスパラ](https://used.dospara.co.jp/buy/search.php?ft2=Core+i9+9900) | 23,000円。掲載時期は不明 | 掲載なし |
| [ツクモ](https://kaitori.tsukumo.co.jp/used_products/) | 8,000円 | Z390カテゴリ一律5,000円 |

| ヤフオク落札（直近180日） | Core i9-9900KF | Z390-A PRO |
| --- | --- | --- |
| 単体の動作品 | 15,000〜25,000円、中心は21,000〜22,000円 | 5,000〜8,000円、中心は6,000円前後。I/Oパネル付きで7,280円 |
| ジャンク・動作未確認 | 4,565〜15,000円 | 1,890円 |
| CPUとZ390ボードのセット | 20,500〜24,000円 | 同左 |
| 出典 | [落札一覧](https://auctions.yahoo.co.jp/closedsearch/closedsearch/core%20i9-9900kf/0/)（69件で、PC丸ごとを含む平均は27,129円） | [落札一覧](https://auctions.yahoo.co.jp/closedsearch/closedsearch/z390-a%20pro/0/)（11件で平均7,841円） |

- 個人売買ではCPUとボードを別々に売るほうが高く、合計で28,000円前後になる。セット売りは20,500〜24,000円で、単体の合計を下回る
- 店舗買取は2点合計でパソコン工房の17,000円が確実な下限。じゃんぱらとドスパラのCPU買取上限は高いが、掲載時期が不明なので持ち込み前に当日の価格を確認する
- 新規購入分（14900Kが83,980円、MSI B760 GAMING PLUS WIFI DDR4が17,980円、合計101,960円）に対する回収率は、個人売買で約27%、店舗買取で約17%

### 最終採用結果

2026年10月19日時点で組み上がった構成。値は実機の`lscpu`、`lspci`、sysfs、DIMMのSPDの読み取りによる。

| 部品 | 採用 |
| --- | --- |
| CPU | Core i9-14900K（B0ステッピング、マイクロコード0x137） |
| マザーボード | MSI B760 GAMING PLUS WIFI DDR4、BIOS 7D98vMA |
| メモリ | 流用。CT32G4DFD8266.C16FF ×2とMicron 16ATF4G64AZ-2G6B1 ×2の4枚で128GB |
| CPUクーラー | NH-D15を流用 |
| SSD | WD Black SN7100を流用。CPU直結のM.2でPCIe 4.0 x4リンク |
| グラフィックス | GTX 1650を撤去し、UHD Graphics 770（i915）。DisplayPortとHDMIの2画面 |
| 電源 | V750 Goldを流用 |
| ケース | Silencio S600を流用 |
| USB増設カード | PEXUSB3S44Vを流用。CPU直結のPCI_E1でPCIe 2.0 x4リンク、uPD720202 ×4をすべて認識 |
| 無線LANカード | TX3000Eを撤去。有線はRTL8125（r8169）、無線はオンボードのAX211（iwlwifi） |

- 電力制限はIntel Default SettingsのPerformanceプロファイル（PL1 = PL2 = 253W）
- OSはUbuntu 24.04.5 LTS（カーネル7.0.0-38-generic）。使用しているドライバはすべてカーネル同梱
