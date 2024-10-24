## カレントディレクトリ以下のPNG画像をJPGに変換する

ファイル名を切り取るやつ、ほんと覚えられない……

```
for file in $(find . -name "*.png" -type f); do convert "$file" "${file%.png}.jpg"; rm "$file"; done
```

PNGの圧縮を調節したかったので結局こっちを使った。8並列optipng

```
find . -name "*.png" -type f -print0 | xargs -0 -P8 -n1 optipng -o7
```
