@echo off
setlocal enabledelayedexpansion

if not defined MSYS2_LOCAL set MSYS2_LOCAL=.msys64

:GENERATE_TEMP_DIR
for /f %%i in ('powershell -Command "[guid]::NewGuid().ToString()"') do set UUID=%%i
set TEMP_DIR=%TEMP%\%UUID%
if exist "%TEMP_DIR%" goto GENERATE_TEMP_DIR

if not exist "%CD%\%MSYS2_LOCAL%\msys2_shell.cmd" (
    mkdir "%TEMP_DIR%"
    powershell -Command "Invoke-WebRequest -Uri https://github.com/msys2/msys2-installer/releases/download/2024-11-16/msys2-base-x86_64-20241116.sfx.exe -OutFile ""%TEMP_DIR%\msys2-base-x86_64-20241116.sfx.exe"""
    "%TEMP_DIR%\msys2-base-x86_64-20241116.sfx.exe" -y -o"%TEMP_DIR%"
    move "%TEMP_DIR%\msys64" "%CD%\%MSYS2_LOCAL%"
    rmdir /s /q "%TEMP_DIR%"

    rem Core system upgrade
    cmd /c %CD%\%MSYS2_LOCAL%\msys2_shell.cmd -defterm -here -no-start -c "pacman -Suy --noconfirm"
    rem Update packages
    cmd /c %CD%\%MSYS2_LOCAL%\msys2_shell.cmd -defterm -here -no-start -c "pacman -Suy --noconfirm"
    rem Install local dependencies
    cmd /c %CD%\%MSYS2_LOCAL%\msys2_shell.cmd -defterm -here -no-start -ucrt64 -c "pacman -S --noconfirm python make"
)

cmd /c %CD%\%MSYS2_LOCAL%\msys2_shell.cmd -defterm -here -no-start %*
