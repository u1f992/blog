## WindowsのセットアップをMSアカウントなしで行う

https://news.yahoo.co.jp/articles/f7150bdb2419ad79e8bfa1f9593074b667fa1e3c?page=2

ローカルフォルダ名をアカウント名（メールアドレスの一部らしい？）にするのを本当にやめてくれ

1. <kbd>Shift</kbd>+<kbd>F10</kbd>でコマンドプロンプトを起動
2. `oobe\BypassNRO.cmd`を実行し、再起動を待機する
3. インターネット接続なしで進める
4. 「名前を入力します」で指定する名前がホームフォルダ名になる。

### ネットワークの設定を削除（誤って繋いでしまった時のリカバリ）

```
> netsh wlan show profile
> netsh wlan delete profile name="AP_NAME"
> shutdown -r
```

インターネットに接続しないまま、回復ドライブも作成しておく（購入時のスナップショットとして）。32GB以上の～と記載されていたが32GBで作成できた。

`%USERPROFILE%\OneDrive`にデスクトップやドキュメントを配置されるのもやめてほしい。オフラインのまま、OneDriveの同期設定を解除しアンインストールしておく。

1. （不要？）タスクバーのアイコン＞「ヘルプと設定」＞「設定」＞「アカウント」＞「このPCのリンク解除」
2. タスクバーのアイコン＞「ヘルプと設定」＞「OneDriveを閉じる」＞「OneDriveを終了する」
3. 「プログラムの追加と削除」からOneDriveをアンインストール

```
TASKKILL /F /IM OneDrive.exe /T

REM このコマンドとアンインストールは違うらしい。
REM 「プログラムの追加と削除」からアンインストールしたら下記のレジストリ操作をしなくてもエクスプローラーから消えた

REM 32bit
REM %SystemRoot%\System32\OneDriveSetup.exe /uninstall

REM 64bit
%SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall

RMDIR /Q /S "%USERPROFILE%\OneDrive"
RMDIR /Q /S "%LOCALAPPDATA%\Microsoft\OneDrive"
RMDIR /Q /S "%ProgramData%\Microsoft OneDrive"
RMDIR /Q /S "C:\OneDriveTemp"

REM 以下はレジストリを触るので調べながらやったほうがよい

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\OneDrive" /v PreventNetworkTrafficPreUserSignIn /t REG_DWORD /d 1 /f

REM エクスプローラーのエントリ
REM HKEY_LOCAL_MACHINE/SOFTWARE/Microsoft/Windows/CurrentVersion/Explorer/MyComputer/NameSpace で紐づけられている
reg delete "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f
reg delete "HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f
```

再起動後、ここで初めてインターネットに接続する。まずはWindows Update。

OfficeをインストールするにはMicrosoftアカウントによるサインインが必須になる。これもかなりいやな仕様だが……
仕方なくここでMicrosoftアカウントに切り替える

「設定」＞「アカウント」＞「ユーザーの情報」＞「アカウントの設定」＞「Microsoftアカウントでのサインインに切り替える」

OfficeをインストールしたらOneDriveが復活した、いらんねんそれは。同じ手順で削除していく
