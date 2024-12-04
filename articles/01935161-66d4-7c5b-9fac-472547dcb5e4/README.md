## PDFをPNGに変換

- 背景透過なら`-sDEVICE=pngalpha`
- 全ページなら`-dFirstPage`/`-dLastPage`を削除

```
$ gs \
    -dBATCH \
    -dNOPAUSE \
    -dSAFER \
    -sDEVICE=png16m \
    -r300 \
    -dFirstPage=128 \
    -dLastPage=128 \
    -sOutputFile=page_%03d.png \
    input.pdf
```
