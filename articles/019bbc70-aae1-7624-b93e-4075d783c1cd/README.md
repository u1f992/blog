## SATA SSDのヘルスチェック

だいぶよさそうな価格だったので中古のSATA SSDを買ってきた。使用前にヘルスチェックをしたい。

smartctlコマンドが使える（smartmontools）SATA USB変換は[UGREEN USB 3.0 to SATA Hard Drive Adapter CM321 | P/N: 70609](https://amzn.asia/d/hCK3wJ1)　S.M.A.R.T.（Self-Monitoring, Analysis and Reporting Technology）に対応しているのが重要。

```
$ sudo smartctl -i -d sat /dev/sdf
smartctl 7.4 2023-08-01 r5530 [x86_64-linux-6.14.0-37-generic] (local build)
Copyright (C) 2002-23, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===
Model Family:     Samsung based SSDs
Device Model:     Samsung SSD 870 QVO 4TB
Serial Number:    S5STNF0W706332M
LU WWN Device Id: 5 002538 f4372dd3a
Firmware Version: SVQ02B6Q
User Capacity:    4,000,787,030,016 bytes [4.00 TB]
Sector Size:      512 bytes logical/physical
Rotation Rate:    Solid State Device
Form Factor:      2.5 inches
TRIM Command:     Available, deterministic, zeroed
Device is:        In smartctl database 7.3/5528
ATA Version is:   ACS-4 T13/BSR INCITS 529 revision 5
SATA Version is:  SATA 3.3, 6.0 Gb/s (current: 6.0 Gb/s)
Local Time is:    Wed Jan 14 20:29:05 2026 JST
SMART support is: Available - device has SMART capability.
SMART support is: Enabled

$ sudo smartctl -a -d sat /dev/sdf
smartctl 7.4 2023-08-01 r5530 [x86_64-linux-6.14.0-37-generic] (local build)
Copyright (C) 2002-23, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===
Model Family:     Samsung based SSDs
Device Model:     Samsung SSD 870 QVO 4TB
Serial Number:    S5STNF0W706332M
LU WWN Device Id: 5 002538 f4372dd3a
Firmware Version: SVQ02B6Q
User Capacity:    4,000,787,030,016 bytes [4.00 TB]
Sector Size:      512 bytes logical/physical
Rotation Rate:    Solid State Device
Form Factor:      2.5 inches
TRIM Command:     Available, deterministic, zeroed
Device is:        In smartctl database 7.3/5528
ATA Version is:   ACS-4 T13/BSR INCITS 529 revision 5
SATA Version is:  SATA 3.3, 6.0 Gb/s (current: 6.0 Gb/s)
Local Time is:    Wed Jan 14 20:29:15 2026 JST
SMART support is: Available - device has SMART capability.
SMART support is: Enabled

=== START OF READ SMART DATA SECTION ===
SMART overall-health self-assessment test result: PASSED

General SMART Values:
Offline data collection status:  (0x00)	Offline data collection activity
					was never started.
					Auto Offline Data Collection: Disabled.
Self-test execution status:      (   0)	The previous self-test routine completed
					without error or no self-test has ever 
					been run.
Total time to complete Offline 
data collection: 		(    0) seconds.
Offline data collection
capabilities: 			 (0x53) SMART execute Offline immediate.
					Auto Offline data collection on/off support.
					Suspend Offline collection upon new
					command.
					No Offline surface scan supported.
					Self-test supported.
					No Conveyance Self-test supported.
					Selective Self-test supported.
SMART capabilities:            (0x0003)	Saves SMART data before entering
					power-saving mode.
					Supports SMART auto save timer.
Error logging capability:        (0x01)	Error logging supported.
					General Purpose Logging supported.
Short self-test routine 
recommended polling time: 	 (   2) minutes.
Extended self-test routine
recommended polling time: 	 ( 320) minutes.
SCT capabilities: 	       (0x003d)	SCT Status supported.
					SCT Error Recovery Control supported.
					SCT Feature Control supported.
					SCT Data Table supported.

SMART Attributes Data Structure revision number: 1
Vendor Specific SMART Attributes with Thresholds:
ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
  5 Reallocated_Sector_Ct   0x0033   100   100   010    Pre-fail  Always       -       0
  9 Power_On_Hours          0x0032   099   099   000    Old_age   Always       -       1376
 12 Power_Cycle_Count       0x0032   099   099   000    Old_age   Always       -       195
177 Wear_Leveling_Count     0x0013   099   099   000    Pre-fail  Always       -       4
179 Used_Rsvd_Blk_Cnt_Tot   0x0013   100   100   010    Pre-fail  Always       -       0
181 Program_Fail_Cnt_Total  0x0032   100   100   010    Old_age   Always       -       0
182 Erase_Fail_Count_Total  0x0032   100   100   010    Old_age   Always       -       0
183 Runtime_Bad_Block       0x0013   100   100   010    Pre-fail  Always       -       0
187 Uncorrectable_Error_Cnt 0x0032   100   100   000    Old_age   Always       -       0
190 Airflow_Temperature_Cel 0x0032   076   047   000    Old_age   Always       -       24
195 ECC_Error_Rate          0x001a   200   200   000    Old_age   Always       -       0
199 CRC_Error_Count         0x003e   100   100   000    Old_age   Always       -       0
235 POR_Recovery_Count      0x0012   099   099   000    Old_age   Always       -       12
241 Total_LBAs_Written      0x0032   099   099   000    Old_age   Always       -       24021862977

SMART Error Log Version: 1
No Errors Logged

SMART Self-test log structure revision number 1
No self-tests have been logged.  [To run self-tests, use: smartctl -t]

SMART Selective self-test log data structure revision number 1
 SPAN  MIN_LBA  MAX_LBA  CURRENT_TEST_STATUS
    1        0        0  Not_testing
    2        0        0  Not_testing
    3        0        0  Not_testing
    4        0        0  Not_testing
    5        0        0  Not_testing
  256        0    65535  Read_scanning was never started
Selective self-test flags (0x0):
  After scanning selected spans, do NOT read-scan remainder of disk.
If Selective self-test is pending on power-up, resume after 0 minute delay.

The above only provides legacy SMART information - try 'smartctl -x' for more

```

全体的に大丈夫

```
SMART overall-health self-assessment test result: PASSED
```

Samsung SSD 870 QVO 4TBの公称保証TBW（Total Bytes Written）は1,440TB

```
241 Total_LBAs_Written      0x0032   099   099   000    Old_age   Always       -       24021862977
```

LBA（Logical Block Address）×512バイト＝12TB　かなり良好といえる
