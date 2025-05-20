## 基本的にDocker内で使っているツール類

GUIが必要な時は`--env "DISPLAY=${DISPLAY:-:0.0} --volume /mnt/wslg/.X11-unix/:/tmp/.X11-unix`（WSL）

- https://qiita.com/U-1F992/items/c75ffa7373a49d216862

### Ghostscript

```
FROM ubuntu:24.04 AS builder
RUN apt-get update && apt-get --yes install \
        gcc \
        make \
        wget \
    && rm -rf /var/lib/apt/lists/* \
    && wget https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs10051/ghostscript-10.05.1.tar.gz \
    && tar xvf ghostscript-10.05.1.tar.gz \
    && cd ghostscript-10.05.1 \
    && ./configure --prefix=/usr/local \
    && make -j$(nproc) \
    && make install

FROM ubuntu:24.04
COPY --from=builder /usr/local/. /usr/local/

ENTRYPOINT [ "gs" ]
```

```
docker build -f ghostscript.dockerfile -t ghostscript:10.05.1 .
```

```
$ docker run \
    --entrypoint /usr/bin/gs \
    --interactive \
    --mount type=bind,source=$(pwd),target=/workdir \
    --rm \
    --tty \
    --user $(id -u):$(id -g) \
    --workdir /workdir \
    ghostscript:10.05.1
```

`registry.gitlab.com/islandoftex/images/texlive:TL<year>-historic`にも入っているので、他のPDF周りのツールを使うときはこちらのほうが便利なこともある。

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
