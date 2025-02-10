## RDPメモ

- https://github.com/stascorp/rdpwrap
- https://github.com/sebaxakerhtc/rdpwrap.ini
- https://qiita.com/nak435/items/800dbda782f4fe9c7df1

```
PS > Set-Location Download
PS > Invoke-WebRequest -Uri https://github.com/stascorp/rdpwrap/releases/download/v1.6.2/RDPWrap-v1.6.2.zip -OutFile RDPWrap-v1.6.2.zip
PS > Expand-Archive -Path RDPWrap-v1.6.2.zip -DestinationPath ..\RDPWrap-v1.6.2
PS > Remove-Item .\RDPWrap-v1.6.2.zip
PS > Set-Location ..\RDPWrap-v1.6.2
PS > New-Item -Type Directory rdpwrap.ini.backup
PS > Invoke-WebRequest -Uri https://raw.githubusercontent.com/sebaxakerhtc/rdpwrap.ini/7c699d5bc5adde603e4d12b68b24a2d234b68eb5/rdpwrap.ini -OutFile rdpwrap.ini.backup/rdpwrap.ini.7c699d5bc5adde603e4d12b68b24a2d234b68eb5
PS > sudo .\install.bat
...
OK

[+] Successfully installed.
______________________________________________________________

You can check RDP functionality with RDPCheck program.
Also you can configure advanced settings with RDPConf program.

続行するには何かキーを押してください . . .
PS > sudo .\update.bat
RDP Wrapper Library v1.6.2
Installer v2.5
Copyright (C) Stas'M Corp. 2017

[*] Checking for updates...
[*] Current update date: 2018.10.10
[*] Latest update date:  2018.10.10
[*] Everything is up to date.

続行するには何かキーを押してください . . .
PS > sudo net stop termservice
Remote Desktop Services サービスを停止中です.
Remote Desktop Services サービスは正常に停止されました。

PS > Copy-Item 'C:\Program Files\RDP Wrapper\rdpwrap.ini' .\rdpwrap.ini.backup\
PS > sudo pwsh -Command "Copy-Item .\rdpwrap.ini.backup\rdpwrap.ini.7c699d5bc5adde603e4d12b68b24a2d234b68eb5 'C:\Program Files\RDP Wrapper\rdpwrap.ini'"
PS > sudo net start termservice
Remote Desktop Services サービスを開始します.
Remote Desktop Services サービスは正常に開始されました。

PS > .\RDPConf.exe
```

`Listener state: Listening`を確認

```
PS > (Invoke-WebRequest -Uri 'https://api64.ipify.org').Content
```
