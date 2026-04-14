## Dev Container CLIのdevcontainer upがフォアグラウンドで継続してしまう問題が解消していた

v0.80.1以前のDev Containers CLIと[Docker v29](https://github.com/moby/moby/releases/tag/docker-v29.0.0)の組み合わせで、`devcontainer up`において、コンテナの作成を伴う場合のみフォアグラウンド継続・そうでない場合はコンテナIDを示して終了するため扱いづらい問題があった。以下のようなタイムアウトスニペットを作成して回避していた。

<details>
<summary>以前使用したスニペット</summary>

```json
{
  scripts: {
    "devcontainer:up": "node -e \"try{require('child_process').execSync('devcontainer up --workspace-folder .',{timeout:10000,stdio:'inherit'})}catch(e){if(!e.killed)throw e}\""
   }
}
```

</details>

仕様だと勘違いしていたのだが、[devcontainers/cli#1103](https://github.com/devcontainers/cli/pull/1103)でDocker v29への対応が入りv0.80.2としてリリースされたことで解消していた。

Docker v29の破壊的変更のうち、以下の箇所が影響している。

> - `GET /events` no longer includes the deprecated `status`, `id`, and `from` fields. These fields were removed in API v1.22, but still included in the response. These fields are now omitted when using API v1.52 or later. [moby/moby#50832](https://github.com/moby/moby/pull/50832)

`devcontainer up`はコンテナ起動後、`info.status === "starts"`でイベントを待って処理を継続していた。Docker v29で`status`が廃止されたため、この箇所が壊れていたようだ。

---

メモ：Dev Container CLIが作成するコンテナとイメージをクリーンアップする方法。`--workspace-folder`に移動して使う。

```shellsession
$ docker ps --all --filter "label=devcontainer.local_folder=$PWD" --format '{{.ID}}' | xargs --no-run-if-empty docker rm --force
$ docker images --format '{{.Repository}}' | grep "vsc-$(basename "$PWD")" | xargs --no-run-if-empty docker rmi
```

