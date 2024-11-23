## 白背景を詰める

trimのアルゴリズムの都合、全体が背景色以外で囲われている場合、その枠が削除されてしまう。

https://qiita.com/yoya/items/62879e6e03d5a70eed09

```
$ magick input.png -bordercolor white -border 1x1 -trim +repage output.png
```

```
$ docker run \
    --rm \
    --tty \
    --user $(id -u):$(id -g) \
    --mount type=bind,source=.,target=/workdir \
    --workdir /workdir \
    --entrypoint /usr/local/bin/magick \
    dpokidov/imagemagick:7.1.1-39
```
