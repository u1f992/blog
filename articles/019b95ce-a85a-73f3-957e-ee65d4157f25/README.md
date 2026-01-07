## node_modules以下にパッチをあてる

開発中の機能を一時的に他のプロジェクトで使えるようにしたいことがある。例えば今`@vivliostyle/cli`のlatestは10.2.1で、PR 712の機能を使いたい。

```
$ cd $(mktemp --directory)

$ npm view @vivliostyle/cli@10.2.1 dist.tarball | xargs curl -O

$ git clone https://github.com/vivliostyle/vivliostyle-cli --depth=1
$ cd vivliostyle-cli
$ git fetch origin pull/712/head
$ git merge FETCH_HEAD --no-edit
$ pnpm install
$ pnpm build
$ pnpm pack
$ mv vivliostyle-cli-10.2.1.tgz ..
$ cd ..

$ tree -L 1
.
├── cli-10.2.1.tgz
├── vivliostyle-cli
└── vivliostyle-cli-10.2.1.tgz

2 directories, 2 files

$ mkdir a b
$ tar -xzf cli-10.2.1.tgz -C a
$ tar -xzf vivliostyle-cli-10.2.1.tgz -C b
$ git diff --no-index --find-renames a/package b/package > pr-712.patch || true
$ head -n 10 pr-712.patch 
diff --git a/a/package/dist/chunk-5MEUINC4.js b/b/package/dist/chunk-5JTKT7VK.js
similarity index 99%
rename from a/package/dist/chunk-5MEUINC4.js
rename to b/package/dist/chunk-5JTKT7VK.js
index a026c93..bffb601 100644
--- a/a/package/dist/chunk-5MEUINC4.js
+++ b/b/package/dist/chunk-5JTKT7VK.js
@@ -16,7 +16,7 @@ import {
   prepareThemeDirectory,
   resolveTaskConfig,
```

カレントディレクトリがNode.jsプロジェクトで`node_modules`ディレクトリがあり、`@vivliostyle/cli@10.2.1`をインストール済みの時、以下の手順でパッチを適用できる（パスの先頭3階層`a/a/package`を無視）。

```
$ tree -L 1
.
├── node_modules
├── package-lock.json
├── package.json
└── pr-712.patch

2 directories, 3 files
$ cat package.json
{
  "dependencies": {
    "@vivliostyle/cli": "10.2.1"
  }
}
$ git apply -p3 --directory=node_modules/@vivliostyle/cli < pr-712.patch
```
