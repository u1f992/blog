## ワーキングディレクトリ内のファイル名がある正規表現にマッチするファイルから、ある正規表現にマッチする行を抽出する on WSL

`clip.exe`はsjisなので文字コード変換が必要

https://zenn.dev/kumavale/scraps/2271c61cbd19ef

```
find . -regex './[0-9]-[0-9].txt' | xargs -I{} grep '^■■' {} | iconv -t sjis | clip.exe
```
