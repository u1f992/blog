## zshとbashでPATH設定を共通化する（Mac）

<figure>
<figcaption>~/.config/shell/path.sh</figcaption>

```sh
# zshとbashでPATH設定を共通化するためのスクリプト
# .zshrc / .bashrcから以下のように読み込ませる
#
#   if [ -f "$HOME/.config/shell/path.sh" ]; then
#     . "$HOME/.config/shell/path.sh"
#   fi
#
# bashはログインシェルとして起動する場合.bashrcを読まない
# SSH接続時のログインシェルをbashに設定している場合、.bash_profileから.bashrcを読み込むように設定する
#
#   if [ -f "$HOME/.bashrc" ]; then
#     . "$HOME/.bashrc"
#   fi

prepend_path() {
  case ":$PATH:" in
    *:"$1":*) ;;
    *) PATH="$1:$PATH" ;;
  esac
}

prepend_path "$HOME/.docker/bin"

export PATH
```

</figure>
