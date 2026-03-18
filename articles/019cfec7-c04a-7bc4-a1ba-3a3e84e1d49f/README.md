## npxでサブディレクトリにあるパッケージを直接実行する

対応する記述をドキュメント内で見つけられていないのだが、以下のようにしてサブディレクトリにあるパッケージを直接実行できる。

```shellsession
$ echo "# hello" | npx --yes --loglevel=silent "git+https://github.com/vivliostyle/vfm.git#a1fd162fefca440e72b24c85e11be35bbec4d0da::path:packages/vfm"
```

一応言及はされている

- https://github.com/npm/feedback/discussions/39#discussioncomment-85141

ここらへんで処理されていそう。

- https://github.com/npm/cli/blob/8eff5fb31afc996c71c8f159defa324cb86dfc5a/node_modules/pacote/lib/fetcher.js#L32
  - https://github.com/npm/cli/blob/8eff5fb31afc996c71c8f159defa324cb86dfc5a/node_modules/npm-package-arg/lib/npa.js#L219
    - https://github.com/npm/cli/blob/8eff5fb31afc996c71c8f159defa324cb86dfc5a/node_modules/npm-package-arg/lib/npa.js#L244
- （tarball）https://github.com/npm/cli/blob/8eff5fb31afc996c71c8f159defa324cb86dfc5a/node_modules/pacote/lib/git.js#L256
- （ssh download）https://github.com/npm/cli/blob/8eff5fb31afc996c71c8f159defa324cb86dfc5a/node_modules/pacote/lib/git.js#L278

`a1fd162fefca440e72b24c85e11be35bbec4d0da::path:packages/vfm`が`[a1fd162fefca440e72b24c85e11be35bbec4d0da, path:packages/vfm]`に分解されている。`:`がない前者はcommit-ish（コミットハッシュ、ブランチ、タグ）、ある後者はさらに`[path, packages/vfm]`に分解されてサブディレクトリが認識される。ほかに`semver`があるらしいが、いまのところ使い道がわからない。その他はignoring unknown keyされる。

pacoteがgitSubdirを使うようになったのが https://github.com/npm/pacote/pull/442 で、この変更が入ったリリースは21.2.0。npmでpacote@21.2.0以降のバージョンを取り込んだのは https://github.com/npm/cli/commit/aae84bf5a で、npmのリリースとしては[11.10.0 (2026-02-11)](https://github.com/npm/cli/releases/tag/v11.10.0)で含まれたはず。ごく最近だ。

```shellsession
$ docker run --rm node:latest bash -c '
npm install -g npm@11.9.0 2>/dev/null >/dev/null
npm --version
npx --yes "git+https://github.com/vivliostyle/vfm.git#a1fd162fefca440e72b24c85e11be35bbec4d0da::path:packages/vfm" --version 2>&1
'
11.9.0
...
npm error could not determine executable to run  ← path:packages/vfmが無視されてルートを見に行き失敗
...

$ docker run --rm node:latest bash -c '
npm install -g npm@11.10.0 2>/dev/null >/dev/null
npm --version
npx --yes "git+https://github.com/vivliostyle/vfm.git#a1fd162fefca440e72b24c85e11be35bbec4d0da::path:packages/vfm" --version 2>&1
'
11.10.0
...
2.5.0
...
```

なおTypeScriptを採用しているプロジェクトの場合、`prepare`スクリプトを用意することで、内部で`npm install`が行われた後に自動でビルドされ、package.jsonが指すbinも用意されてnpxで実行できるようになる。

ちなみにpnpm dlxではv9から`&path:`で同じことを行える。

```
$ docker run --rm node:latest bash -c '
npm install -g pnpm@9.0.0 2>/dev/null >/dev/null
pnpm --version
pnpm dlx "github:vivliostyle/vfm#a1fd162fefca440e72b24c85e11be35bbec4d0da&path:packages/vfm" --version 2>&1
'
9.0.0
...
2.5.0
```
