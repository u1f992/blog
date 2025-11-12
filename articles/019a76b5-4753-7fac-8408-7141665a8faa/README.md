## ThinkPad X1 Carbon Gen 12についている指紋認証デバイスをLinuxでも使う

このマシンでWindowsを使っていたころから特に使用していなかったのですが、よく考えるとキーボード上のまあまあの面積を占めるものを使わないのもどうかと思い始めました。

一般に指紋認証デバイス自体はUSBやSPIで接続されており、libfprintがその操作を取り持ちます。指紋認証を使用する際にはfprintdが常駐しており、PAM（Pluggable Authentication Modules）に`pam_fprintd.so`を追加することで、ログイン・画面ロック・sudoなどに指紋認証が統合される仕組みです。

なにか設定した覚えはありませんが、Ubuntu 24.04にはlibfprintはすでにインストールされていました。マシンに指紋認証デバイスが接続されていることを検知すると自動インストールされるのかもしれません（未確認）。

利用できる指紋認証デバイスは以下のコマンドで確認できます。

```
$ fprintd-list $(whoami)
found 1 devices
Device at /net/reactivated/Fprint/Device/0
Using device /net/reactivated/Fprint/Device/0
User mukai has no fingers enrolled for Synaptics Sensors.
```

この「Synaptics」というデバイスがそうだと考えられます。このIDはlibfprintのSupported Devicesにも掲載されており、スムーズに利用できそうです。

```
$ lsusb
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 003 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 003 Device 002: ID 06cb:0123 Synaptics, Inc.
Bus 003 Device 003: ID 30c9:005f Luxvisions Innotech Limited Integrated Camera
Bus 003 Device 004: ID 8087:0033 Intel Corp. AX211 Bluetooth
Bus 004 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 004 Device 003: ID 17ef:7205 Lenovo Thinkpad LAN
```

以下の手順で指紋を登録します。

```
$ sudo fprintd-enroll $(whoami)
Using device /net/reactivated/Fprint/Device/0
Enrolling right-index-finger finger.
Enroll result: enroll-stage-passed
Enroll result: enroll-stage-passed
Enroll result: enroll-stage-passed
Enroll result: enroll-retry-scan
Enroll result: enroll-stage-passed
Enroll result: enroll-stage-passed
...
Enroll result: enroll-completed
$ fprintd-list $(whoami)
found 1 devices
Device at /net/reactivated/Fprint/Device/0
Using device /net/reactivated/Fprint/Device/0
Fingerprints for user mukai on Synaptics Sensors (press):
 - #0: right-index-finger
```

これで再起動後のログインに指紋を使用することはできましたが、Chromeを初回起動しようとすると「コンピューターのログイン時に、ログインキーリングがロックを解除しませんでした。」という警告が表示され、（指紋不可の）パスワード入力を求められます。また、指紋認証はsudoでは使用されません。調べると、GDMでは個別に`pam_fprintd`を利用していましたが、全体では未設定でした。

```
$ grep -n 'pam_fprintd' /etc/pam.d/gdm-fingerprint
4:auth	required	pam_fprintd.so
25:password required       pam_fprintd.so
$ cat /etc/pam.d/common-auth 
#
# /etc/pam.d/common-auth - authentication settings common to all services
#
# This file is included from other service-specific PAM config files,
# and should contain a list of the authentication modules that define
# the central authentication scheme for use on the system
# (e.g., /etc/shadow, LDAP, Kerberos, etc.).  The default is to use the
# traditional Unix authentication mechanisms.
#
# As of pam 1.0.1-6, this file is managed by pam-auth-update by default.
# To take advantage of this, it is recommended that you configure any
# local modules either before or after the default block, and use
# pam-auth-update to manage selection of other modules.  See
# pam-auth-update(8) for details.

# here are the per-package modules (the "Primary" block)
auth	[success=2 default=ignore]	pam_unix.so nullok
auth	[success=1 default=ignore]	pam_sss.so use_first_pass
# here's the fallback if no module succeeds
auth	requisite			pam_deny.so
# prime the stack with a positive return value if there isn't one already;
# this avoids us returning an error just because nothing sets a success code
# since the modules above will each just jump around
auth	required			pam_permit.so
# and here are more per-package modules (the "Additional" block)
auth	optional			pam_cap.so 
# end of pam-auth-update config
```

次のコマンドで有効化します。

```
$ sudo pam-auth-update
  #「Fingerprint authentication」にチェック
$ grep -n 'pam_fprintd' /etc/pam.d/common-auth 
17:auth	[success=3 default=ignore]	pam_fprintd.so max-tries=1 timeout=10 # debug
```

これでsudoでもパスワードの代わりに指紋認証を使用可能になります。

別ターミナルウィンドウで：

```
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ sudo -i
指紋読取装置に右の人指し指を置いてください
root@mukai-ThinkPad-X1-Carbon-Gen-12:~# 
```

Chromeの問題はGNOMEキーリングの仕様ということです。うーん？

- https://gitlab.gnome.org/GNOME/gnome-keyring/-/issues/1

起動時のログインはパスワード入力で行えば、初回Chrome起動時に求められることはなくなります。意味あるのかな指紋認証これ。
