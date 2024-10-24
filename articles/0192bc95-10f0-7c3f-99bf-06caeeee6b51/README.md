## DockerでTeXツールチェイン

```
docker run --mount "type=bind,source=$PWD,target=/workdir" --workdir /workdir --interactive --tty --rm registry.gitlab.com/islandoftex/images/texlive:TL2023-historic bash
```

使い道はないかもしれないけどGUIも出せる。WSLなら：

```
docker run \
    --env "DISPLAY=${DISPLAY:-:0.0}" \
    --volume /mnt/wslg/.X11-unix/:/tmp/.X11-unix \
    --mount "type=bind,source=$PWD,target=/workdir" \
    --workdir /workdir \
    --interactive \
    --tty \
    --rm \
    registry.gitlab.com/islandoftex/images/texlive:TL2023-historic bash
```

https://qiita.com/U-1F992/items/c75ffa7373a49d216862
