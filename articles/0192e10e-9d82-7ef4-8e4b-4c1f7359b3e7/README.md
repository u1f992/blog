## MSYS2のポータブル環境

#### shell.bat

```bat
@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

IF NOT DEFINED TARGET_DIR SET "TARGET_DIR=.env"

IF EXIST "%TARGET_DIR%\msys64\msys2_shell.cmd" (
    CD "%TARGET_DIR%\msys64"
    msys2_shell.cmd -defterm -here -no-start %*
    EXIT /B 0
)

MKDIR "%TARGET_DIR%" 2>NUL
CD "%TARGET_DIR%"

IF NOT EXIST msys2-base-x86_64-20241116.sfx.exe (
    POWERSHELL -Command "Invoke-WebRequest -Uri https://github.com/msys2/msys2-installer/releases/download/2024-11-16/msys2-base-x86_64-20241116.sfx.exe -OutFile msys2-base-x86_64-20241116.sfx.exe"
)
msys2-base-x86_64-20241116.sfx.exe -y
CD msys64

REM The shell exits with a non-zero status due to core system updates
cmd /C msys2_shell.cmd -defterm -here -no-start -c "yes | pacman -Suy"

REM This time update packages
cmd /C msys2_shell.cmd -defterm -here -no-start -c "yes | pacman -Suy"

msys2_shell.cmd -defterm -here -no-start %*
```
