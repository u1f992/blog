## MSYS2のポータブル環境

#### shell.cmd

```bat
@echo off
setlocal enabledelayedexpansion

if not defined TARGET_DIR set "TARGET_DIR=.msys2"

if exist "%TARGET_DIR%\msys64\msys2_shell.cmd" (
    cd "%TARGET_DIR%\msys64"
    msys2_shell.cmd -defterm -here -no-start %*
    exit /b 0
)

mkdir "%TARGET_DIR%"
cd "%TARGET_DIR%"

powershell -Command "Invoke-WebRequest -Uri https://github.com/msys2/msys2-installer/releases/download/2024-11-16/msys2-base-x86_64-20241116.sfx.exe -OutFile msys2-base-x86_64-20241116.sfx.exe"
msys2-base-x86_64-20241116.sfx.exe -y
cd msys64

rem The shell exits with a non-zero status due to core system updates
cmd /C msys2_shell.cmd -defterm -here -no-start -c "pacman -Suy --noconfirm"

rem This time update packages
cmd /C msys2_shell.cmd -defterm -here -no-start -c "pacman -Suy --noconfirm"

cmd /C msys2_shell.cmd -defterm -here -no-start -ucrt64 -c "pacman -S --noconfirm mingw-w64-ucrt-x86_64-cmake mingw-w64-ucrt-x86_64-toolchain"

msys2_shell.cmd -defterm -here -no-start %*
```
