## MSYS2のポータブル環境

#### shell.sh

```sh
#!/bin/bash

set -eu

if [ -z "${TARGET_DIR:-}" ]; then
    echo "Usage: TARGET_DIR=target_dir $0"
    exit 1
fi

if [ -e "$TARGET_DIR/msys64/msys2_shell.cmd" ]; then
    cd "$TARGET_DIR"
    cd msys64/
    cmd.exe /C msys2_shell.cmd -defterm -here -no-start "$@"
    exit 0
fi

mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

curl --location --remote-name https://github.com/msys2/msys2-installer/releases/download/2024-11-16/msys2-base-x86_64-20241116.sfx.exe
./msys2-base-x86_64-20241116.sfx.exe -y
cd msys64/
# The shell exits with a non-zero status due to core system updates
echo "yes | pacman -Suy && exit" | cmd.exe /C msys2_shell.cmd -defterm -here -no-start || true
# This time update packages
echo "yes | pacman -Suy && exit" | cmd.exe /C msys2_shell.cmd -defterm -here -no-start || true

cmd.exe /C msys2_shell.cmd -defterm -here -no-start "$@"
```
