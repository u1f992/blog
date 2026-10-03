## gsudoは「降格」もできる

sudoコマンドがWindowsに標準搭載され影が薄くなっているが、gsudoは「降格」もできる。

管理者権限のPowerShellで

```
PS > cp C:\Windows\System32\notepad.exe C:\Windows\System32\notepad2.exe

PS > gsudo --integrity Medium
PS > cp C:\Windows\System32\notepad.exe C:\Windows\System32\notepad2.exe
cp : パス 'C:\Windows\System32\notepad2.exe' へのアクセスが拒否されました。
発生場所 行:1 文字:1
+ cp C:\Windows\System32\notepad.exe C:\Windows\System32\notepad2.exe
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ CategoryInfo          : PermissionDenied: (C:\Windows\System32\notepad.exe:FileInfo) [Copy-Item], UnauthorizedAccessException
+ FullyQualifiedErrorId : CopyFileInfoItemUnauthorizedAccessError,Microsoft.PowerShell.Commands.CopyItemCommand

PS > exit
PS > rm C:\Windows\System32\notepad2.exe
```
