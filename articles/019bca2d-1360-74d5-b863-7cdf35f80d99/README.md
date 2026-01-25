## ThinkPad P52 (20MA)

中古で買った。

- バッテリー駆動可能
- M.2 NVMe SSDを2基＋SATA HDD/SSDを1基搭載できるので、システム用のディスク以外の2基でRAIDを構成可能

### 状態確認

Windows 11 Proがインストールされている。BitLockerは有効化されていない。

とりあえず初回起動チェックでバッテリーの明らかな劣化はなさそう。

コントロール パネル＞ハードウェアとサウンド＞電源ボタンの動作の変更＞現在利用可能ではない設定を変更します＞高速スタートアップを有効にする　のチェックを外して「変更の保存」をクリック。Shiftを入力しながらシャットダウンして完全シャットダウン。

バッテリーを取り外したところにあるシリアル番号をLenovoサポートに入力したが情報を得られない。Lenovoサポートページではアクセス中のマシンからシリアル番号を検出できるようになっているが、ディスクは工場出荷時状態の復元ではなく素のWindows 11をクリーンインストールされているらしく、Lenovoのツールがインストールされていない。Lenovo Service Bridgeをインストールし、シリアル番号が検出された。「PF-xxx」のうちハイフンは省いたものを入力するべきだったようだ。

OfficeがプリインストールされているのでWordを起動して確認すると、Microsoft Office Home and Business 2019がライセンス認証されている。まあ出所のわからない旧版のOfficeは、もらえたとて使わないか。

<figure>
<figcaption>Officeライセンス情報（放棄）</figcaption>

```
PS C:\Users\user> cd 'C:\Program Files (x86)\Microsoft Office\Office16\'
PS C:\Program Files (x86)\Microsoft Office\Office16> cscript .\OSPP.VBS /dstatus
Microsoft (R) Windows Script Host Version 10.0
Copyright (C) Microsoft Corporation. All rights reserved.

---Processing--------------------------
---------------------------------------
PRODUCT ID: 00404-49006-52434-AA646
SKU ID: 7fe09eef-5eed-4733-9a60-d7019df11cac
LICENSE NAME: Office 19, Office19HomeBusiness2019R_Retail edition
LICENSE DESCRIPTION: Office 19, RETAIL channel
BETA EXPIRATION: 1601/01/01
LICENSE STATUS:  ---LICENSED---
Last 5 characters of installed product key: XXXXX
---------------------------------------
---------------------------------------
---Exiting-----------------------------
```

</figure>

SATAケーブルとブラケット、2つ目のM.2スロットのSSDのネジは付属していなかった。M.2 SSDのスロットに付いていた黒いリボンは、そのままでは2枚目のSSDを取り付けられなかったので剥がした。M.2 SSDの下にあったサーマルパッドを触ったら端が少し欠けた。SATAケーブルとブラケットはAliExpressで購入、アルミ泊のテープ？も付属していたが使用していない。ネジはSSDに付属しておりちょうど使用できた。

