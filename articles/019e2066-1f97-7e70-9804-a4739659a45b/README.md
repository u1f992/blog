## GNOME Shell Extensions

GNOME Shell Extensionsの管理には、CLI（`gnome-extensions`）／公式GUI（パッケージ名：`gnome-shell-extension-prefs`、Flatpak ID：`org.gnome.Extensions`）／サードパーティGUI（パッケージ名：`gnome-shell-extension-manager`、Flatpak ID：`com.mattjakeman.ExtensionManager`）がある。`com.mattjakeman.ExtensionManager`はサードパーティではあるものの、gnome-shellにIDがハードコーディングされている[ref](https://gitlab.gnome.org/GNOME/gnome-shell/-/blob/gnome-46/js/ui/extensionSystem.js#L89-91) [ref](https://gitlab.gnome.org/GNOME/gnome-shell/-/work_items/5564)。

Ubuntu（24.04）にはCLIが標準インストールされている。いずれかのGUIがインストールされており`allow-extension-installation`有効の場合に、セッション開始時に自動アップデートが行われる[ref](https://gitlab.gnome.org/GNOME/gnome-shell/-/blob/gnome-46/js/ui/extensionSystem.js#L75)。

GNOMEはGUIでのみ使うものだから、公式GUIをインストールすることは特に問題にはならないだろう。ただし公式GUIにはリモートを管理する機能はない。インストールはwgetによる手動fetchで行う。たとえば[Hide Top Bar](https://extensions.gnome.org/extension/545/hide-top-bar/)の場合。

```bash
PK=545   # EGO URL の /extension/<PK>/... から取れる拡張 ID
SHELL_VER=$(gnome-shell --version | awk '{print $3}' | cut -d. -f1)

# UUID と該当 Shell バージョン向けビルドの version_tag を EGO から取得
INFO=$(wget -qO- "https://extensions.gnome.org/extension-info/?pk=$PK&shell_version=$SHELL_VER")
UUID=$(echo "$INFO" | python3 -c "import json,sys; print(json.load(sys.stdin)['uuid'])")
VTAG=$(echo "$INFO" | python3 -c "import json,sys; print(json.load(sys.stdin)['shell_version_map']['$SHELL_VER']['pk'])")

# zip をダウンロードして CLI でインストール（zip は seekable である必要があり、pipe 不可なので一時ファイル経由）
ZIP=$(mktemp --suffix=.zip)
wget -q -O "$ZIP" "https://extensions.gnome.org/download-extension/$UUID.shell-extension.zip?version_tag=$VTAG"
gnome-extensions install "$ZIP"

# ログアウト→ログイン後に有効化（公式 GUI からトグル ON でも可）
# gnome-extensions enable "$UUID"
```
