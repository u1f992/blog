## mintty.exeでWSLを起動する

`C:\msys64\usr\bin\mintty.exe C:\Windows\System32\wsl.exe --cd "~"`へのショートカットを作成する。Git Bashでもいけるかも。

```
> $wshShell=New-Object -ComObject "WScript.Shell";$wslPath="C:\Windows\System32\wsl.exe";$minttyPath="C:\msys64\usr\bin\mintty.exe";$lnk=$wshShell.CreateShortcut("$($PWD.Path)\wsl.exe.lnk");$lnk.TargetPath=$minttyPath;$lnk.Arguments="$wslPath --cd ""~""";$lnk.WorkingDirectory=$PWD.Path;$lnk.IconLocation="$wslPath, 0";$lnk.Save();
```

```javascript
var wshShell = new ActiveXObject("WScript.Shell");
var curDir = wshShell.CurrentDirectory;
var wslPath = "C:\\Windows\\System32\\wsl.exe";

var lnk = wshShell.CreateShortcut(curDir + "\\wsl.exe.lnk");
lnk.TargetPath = "C:\\msys64\\usr\\bin\\mintty.exe";
lnk.Arguments = wslPath + " --cd \"~\"";
lnk.WorkingDirectory = curDir;
lnk.IconLocation = wslPath + ", 0"
lnk.Save();
```

なんでこんなことをするかというと、MSYS2よりはWSLのほうが"ほぼLinux"として扱いやすいが、Windows Terminalはsixelに対応してないので面白くなかったりキーボードショートカットがおせっかいだったりして好きじゃないから。

フォント設定などもろもろ`.minttyrc`はMSYS2の`$HOME`に置いておく。

バッチファイルのほうがいいかも。この場合`.minttyrc`はWindows側の`%USERPROFILE%`に置いておく。

```
C:\msys64\usr\bin\mintty.exe --title wsl --icon C:\Windows\System32\wsl.exe,0 C:\Windows\System32\wsl.exe --cd "~"
```

応用のPowerShell。HOMEを設定しておかないと（Windows側の）Vimなど一部が正しく設定を読まない。

```
SET HOME=%USERPROFILE%
C:\msys64\usr\bin\mintty.exe --icon "C:\Program Files\PowerShell\7\pwsh.exe,0" "C:\Program Files\PowerShell\7\pwsh.exe" -WorkingDirectory %USERPROFILE%
```
