## `*.ai` → `*.pdf`

アウトライン化されていたら多分大丈夫

```
$ gs \
    -dBATCH \
    -dNOPAUSE \
    -dSAFER \
    -sDEVICE=pdfwrite \
    -dCompatibilityLevel=1.4 \
    -dPDFSETTINGS=/prepress \
    -sOutputFile=output.pdf \
    input.ai
```
