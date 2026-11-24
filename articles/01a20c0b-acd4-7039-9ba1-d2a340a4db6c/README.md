## Dockerfileを使わない手抜きビルド

ローカルにmakeとかgccとか入れて散らかしたくない。`apt install`してからビルドする手順だと先にroot権限が必要なのでDockerfileを作ることになり、少し面倒。

非rootでコンテナを開始する

```
container=$(docker run --detach --interactive --tty --rm --user "$(id -u):$(id -g)" --volume .:/workdir --workdir /workdir ubuntu:26.04)
```

rootでパッケージをインストール

```
docker exec --user root $container bash -c 'apt update && apt install --yes gcc make'
```

非ルートでビルド

```
docker exec $container make
```

コンテナを停止。`--rm`で起動したので停止時に消える。

```
docker stop $container
```
