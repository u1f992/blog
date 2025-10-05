## FFmpegでmp4からgifに変換

パレット作成→Gif作成

```
$ ffmpeg -i input.mp4 -vf "fps=15,scale=640:-1:flags=lanczos,palettegen" -y palette.png
$ ffmpeg -i input.mp4 -i palette.png -lavfi "fps=15,scale=640:-1:flags=lanczos [x]; [x][1:v] paletteuse" -y output.gif
```

1行でできるらしい。

```
$ ffmpeg -i input.mp4 -filter_complex "[0:v]fps=15,scale=640:-1:flags=lanczos,split[a][b];[a]palettegen[p];[b][p]paletteuse" -y output-oneline.gif
$ sha256sum *.gif
f12d30d20c4bf9483f17e08f16fada73e232b54b34f3d5898c956d42567f7564  output-oneline.gif
f12d30d20c4bf9483f17e08f16fada73e232b54b34f3d5898c956d42567f7564  output.gif
```
