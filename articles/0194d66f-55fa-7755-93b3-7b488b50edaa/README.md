## AppImageを手動でインストールする（Ubuntu 24.04）

```
$ mkdir ~/.local/bin/arduino-ide && cd ~/.local/bin/arduino-ide/
$ mv ~/Downloads/arduino-ide_2.3.6_Linux_64bit.AppImage .
$ chmod +x arduino-ide_2.3.6_Linux_64bit.AppImage
$ ./arduino-ide_2.3.6_Linux_64bit.AppImage --appimage-extract
$ chmod +x ~/.local/bin/arduino-ide/squashfs-root/arduino-ide.desktop
$ ln -s ~/.local/bin/arduino-ide/squashfs-root/arduino-ide.desktop ~/.local/share/applications/arduino-ide.desktop
$ cat ~/.local/share/applications/arduino-ide.desktop 
[Desktop Entry]
Name=Arduino IDE
Exec=AppRun --no-sandbox %U
Terminal=false
Type=Application
Icon=arduino-ide
StartupWMClass=Arduino IDE
X-AppImage-Version=2.3.6
Comment=Arduino IDE
Categories=Development;
$ nano ~/.local/share/applications/arduino-ide.desktop 
$ cat ~/.local/share/applications/arduino-ide.desktop 
[Desktop Entry]
Name=Arduino IDE
Exec=/home/mukai/.local/bin/arduino-ide/squashfs-root/AppRun --no-sandbox %U
Terminal=false
Type=Application
Icon=/home/mukai/.local/bin/arduino-ide/squashfs-root/arduino-ide.png
StartupWMClass=Arduino IDE
X-AppImage-Version=2.3.6
Comment=Arduino IDE
Categories=Development;
```

- `*.desktop`には実行権限が必要
- `*.desktop`が正しい`Exec`/`Icon`を指しているか確認する。
  - `~/`を解釈しないので注意
  - `Exec`はパスが通っていればコマンド名でいい。通っていなければ絶対パスで指定
  - `Icon`は絶対パスで指定