- [取り外し、交換動画 - ThinkPad P52 (20M9, 20MA) - Lenovo Support JP](https://support.lenovo.com/jp/ja/solutions/ht508550-removal-and-replacement-videos-thinkpad-p52-20m9-20ma)

新たに搭載したディスクの状態はとりあえずよさそうだ。

<details>
<summary>CrystalDiskInfoのヘルスチェック</summary>

```
----------------------------------------------------------------------------
CrystalDiskInfo 9.7.2 (C) 2008-2025 hiyohiyo
                                Crystal Dew World: https://crystalmark.info/
----------------------------------------------------------------------------

    OS : Windows 11 Pro 25H2 [10.0 Build 26200] (x64)
  Date : 2026/01/24 18:22:22

-- Controller Map ----------------------------------------------------------
 + 標準 SATA AHCI コントローラー [ATA]
   - Samsung SSD 870 QVO 4TB
 + Microsoft 記憶域コントローラー [SCSI]
   - Microsoft Storage Space Device
 + 標準 NVM Express コントローラー [SCSI]
   - Lexar SSD NM790 4TB
 + 標準 NVM Express コントローラー [SCSI]
   - SAMSUNG MZVLB256HBHQ-000L7

-- Disk List ---------------------------------------------------------------
 (01) SAMSUNG MZVLB256HBHQ-000L7 : 256.0 GB [1/1/0, sq] - nv
 (02) Lexar SSD NM790 4TB : 4096.7 GB [0/0/0, sq] - nv
 (03) Samsung SSD 870 QVO 4TB : 4000.7 GB [2/X/X, pd1] - sg

----------------------------------------------------------------------------
 (01) SAMSUNG MZVLB256HBHQ-000L7
----------------------------------------------------------------------------
           Model : SAMSUNG MZVLB256HBHQ-000L7
        Firmware : 5M2QEXH7
   Serial Number : S4ELNF2M957597
       Disk Size : 256.0 GB
       Interface : NVM Express
        Standard : NVM Express 1.3
   Transfer Mode : PCIe 3.0 x4 | PCIe 3.0 x4
  Power On Hours : 2331 時間
  Power On Count : 1282 回
      Host Reads : 20609 GB
     Host Writes : 12957 GB
     Temperature : 31 C (87 F)
   Health Status : 正常 (97 %)
        Features : S.M.A.R.T., TRIM, VolatileWriteCache
    Drive Letter : C:

-- S.M.A.R.T. --------------------------------------------------------------
ID RawValues(6) Attribute Name
01 000000000000 クリティカルワーニング
02 000000000130 温度
03 000000000064 予備領域
04 00000000000A 予備領域 (しきい値)
05 000000000003 使用率
06 0000029383CC 総読み込み量 (ホスト)
07 0000019E9FDE 総書き込み量 (ホスト)
08 000033AC672C リードコマンド数 (ホスト)
09 00002206539D ライトコマンド数 (ホスト)
0A 00000000089C コントローラービジー時間
0B 000000000502 電源投入回数
0C 00000000091B 使用時間
0D 000000000060 アンセーフシャットダウン回数
0E 000000000000 データエラー回数
0F 0000000003D4 エラーログエントリー数
10 000000000000 警告（ワーニング）温度超過時間
11 000000000000 警告（クリティカル）温度超過時間
12 000000000130 温度センサー1
13 00000000013B 温度センサー2
1A 000000000000 設定温度1超過回数
1B 000000000000 設定温度2超過回数
1C 000000000000 設定温度1超過時間
1D 000000000000 設定温度2超過時間

-- IDENTIFY_DEVICE ---------------------------------------------------------
        0    1    2    3    4    5    6    7    8    9
000: 144D 144D 3453 4C45 464E 4D32 3539 3537 3739 2020
010: 2020 2020 4153 534D 4E55 2047 5A4D 4C56 3242 3635
020: 4248 5148 302D 3030 374C 2020 2020 2020 2020 2020
030: 2020 2020 4D35 5132 5845 3748 3802 0025 0900 0004
040: 0300 0001 0D40 0003 1200 007A 0000 0000 0000 0000
050: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
060: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
070: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
080: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
090: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
100: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
110: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
120: 0000 0000 0000 0000 0000 0000 0000 0000 0017 0307
130: 0316 043F 0101 0165 0166 0000 0000 0000 0000 0000
140: 6000 9E65 003B 0000 0000 0000 0000 0000 0000 0000
150: 0000 0000 0000 0000 0000 0000 0000 0000 0023 0000
160: 0000 0001 0141 0166 0003 0000 0000 0000 0000 0000
170: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
180: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
190: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
200: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
210: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
220: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
230: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
240: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
250: 0000 0000 0000 0000 0000 0000

-- SMART_NVME --------------------------------------------------------------
     +0 +1 +2 +3 +4 +5 +6 +7 +8 +9 +A +B +C +D +E +F
000: 00 30 01 64 0A 03 00 00 00 00 00 00 00 00 00 00
010: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
020: CC 83 93 02 00 00 00 00 00 00 00 00 00 00 00 00
030: DE 9F 9E 01 00 00 00 00 00 00 00 00 00 00 00 00
040: 2C 67 AC 33 00 00 00 00 00 00 00 00 00 00 00 00
050: 9D 53 06 22 00 00 00 00 00 00 00 00 00 00 00 00
060: 9C 08 00 00 00 00 00 00 00 00 00 00 00 00 00 00
070: 02 05 00 00 00 00 00 00 00 00 00 00 00 00 00 00
080: 1B 09 00 00 00 00 00 00 00 00 00 00 00 00 00 00
090: 60 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0A0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0B0: D4 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0C0: 00 00 00 00 00 00 00 00 30 01 3B 01 00 00 00 00
0D0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0E0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0F0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
100: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
110: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
120: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
130: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
140: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
150: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
160: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
170: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
180: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
190: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1A0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1B0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1C0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1D0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1E0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1F0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

----------------------------------------------------------------------------
 (02) Lexar SSD NM790 4TB
----------------------------------------------------------------------------
           Model : Lexar SSD NM790 4TB
        Firmware : 12237
   Serial Number : PB1601R000643P2202
       Disk Size : 4096.7 GB
       Interface : NVM Express
        Standard : NVM Express 2.0
   Transfer Mode : PCIe 3.0 x4 | PCIe 4.0 x4
  Power On Hours : 0 時間
  Power On Count : 3 回
      Host Reads : 0 GB
     Host Writes : 0 GB
     Temperature : 33 C (91 F)
   Health Status : 正常 (100 %)
        Features : S.M.A.R.T., TRIM, VolatileWriteCache
    Drive Letter : 

-- S.M.A.R.T. --------------------------------------------------------------
ID RawValues(6) Attribute Name
01 000000000000 クリティカルワーニング
02 000000000132 温度
03 000000000064 予備領域
04 00000000000A 予備領域 (しきい値)
05 000000000000 使用率
06 000000000000 総読み込み量 (ホスト)
07 000000000000 総書き込み量 (ホスト)
08 000000000028 リードコマンド数 (ホスト)
09 000000000000 ライトコマンド数 (ホスト)
0A 000000000000 コントローラービジー時間
0B 000000000003 電源投入回数
0C 000000000000 使用時間
0D 000000000002 アンセーフシャットダウン回数
0E 000000000000 データエラー回数
0F 000000000002 エラーログエントリー数
10 000000000000 警告（ワーニング）温度超過時間
11 000000000000 警告（クリティカル）温度超過時間
12 000000000132 温度センサー1
13 00000000012A 温度センサー2
1A 000000000000 設定温度1超過回数
1B 000000000000 設定温度2超過回数
1C 000000000000 設定温度1超過時間
1D 000000000000 設定温度2超過時間

-- IDENTIFY_DEVICE ---------------------------------------------------------
        0    1    2    3    4    5    6    7    8    9
000: 1D97 1D97 4250 3631 3130 3052 3030 3436 5033 3232
010: 3230 2020 654C 6178 2072 5353 2044 4D4E 3937 2030
020: 5434 2042 2020 2020 2020 2020 2020 2020 2020 2020
030: 2020 2020 3231 3332 2037 2020 5B00 CAF2 0700 0000
040: 0000 0002 A120 0007 8480 001E 0200 0000 0012 0000
050: 0000 0000 0000 0000 0000 0100 0000 0000 0000 0000
060: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
070: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
080: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
090: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
100: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
110: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
120: 0000 0000 0000 0000 0000 0000 0000 0000 0017 0302
130: 0A14 043F 0101 016B 0170 1F40 2800 0000 2800 0000
140: 6000 DCA5 03B9 0000 0000 0000 0000 0000 0000 0000
150: 0000 0000 0000 0000 0000 0000 0002 0600 001E 0101
160: 0000 0001 0175 0184 0002 4000 0140 0000 0020 0000
170: 0001 0000 0000 0000 0000 0000 0000 0000 0000 0000
180: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
190: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
200: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
210: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
220: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
230: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
240: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
250: 0000 0000 0000 0000 0000 0000

-- SMART_NVME --------------------------------------------------------------
     +0 +1 +2 +3 +4 +5 +6 +7 +8 +9 +A +B +C +D +E +F
000: 00 32 01 64 0A 00 00 00 00 00 00 00 00 00 00 00
010: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
020: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
030: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
040: 28 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
050: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
060: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
070: 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
080: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
090: 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0A0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0B0: 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0C0: 00 00 00 00 00 00 00 00 32 01 2A 01 00 00 00 00
0D0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0E0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0F0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
100: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
110: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
120: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
130: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
140: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
150: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
160: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
170: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
180: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
190: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1A0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1B0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1C0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1D0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1E0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1F0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

----------------------------------------------------------------------------
 (03) Samsung SSD 870 QVO 4TB
----------------------------------------------------------------------------
           Model : Samsung SSD 870 QVO 4TB
        Firmware : SVQ02B6Q
   Serial Number : S5STNF0W706332M
       Disk Size : 4000.7 GB (8.4/137.4/4000.7/----)
     Buffer Size : 不明
     Queue Depth : 32
    # of Sectors : 7814037168
   Rotation Rate : ---- (SSD)
       Interface : Serial ATA
   Major Version : ACS-4
   Minor Version : ACS-4 Revision 5
   Transfer Mode : SATA/600 | SATA/600
  Power On Hours : 1379 時間
  Power On Count : 196 回
     Host Writes : 11454 GB
Wear Level Count : 4
     Temperature : 29 C (84 F)
   Health Status : 正常 (99 %)
        Features : S.M.A.R.T., NCQ, TRIM, DevSleep, GPL
       APM Level : ----
       AAM Level : ----
    Drive Letter : 

-- S.M.A.R.T. --------------------------------------------------------------
ID Cur Wor Thr RawValues(6) Attribute Name
05 100 100 _10 000000000000 代替処理済のセクタ数
09 _99 _99 __0 000000000563 使用時間
0C _99 _99 __0 0000000000C4 電源投入回数
B1 _99 _99 __0 000000000004 ウェアレベリング回数
B3 100 100 _10 000000000000 使用済予備ブロック数 (トータル)
B5 100 100 _10 000000000000 書き込み失敗回数 (トータル)
B6 100 100 _10 000000000000 消去失敗回数 (トータル)
B7 100 100 _10 000000000000 ランタイム不良ブロック (トータル)
BB 100 100 __0 000000000000 訂正不可能エラー数
BE _71 _47 __0 00000000001D エアフロー温度
C3 200 200 __0 000000000000 ECC エラーレート
C7 100 100 __0 000000000000 CRC エラー数
EB _99 _99 __0 00000000000C POR 回復回数
F1 _99 _99 __0 000597D08C79 総書き込み量

-- IDENTIFY_DEVICE ---------------------------------------------------------
        0    1    2    3    4    5    6    7    8    9
000: 0040 3FFF C837 0010 0000 0000 003F 0000 0000 0000
010: 5335 5354 4E46 3057 3730 3633 3332 4D20 2020 2020
020: 0000 0000 0000 5356 5130 3242 3651 5361 6D73 756E
030: 6720 5353 4420 3837 3020 5156 4F20 3454 4220 2020
040: 2020 2020 2020 2020 2020 2020 2020 8001 4001 2F00
050: 4000 0200 0200 0007 3FFF 0010 003F FC10 00FB 0101
060: FFFF 0FFF 0000 0007 0003 0078 0078 0078 0078 4F30
070: 0000 0000 0000 0000 0000 001F 850E 00C6 056C 0060
080: 09FC 005E 746B 7D01 4163 7469 BC01 4163 407F 0002
090: 0004 0000 FFFE 0000 0000 0000 0000 0000 0000 0000
100: BEB0 D1C0 0001 0000 0000 0008 4000 0000 5002 538F
110: 4372 DD3A 0000 0000 0000 0000 0000 0000 0000 401E
120: 401C 0000 0000 0000 0000 0000 0000 0000 0029 0000
130: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
140: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
150: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
160: 0000 0000 0000 0000 0000 0000 0000 0000 0003 0001
170: 2020 2020 2020 2020 0000 0000 0000 0000 0000 0000
180: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
190: 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000
200: 0000 0000 0000 0000 0000 0000 003D 0000 0000 4000
210: 0000 0000 0000 0000 0000 0000 0000 0001 0000 0000
220: 0000 0000 11FF 0000 0000 0000 0000 0000 0000 0000
230: 0000 0000 0000 0000 0000 1400 0000 0000 0000 0000
240: 0000 0000 0000 4000 0000 0000 0000 0000 0000 0000
250: 0000 0000 0000 0000 0000 32A5

-- SMART_READ_DATA ---------------------------------------------------------
     +0 +1 +2 +3 +4 +5 +6 +7 +8 +9 +A +B +C +D +E +F
000: 01 00 05 33 00 64 64 00 00 00 00 00 00 00 09 32
010: 00 63 63 63 05 00 00 00 00 00 0C 32 00 63 63 C4
020: 00 00 00 00 00 00 B1 13 00 63 63 04 00 00 00 00
030: 00 00 B3 13 00 64 64 00 00 00 00 00 00 00 B5 32
040: 00 64 64 00 00 00 00 00 00 00 B6 32 00 64 64 00
050: 00 00 00 00 00 00 B7 13 00 64 64 00 00 00 00 00
060: 00 00 BB 32 00 64 64 00 00 00 00 00 00 00 BE 32
070: 00 47 2F 1D 00 00 00 00 00 00 C3 1A 00 C8 C8 00
080: 00 00 00 00 00 00 C7 3E 00 64 64 00 00 00 00 00
090: 00 00 EB 12 00 63 63 0C 00 00 00 00 00 00 F1 32
0A0: 00 63 63 79 8C D0 97 05 00 00 00 00 00 00 00 00
0B0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0C0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0D0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0E0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0F0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
100: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
110: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
120: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
130: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
140: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
150: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
160: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 53
170: 03 00 01 00 02 FF 00 40 01 00 00 00 00 00 00 00
180: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
190: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1A0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1B0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1C0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1D0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1E0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1F0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 8D

-- SMART_READ_THRESHOLD ----------------------------------------------------
     +0 +1 +2 +3 +4 +5 +6 +7 +8 +9 +A +B +C +D +E +F
000: 01 00 05 0A 00 00 00 00 00 00 00 00 00 00 09 00
010: 00 00 00 00 00 00 00 00 00 00 0C 00 00 00 00 00
020: 00 00 00 00 00 00 B1 00 00 00 00 00 00 00 00 00
030: 00 00 B3 0A 00 00 00 00 00 00 00 00 00 00 B5 0A
040: 00 00 00 00 00 00 00 00 00 00 B6 0A 00 00 00 00
050: 00 00 00 00 00 00 B7 0A 00 00 00 00 00 00 00 00
060: 00 00 BB 00 00 00 00 00 00 00 00 00 00 00 BE 00
070: 00 00 00 00 00 00 00 00 00 00 C3 00 00 00 00 00
080: 00 00 00 00 00 00 C7 00 00 00 00 00 00 00 00 00
090: 00 00 EB 00 00 00 00 00 00 00 00 00 00 00 F1 00
0A0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0B0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0C0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0D0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0E0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
0F0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
100: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
110: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
120: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
130: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
140: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
150: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
160: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
170: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
180: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
190: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1A0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1B0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1C0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1D0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1E0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
1F0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 4E
```

</details>

[ArchWiki](https://wiki.archlinux.org/title/Lenovo_ThinkPad_P52)がBIOSの更新に言及していたので確認。

Shift入力しながら完全シャットダウン。`To interrupt normal startup, press Enter`でEnter入力、Startup Interrupt MenuでF1を入力してBIOSに入る。

F9 Setup Defaultsでデフォルト設定をロードして、Restart > Exit Saving Changes

- [BIOS アップデート (ユーティリティ および 起動CD用) (Windows 11 64bit/ 10 64bit) - ThinkPad P52, P72 - Lenovo Support JP](https://support.lenovo.com/jp/ja/downloads/ds504024-bios-update-utility-bootable-cd-for-windows-10-64-bit-linux-thinkpad-p52-p72)

> | パッケージ | UEFI BIOS | ECP | BIOS アップデート<br>ユーティリティ (Windows) | BIOS アップデート<br>ユーティリティ (起動CD用) |
> | --- | --- | --- | --- | --- |
> | N2CUJ46W | 1.89 (N2CET76W) | 1.16 (N2CHT26W) | 現在のリリース | 現在のリリース |

```
PS C:\Users\user\Downloads> Get-FileHash -Algorithm SHA256 .\n2cuj46w.exe

Algorithm       Hash                                                                   Path
---------       ----                                                                   ----
SHA256          3F1305F385D2C6866875DE5D036A487F773A09C395AFC7F8028823EE4CF39C0A       C:\Users\user\Downloads\n2cuj...

```

指示通り進めると「BIOS image file is same as BIOS ROM. An update is not necessary at this time.」だった。

他にも何かあるかも。Lenovo Vantageをインストールする。

- https://www.lenovo.com/us/en/software/vantage
  - https://apps.microsoft.com/detail/9wzdncrfj4mv

「更新プログラムの確認」からすべて更新しておく。再起動して0件であることを確認する。

### Ubuntu Serverをインストール

Ubuntu 24.04.3 LTS

- https://ubuntu.com/download/server

```
PS C:\Users\user\Downloads> Get-FileHash -Algorithm SHA256 .\ubuntu-24.04.3-live-server-amd64.iso

Algorithm       Hash                                                                   Path
---------       ----                                                                   ----
SHA256          C3514BF0056180D09376462A7A1B4F213C1D6E8EA67FAE5C25099C6FD3D8274B       C:\Users\user\Downloads\ubunt...

PS C:\Users\user\Downloads> Get-Disk | Select Number,FriendlyName,Size

Number FriendlyName                        Size
------ ------------                        ----
     0 Lexar SSD NM790 4TB        4096805658624
     1 SAMSUNG MZVLB256HBHQ-000L7  256060514304
     3 DATA                       3991366795264
     4 KIOXIA TransMemory           15495856128
```

Git for WindowsをインストールしてGit Bashを管理者権限で起動する。

- 管理者権限でないと`dd: failed to open '/dev/sde': Permission denied`
- 単純に`/dev/sd*`で指定すると`dd: error writing '/dev/sde': Invalid request code`
- `//./PhysicalDrive4`ではない。`dd: failed to open '//./PhysicalDrive4': Is a directory`

```
user@DESKTOP-N7SSKU9 MINGW64 ~
$ dd if=/c/Users/user/Downloads/ubuntu-24.04.3-live-server-amd64.iso of="\\.\PhysicalDrive4" bs=4M status=progress
2948595712 bytes (2.9 GB, 2.7 GiB) copied, 3 s, 983 MB/s
787+1 records in
787+1 records out
3303444480 bytes (3.3 GB, 3.1 GiB) copied, 3.4151 s, 967 MB/s

user@DESKTOP-N7SSKU9 MINGW64 ~
$ sync

user@DESKTOP-N7SSKU9 MINGW64 ~
$ dd if="\\.\PhysicalDrive4" bs=4M status=none | cmp - /c/Users/user/Downloads/ubuntu-24.04.3-live-server-amd64.iso
（何も表示されなければ検証成功）
```

Shift入力しながら完全シャットダウン。`To interrupt normal startup, press Enter`でEnter入力、Startup Interrupt MenuでF1を入力してBIOSに入る。

F9 Setup Defaultsでデフォルト設定をロード。Startup > BootでUSB HDD KIOXIA TransMemoryを最上位に。Restart > Exit Saving Changes

GRUBメニューでTry or Install Ubuntu Server

```
Use UP, DOWN and ENTER keys to select your language.
  English

Keyboard configuration
  Layout: Japanese
  Variant: Japanese

Choose the type of installation
  (X) Ubuntu Server
  ( ) Ubuntu Server (minimized)

  Additional options
  [X] Search for third-party drivers

Network configuration
  enp0s31f6 eth -
  DHCPv4 192.168.0.6/24

  wlp0s20f3 wlan not connected
  disabled

Proxy configuration
  Proxy address: （空白）

Ubuntu archive mirror configuration
  Mirror address: http://jp.archive.ubuntu.com/ubuntu/

Guided storage configuration
  (X) Use an entire disk
      [ SAMSUNG_MZVLB256HBHQ-000L7_S4ELNF2M957597_1  local disk  238.474G ]
      [X] Set up this disk as an LVM group
          [ ] Encrypt the LVM group with LUKS
  ( ) Custom storage layout

SSH configuration
  [X] Install OpenSSH server

Featured server snaps
  （選択なし）

インストール終了まで待機
[ Reboot Now ]

[FAILED] Failed unmounting cdrom.mount - /cdrom
Please remove the installation medium, then press ENTER:
```

### DHCP固定割当

DHCPで割り振られた空いているアドレスを確認。インストール時に`192.168.0.6`とあったが、念の為

```
$ ip addr show enp0s31f6 
2: enp0s31f6: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether e8:6a:64:47:5a:b7 brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.6/24 metric 100 brd 192.168.0.255 scope global dynamic enp0s31f6
       valid_lft 85545sec preferred_lft 85545sec
    inet6 240f:100:d828:1:ea6a:64ff:fe47:5ab7/64 scope global dynamic mngtmpaddr noprefixroute 
       valid_lft 259sec preferred_lft 259sec
    inet6 fe80::ea6a:64ff:fe47:5ab7/64 scope link 
       valid_lft forever preferred_lft forever
```

ホームゲートウェイ詳細設定 > ここから設定/確認 > 3.LAN設定 > DHCP固定割当設定 > 追加

```
MACアドレス　e8:6a:64:47:5a:b7
IPアドレス　192.168.0.6
```

設定 > 戻る　でテーブルに追加されたことを確認したら、保存

Ubuntu Serverが既定で使用するsystemd-networkdのDHCPクライアントは、デフォルトでDUIDをClient IDに使用する（[過去のセットアップ](..//0199d804-fa2f-7925-82e1-003224f2d920/README.md)）。

```
$ sudo vim /etc/netplan/99-set-dhcp-identifier-mac.yaml

  以下の内容で新規作成
  network:
    version: 2
    ethernets:
      enp0s31f6:
        dhcp4: true
        dhcp-identifier: mac

$ systemctl reboot
```

DHCP固定割当が効いたか確認。残時間が表示されていた`valid_lft`と`preferred_lft`が`forever`になっていることがわかる。

```
$ ip addr show enp0s31f6 
2: enp0s31f6: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether e8:6a:64:47:5a:b7 brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.6/24 metric 100 brd 192.168.0.255 scope global enp0s31f6
       valid_lft forever preferred_lft forever
    inet6 240f:100:d828:1:ea6a:64ff:fe47:5ab7/64 scope global dynamic mngtmpaddr noprefixroute 
       valid_lft 283sec preferred_lft 283sec
    inet6 fe80::ea6a:64ff:fe47:5ab7/64 scope link 
       valid_lft forever preferred_lft forever
```

### SSH接続を有効化する

インストール直後はufwが起動していないので有効化。LAN内に限りSSH接続を許可

```
$ sudo ufw status
Status: inactive
$ sudo ufw enable
Firewall is active and enabled on system startup
$ sudo ufw allow from 192.168.0.0/16 to any port 22 proto tcp
Rule added
```

```
$ sudo systemctl status ssh
  ...
  Loaded: loaded (/usr/lib/systemd/system/ssh.service; disabled; preset: enabled)
  Active: inactive (dead)
  ...

$ sudo systemctl enable --now ssh
$ sudo systemctl status ssh
  ...
  Loaded: loaded (/usr/lib/systemd/system/ssh.service; enabled; preset: enabled)
  Active: active (running) since ...
  ...
```

蓋を閉じるとスリープしてしまうので無効化

```
$ grep -n 'HandleLidSwitch' /etc/systemd/logind.conf
35:#HandleLidSwitch=suspend
36:#HandleLidSwitchExternalPower=suspend
37:#HandleLidSwitchDocked=ignore
$ sudo vim /etc/systemd/logind.conf
$ grep -n 'HandleLidSwitch' /etc/systemd/logind.conf
35:HandleLidSwitch=ignore
36:HandleLidSwitchExternalPower=ignore
37:HandleLidSwitchDocked=ignore

$ systemctl reboot
```

起動を確認したあと蓋を閉じて、LAN内の他のマシンからSSH接続できることを確認。以降はSSHでセットアップできる。

### WireGuardのセットアップ

```
$ sudo apt update
$ sudo apt --yes install wireguard
$ mkdir ~/wireguard && cd ~/wireguard
$ bash
  $ umask 077
  $ wg genkey | tee thinkpad-p52_private.key | wg pubkey > thinkpad-p52_public.key
  $ wg genkey | tee client_private.key | wg pubkey > client_public.key
  $ exit

$ sudo ufw allow 51820/udp
Rule added
Rule added (v6)
$ sudo ufw allow in on wg0 to any port 22 proto tcp
Rule added
Rule added (v6)
```

WireGuardトンネル内のクライアント同士の通信を許可する

```
$ sudo ufw route allow in on wg0 out on wg0
Rule added
Rule added (v6)
$ sudo vim /etc/ufw/sysctl.conf

  以下の3行をアンコメント
  #net/ipv4/ip_forward=1
  #net/ipv6/conf/default/forwarding=1
  #net/ipv6/conf/all/forwarding=1

$ sudo vim /etc/default/ufw

  DEFAULT_FORWARD_POLICY="DROP"を"ACCEPT"に変更

$ sudo ufw reload
```

フルトンネルのためファイル先頭にIPマスカレード設定を追加

```
$ sudo cat /etc/ufw/before.rules  | head -n 7
*nat
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s 10.8.0.0/24 -o enp0s31f6 -j MASQUERADE
COMMIT

#
# rules.before
$ sudo cat /etc/ufw/before6.rules  | head -n 7
*nat
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s fd42:42:42::/64 -o enp0s31f6 -j MASQUERADE
COMMIT

#
# rules.before
```

<figure>
<figcaption>/etc/wireguard/wg0.conf</figcaption>

```
[Interface]
Address = 10.8.0.1/24, fd42:42:42::1/64
ListenPort = 51820
PrivateKey = (thinkpad-p52_private.keyの中身)

[Peer]
PublicKey = (client_public.keyの中身)
AllowedIPs = 10.8.0.2/32, fd42:42:42::2/128
```

</figure>

ルーター側でポートマッピング設定を行う。ホームゲートウェイ詳細設定 > ここから設定/確認 > 2.ネットワーク設定 > ポートマッピング設定 > 追加

```
優先度　1
LAN側ホスト　192.168.0.6
プロトコル　UDP
ポート番号　51820-51820
```

設定 > 戻る　でテーブルに追加されたことを確認したら、保存

```
$ sudo systemctl enable --now wg-quick@wg0
$ sudo systemctl reboot
```

<figure>
<figcaption>クライアント側wg0.conf例</figcaption>

```
[Interface]
Address = 10.8.0.2/24, fd42:42:42::2/64
PrivateKey = (client_private.key の中身)
DNS = 1.1.1.1

[Peer]
PublicKey = (thinkpad-p52_public.key の中身)
Endpoint = (グローバルIP):51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
```

</figure>
