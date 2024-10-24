## Ghostscriptの`inkcov`と`ink_cov`

https://ghostscript.readthedocs.io/en/latest/Devices.html#ink-coverage-output

「全体をC50で塗りつぶしたとき、`inkcov`は100%、`ink_cov`は50%を返す」

```
gs -dSAFER -dNOPAUSE -dBATCH -o- -sDEVICE=inkcov Y.pdf
gs -dSAFER -dNOPAUSE -dBATCH -o- -sDEVICE=ink_cov Y.pdf
```
