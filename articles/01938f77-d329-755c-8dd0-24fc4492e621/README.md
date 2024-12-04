## 基本的にDocker内で使っているツール類

GUIが必要な時は`--env "DISPLAY=${DISPLAY:-:0.0} --volume /mnt/wslg/.X11-unix/:/tmp/.X11-unix`（WSL）

- https://qiita.com/U-1F992/items/c75ffa7373a49d216862

### Ghostscript

```
$ docker run \
    --entrypoint /usr/bin/gs \
    --interactive \
    --mount type=bind,source=$(pwd),target=/workdir \
    --rm \
    --tty \
    --user $(id -u):$(id -g) \
    --workdir /workdir \
    registry.gitlab.com/islandoftex/images/texlive:TL2023-historic
```

### ImageMagick

```
$ docker run \
    --entrypoint /usr/local/bin/magick \
    --interactive \
    --mount type=bind,source=$(pwd),target=/workdir \
    --rm \
    --tty \
    --user $(id -u):$(id -g) \
    --workdir /workdir \
    dpokidov/imagemagick:7.1.1-39
```
