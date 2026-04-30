## さいきょうのbashスクリプトの書き出しを考える

```bash
#!/usr/bin/env bash
# Homebrewでbashを入れている場合などに有効かも

# https://news.ycombinator.com/item?id=8054440
# set -e: 非ゼロ終了時に停止
# set -E: ERRトラップを関数・コマンド置換・サブシェルに継承させる
# set -u: 未定義変数の参照をエラーに
# set -o pipefail: `set -e`と組み合わせてパイプラインのいずれかが失敗したら停止
# shopt -s inherit_errexit: `set -e`をコマンド置換`$(...)`に継承させる
set -eEuo pipefail
shopt -s inherit_errexit
trap 'echo "Error on line $LINENO: $BASH_COMMAND (exit $?)" >&2' ERR
```
