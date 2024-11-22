## PDFをPNGに変換

#### 全ページ

```
$ gs -dSAFER -dBATCH -dNOPAUSE -r300 -sDEVICE=pngalpha -sOutputFile=page_%03d.png input.pdf
```

#### 指定ページのみ

```
$ gs -dSAFER -dBATCH -dNOPAUSE -r300 -dFirstPage=344 -dLastPage=344 -sDEVICE=pngalpha -sOutputFile=page_344.png page_344.pdf
```

背景は透過なので、必要に応じて白背景を置く。

```
$ magick page_*.png -background white -alpha remove -alpha off page_*.png
```

コンテナ内で↑の作業をすると権限で不都合がありそう（`--user $(id -u):$(id -g)`）
