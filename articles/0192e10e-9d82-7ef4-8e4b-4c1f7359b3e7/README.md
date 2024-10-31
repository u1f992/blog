## MSYS2のポータブル環境

```
> Invoke-WebRequest -Uri https://github.com/msys2/msys2-installer/releases/download/2024-07-27/msys2-base-x86_64-20240727.sfx.exe -OutFile msys2-base-x86_64-20240727.sfx.exe
> .\msys2-base-x86_64-20240727.sfx.exe -y "-o$PWD\"
> cd .\msys64\
> .\msys2_shell.cmd -defterm -here -no-start -ucrt64

$ pacman -Suy
$ # コアシステムの更新が行われた場合はMSYS2シェルが終了するので、再度起動してもう一度`pacman -Suy`を実行する
```

