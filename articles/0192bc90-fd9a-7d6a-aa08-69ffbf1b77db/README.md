## 追跡中のすべてのC言語ファイルにフォーマッタをかける

- `git ls-files`はフィルタできる
- `clang-format`のスタイル定義は`--style=file:~`で指定
- `-i`でインライン置換

```
$ git ls-files "*.c" "*.h" | xargs -I{} clang-format --style=file:.clang-format -i {}
```
