## AppImageをランチャーに追加する（Ubuntu 24.04）

```
$ mv foobar.AppImage ~/.local/bin/foobar
$ cd ~/.local/bin/foobar
$ chmod +x foobar
$ foobar --appimage-extract
$ cp squashfs-root/foobar.desktop ~/.local/share/applications/
$ chmod +x ~/.local/share/applications/foobar.desktop
$ cp squashfs-root/foobar.png ~/.local/share/applications/
$ rm -rf squashfs-root
```

- もとのAppImageより`squashfs-root`を残したほうがいい？
- `*.desktop`には実行権限が必要
- `*.desktop`が正しい`Exec`/`Icon`を指しているか確認する。
  - `Exec`はパスが通っていればコマンド名でいい
  - `Icon`は絶対パスで指定

