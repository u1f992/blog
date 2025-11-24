## VDS1022(I)をLinuxで使う

ハードオフで投げ売りされていた。

[https://www.owon.com.hk/download.asp](https://www.owon.com.hk/download.asp)のFuzzy Searchに「VDS1022」と入力すると、「User Manual for VDS1022(I) PC oscilloscope」（ファイル名：VDS1022_1022I.zip）と「PC software for VDS1022(I) PC oscilloscope」（ファイル名：OWON_VDS_C2_Setup.zip）をダウンロードできる。[https://www.owon.co.jp/download.asp](https://www.owon.co.jp/download.asp)もダウンロードURLは`.com.hk`だった。Windows用のドライバしか入っていなさそうだ。

```
$ sha256sum VDS1022_1022I.zip 
bc60015341de69273fd92dad7cc3457cfdfedfefc8546763e00d1203b54bdbd9  VDS1022_1022I.zip
$ unzip VDS1022_1022I.zip -d VDS1022_1022I
$ tree VDS1022_1022I
VDS1022_1022I
└── VDS_C2_Help_EN_V1.3.5.chm

1 directory, 1 file
$ sha256sum OWON_VDS_C2_Setup.zip 
93b21291e180ec3635457e0172fe3d63f33bc189e60a6359d912b21d16534649  OWON_VDS_C2_Setup.zip
$ unzip OWON_VDS_C2_Setup.zip -d OWON_VDS_C2_Setup
$ tree OWON_VDS_C2_Setup
OWON_VDS_C2_Setup
├── VDS1022(I)-V1.1.7
│   └── OWON_VDS_C2_1.1.7_Setup.exe
└── VDS_USBDRV
    ├── USB驱动安装指南_V1.3.pdf
    ├── USBDRV
    │   ├── v2.0.txt
    │   ├── win10_win8_win7_vista
    │   │   ├── amd64
    │   │   │   ├── libusb0.dll
    │   │   │   └── libusb0.sys
    │   │   ├── devcon.exe
    │   │   ├── ia64
    │   │   │   ├── libusb0.dll
    │   │   │   └── libusb0.sys
    │   │   ├── install.bat
    │   │   ├── libusb-win32-bin-README.txt
    │   │   ├── license
    │   │   │   ├── libusb-win32
    │   │   │   │   └── installer_license.txt
    │   │   │   └── libusb0
    │   │   │       └── installer_license.txt
    │   │   ├── readme.txt
    │   │   ├── reinstall.bat
    │   │   ├── uninstall.bat
    │   │   ├── usb_device.cat
    │   │   ├── usb_device.inf
    │   │   └── x86
    │   │       ├── libusb0.sys
    │   │       └── libusb0_x86.dll
    │   └── win_xp
    │       ├── amd64
    │       │   ├── libusb0.dll
    │       │   └── libusb0.sys
    │       ├── devcon.exe
    │       ├── ia64
    │       │   ├── libusb0.dll
    │       │   └── libusb0.sys
    │       ├── install.bat
    │       ├── libusb-win32-bin-README.txt
    │       ├── license
    │       │   ├── libusb-win32
    │       │   │   └── installer_license.txt
    │       │   └── libusb0
    │       │       └── installer_license.txt
    │       ├── readme.txt
    │       ├── reinstall.bat
    │       ├── uninstall.bat
    │       ├── usb_device.cat
    │       ├── usb_device.inf
    │       └── x86
    │           ├── libusb0.sys
    │           └── libusb0_x86.dll
    └── USB_Driver_Install_Guide_V1.3.pdf

18 directories, 36 files
```

[http://owon.co.jp/products_info.asp?ProductID=6](http://owon.co.jp/products_info.asp?ProductID=6)からも同じものをダウンロードできそう（ダウンロードリンクは`.com.cn`）。

[florentbr/OWON-VDS1022](https://github.com/florentbr/OWON-VDS1022)で非公式リリースが行われており、こちらではLinuxも対応しているようだ。「This software is based on the OWON release for the VDS1022(I) 1.1.1」とある。古いリリースではLinux版もあったのだろうか？　2022年10月24日の[1.1.5-cf19](https://github.com/florentbr/OWON-VDS1022/releases/tag/1.1.5-cf19)が最終リリースで、タグはmasterの最新コミット`4c67805`に打たれている。READMEの手順に従ってインストールしてみる。

```
$ sha256sum OWON-VDS1022-1.1.5-cf19.zip 
cea92b8c279bd210076319c81eb7a21de7b6efa3e45c1c3a9aed65fdee684858  OWON-VDS1022-1.1.5-cf19.zip
$ unzip OWON-VDS1022-1.1.5-cf19.zip
$ cd OWON-VDS1022-1.1.5-cf19/
$ sudo bash install-linux.sh
...
注意、'/tmp/owon-vds-tiny-1.1.5-cf19.amd64.deb' の代わりに 'owon-vds-tiny' を選択します
以下の追加パッケージがインストールされます:
  ca-certificates-java fonts-dejavu-extra java-common libatk-wrapper-java
  libatk-wrapper-java-jni openjdk-25-jre openjdk-25-jre-headless
提案パッケージ:
  default-jre fonts-ipafont-gothic fonts-ipafont-mincho fonts-wqy-microhei
  | fonts-wqy-zenhei fonts-indic
以下のパッケージが新たにインストールされます:
  ca-certificates-java fonts-dejavu-extra java-common libatk-wrapper-java
  libatk-wrapper-java-jni openjdk-25-jre openjdk-25-jre-headless owon-vds-tiny
...
SUCCESS !
```

よさそう。

```
$ owon-vds-tiny 
env: Linux, Java 25 amd64
app dir: /opt/owon-vds-tiny
user dir: /home/mukai/.owon-vds-tiny
locale: ja_JP, ja_JP, true
WARNING: A restricted method in java.lang.System has been called
WARNING: java.lang.System::load has been called by ch.ntb.usb.LibusbJava in an unnamed module (file:/opt/owon-vds-tiny/lib/ch.ntb.usb-0.5.9.jar)
WARNING: Use --enable-native-access=ALL-UNNAMED to avoid a warning for callers in this module
WARNING: Restricted methods will be blocked in a future release unless native access is enabled

windowClosing
releaseConnect
```

Java 21以降では未命名モジュールからのJNIロードを制限・将来的には禁止するそうだ。当面は動くが、以下のようにすれば対策できる。

```
$ which owon-vds-tiny 
/usr/bin/owon-vds-tiny
$ cat /usr/bin/owon-vds-tiny 
#!/bin/bash
java -cp '/opt/owon-vds-tiny/lib/*' com.owon.vds.tiny.Main
$ sudo vim /usr/bin/owon-vds-tiny
$ cat /usr/bin/owon-vds-tiny 
#!/bin/bash
java --enable-native-access=ALL-UNNAMED -cp '/opt/owon-vds-tiny/lib/*' com.owon.vds.tiny.Main
$ owon-vds-tiny 
env: Linux, Java 25 amd64
app dir: /opt/owon-vds-tiny
user dir: /home/mukai/.owon-vds-tiny
locale: en, ja_JP, false
windowClosing
releaseConnect
```

デバイスを接続する。接続自体はうまくできていそう？

```
$ sudo dmesg
[138448.710328] usb 1-9.4: new full-speed USB device number 14 using xhci_hcd
[138448.846567] usb 1-9.4: New USB device found, idVendor=5345, idProduct=1234, bcdDevice= 1.00
[138448.846569] usb 1-9.4: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[138448.846570] usb 1-9.4: Product: ZPRO2.0
[138448.846571] usb 1-9.4: Manufacturer: ZHBI2.0
[138448.846572] usb 1-9.4: SerialNumber: VDS1022
[138448.861124] usbcore: registered new interface driver usbserial_generic
[138448.861146] usbserial: USB Serial support registered for generic
[138448.861911] usbcore: registered new interface driver usb_serial_simple
[138448.861920] usbserial: USB Serial support registered for carelink
[138448.861925] usbserial: USB Serial support registered for flashloader
[138448.861930] usbserial: USB Serial support registered for funsoft
[138448.861935] usbserial: USB Serial support registered for google
[138448.861941] usbserial: USB Serial support registered for hp4x
[138448.861948] usbserial: USB Serial support registered for kaufmann
[138448.861957] usbserial: USB Serial support registered for libtransistor
[138448.861965] usbserial: USB Serial support registered for moto_modem
[138448.861973] usbserial: USB Serial support registered for motorola_tetra
[138448.861989] usbserial: USB Serial support registered for nokia
[138448.862006] usbserial: USB Serial support registered for novatel_gps
[138448.862018] usbserial: USB Serial support registered for owon
[138448.862027] usbserial: USB Serial support registered for siemens_mpi
[138448.862035] usbserial: USB Serial support registered for suunto
[138448.862043] usbserial: USB Serial support registered for vivopay
[138448.862056] usbserial: USB Serial support registered for zio
[138448.862083] usb_serial_simple 1-9.4:1.0: owon converter detected
[138448.862208] usb 1-9.4: owon converter now attached to ttyUSB0
```

アプリを起動するとエラーが出ている。usb_serial_simpleが先に掴んでしまっているのが悪いのか。

```
$ owon-vds-tiny 
env: Linux, Java 25 amd64
app dir: /opt/owon-vds-tiny
user dir: /home/mukai/.owon-vds-tiny
locale: en, ja_JP, false
ch.ntb.usb.USBException: LibusbJava.usb_claim_interface: デバイスもしくはリソースがビジー状態です
	at com.owon.uppersoft.vds.core.usb.CDevice.open(CDevice.java:91)
	at com.owon.uppersoft.vds.core.usb.CDevice.getDevices(CDevice.java:300)
	at com.owon.uppersoft.dso.source.usb.USBSourceManager.refreshUSBPort(USBSourceManager.java:79)
	at com.owon.uppersoft.dso.source.comm.detect.USBLoopChecker.checkUSBDevice(USBLoopChecker.java:74)
	at com.owon.uppersoft.dso.source.comm.USBDaemonHelper.onNotConnecting(USBDaemonHelper.java:35)
	at com.owon.uppersoft.vds.machine.InfiniteDaemonTiny0.onNotConnecting(InfiniteDaemonTiny0.java:37)
	at com.owon.uppersoft.dso.source.comm.Flow.run(Flow.java:79)
	at com.owon.uppersoft.dso.global.ControlAppsTiny$1.run(ControlAppsTiny.java:38)
...
```

アンバインドしてから起動してみる。

```
$ ls /sys/bus/usb/drivers/usb_serial_simple
1-9.4:1.0  bind  module  uevent  unbind
$ echo '1-9.4:1.0' | sudo tee /sys/bus/usb/drivers/usb_serial_simple/unbind
$ owon-vds-tiny
...
```

これで起動した。

設定を永続化する。設定ファイルは存在するので、これに追記しておこう。

```
$ cd /sys/bus/usb/devices/1-9.4
$ cat idVendor && cat idProduct 
5345
1234
$ ls /etc/udev/rules.d/
70-owon-vds-tiny.rules          70-snap.snapd-desktop-integration.rules
70-snap.firefox.rules           70-snap.snapd.rules
70-snap.firmware-updater.rules  99-remote-media-uaccess.rules
70-snap.snap-store.rules        99-spidev.rules
$ sudo cat /etc/udev/rules.d/70-owon-vds-tiny.rules 
SUBSYSTEMS=="usb", ATTRS{idVendor}=="5345", ATTRS{idProduct}=="1234", MODE="0666"
$ echo 'SUBSYSTEMS=="usb", ATTRS{idVendor}=="5345", ATTRS{idProduct}=="1234", RUN+="/bin/sh -c '\''echo %k:1.0 > /sys/bus/usb/drivers/usb_serial_simple/unbind'\''"' | sudo tee -a /etc/udev/rules.d/70-owon-vds-tiny.rules
$ sudo cat /etc/udev/rules.d/70-owon-vds-tiny.rules 
SUBSYSTEMS=="usb", ATTRS{idVendor}=="5345", ATTRS{idProduct}=="1234", MODE="0666"
SUBSYSTEMS=="usb", ATTRS{idVendor}=="5345", ATTRS{idProduct}=="1234", RUN+="/bin/sh -c 'echo %k:1.0 > /sys/bus/usb/drivers/usb_serial_simple/unbind'"
```

デバイスを抜く。ルールをリロード。

```
$ sudo udevadm control --reload-rules
$ sudo udevadm trigger
```

差し直してログを確認。差した直後に設定通りデタッチされたと見てよさそうだ。アプリも起動できる。

```
$ sudo dmesg
[139861.948681] usb 1-9.4: new full-speed USB device number 17 using xhci_hcd
[139862.084747] usb 1-9.4: New USB device found, idVendor=5345, idProduct=1234, bcdDevice= 1.00
[139862.084750] usb 1-9.4: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[139862.084751] usb 1-9.4: Product: ZPRO2.0
[139862.084752] usb 1-9.4: Manufacturer: ZHBI2.0
[139862.084753] usb 1-9.4: SerialNumber: VDS1022
[139862.090451] usb_serial_simple 1-9.4:1.0: owon converter detected
[139862.090519] usb 1-9.4: owon converter now attached to ttyUSB0
[139862.094142] owon ttyUSB0: owon converter now disconnected from ttyUSB0
[139862.094158] usb_serial_simple 1-9.4:1.0: device disconnected
```

---

ところで、公式版には本当にLinuxバージョンは含まれていないのか？　ここまでの検証で見る限り、ドライバーはlibusbだし、アプリはJavaにみえる。改めてインストーラーを洗ってみると最新版にもかなりJavaの痕跡がある。

```
$ strings OWON_VDS_C2_1.1.7_Setup.exe | grep -i java | head -n 10
Please refer to http://java.com/license
Please refer to http://java.com/licensereadme
grant codeBase "file:${jnlpx.home}/javaws.jar" {
    permission java.security.AllPermission;
javazi
javazi
javazi
javazi
javazi
javazi
$ 7z l OWON_VDS_C2_1.1.7_Setup.exe | grep -i '\.jar'
2023-08-23 18:07:14 .....                   3430130  plugins/com.owon.vds.foundation_1.0.0.jar
2023-08-23 18:07:16 .....                    467607  plugins/com.owon.vds.tiny_1.0.31.jar
2023-08-23 18:07:18 .....                     83082  plugins/org.eclipse.core.contenttype_3.4.200.v20120523-2004.jar
2023-08-23 18:07:18 .....                     84274  plugins/org.eclipse.core.jobs_3.5.300.v20120622-204750.jar
2023-08-23 18:07:18 .....                     69464  plugins/org.eclipse.core.runtime_3.8.0.v20120521-2346.jar
2023-08-23 18:07:18 .....                     79807  plugins/org.eclipse.equinox.app_1.3.100.v20120522-1841.jar
2023-08-23 18:07:18 .....                     96589  plugins/org.eclipse.equinox.common_3.6.100.v20120522-1841.jar
2023-08-23 18:07:18 .....                     46364  plugins/org.eclipse.equinox.launcher_1.3.0.v20120522-1813.jar
2023-08-23 18:07:18 .....                    112407  plugins/org.eclipse.equinox.preferences_3.5.0.v20120522-1841.jar
2023-08-23 18:07:18 .....                    167015  plugins/org.eclipse.equinox.registry_3.5.200.v20120522-1841.jar
2023-08-23 18:07:18 .....                     68700  plugins/org.eclipse.osgi.services_3.3.100.v20120522-1822.jar
2023-08-23 18:07:18 .....                   1274766  plugins/org.eclipse.osgi_3.8.1.v20120830-144521.jar
2023-08-23 18:07:10 .....                     53068  plugins/RXTXcomm_2.1.7/RXTXcomm.jar
2023-08-23 18:07:10 .....                     50204  plugins/ch.ntb.usb_0.5.9/ch.ntb.usb-0.5.9.jar
2023-08-23 18:07:12 .....                    185074  plugins/com.google.gson_2.3.1/gson-2.3.1.jar
2023-08-23 18:07:12 .....                   1469918  plugins/com.google.gson_2.3.1/jna-5.2.0.jar
2023-08-23 18:07:12 .....                    419313  plugins/com.google.gson_2.3.1/jna-platform-4.5.2.jar
2023-08-23 18:07:10 .....                    653479  plugins/jxl_2.6.6/jxl.jar
2019-07-03 16:13:18 .....                    117206  jre/lib/alt-rt.jar
2019-07-03 16:13:18 .....                     40316  jre/lib/alt-string.jar
2019-07-03 16:13:18 .....                    908943  jre/lib/charsets.jar
2019-07-03 16:13:18 .....                    725418  jre/lib/deploy.jar
2019-07-03 16:13:18 .....                    219800  jre/lib/javaws.jar
2019-07-03 16:13:20 .....                     78970  jre/lib/jce.jar
2019-07-03 16:13:20 .....                    153730  jre/lib/jsse.jar
2019-07-03 16:13:20 .....                       236  jre/lib/management-agent.jar
2019-07-03 16:13:20 .....                    476683  jre/lib/plugin.jar
2019-07-03 16:13:20 .....                    296841  jre/lib/resources.jar
2019-07-03 16:13:20 .....                  10674050  jre/lib/rt.jar
2019-07-03 16:13:18 .....                      6656  jre/lib/ext/dnsns.jar
2019-07-03 16:13:18 .....                    277903  jre/lib/ext/localedata.jar
2019-07-03 16:13:18 .....                    153149  jre/lib/ext/sunjce_provider.jar
2013-03-08 15:55:02 .....                     31906  jre/lib/ext/sunmscapi.jar
2019-07-03 16:13:18 .....                    216467  jre/lib/ext/sunpkcs11.jar
2019-07-03 16:13:18 .....                      8176  jre/lib/im/indicim.jar
2019-07-03 16:13:18 .....                      6104  jre/lib/im/thaiim.jar
2013-03-08 15:55:02 .....                      2073  jre/lib/security/US_export_policy.jar
2013-03-08 15:55:02 .....                      2454  jre/lib/security/local_policy.jar
```

具体的な手順は書かれていないけれど、[florentbr/OWON-VDS1022](https://github.com/florentbr/OWON-VDS1022)は公式配布からJava部分を取り出して、必要なネイティブライブラリを補ったものなのだろう。確かに、少しファイルを確認するとlibusb-0.1.so.4などが含まれている。
