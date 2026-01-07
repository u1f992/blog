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
$ LANG=C diff --recursive --unified --new-file a/package b/package > pr-712.patch || true
$ head -n 5 pr-712.patch 
diff --recursive --unified --new-file a/package/dist/chunk-37OLZSNI.js b/package/dist/chunk-37OLZSNI.js
--- a/package/dist/chunk-37OLZSNI.js    1985-10-26 17:15:00.000000000 +0900
+++ b/package/dist/chunk-37OLZSNI.js    1970-01-01 09:00:00.000000000 +0900
@@ -1,87 +0,0 @@
-import {
```

カレントディレクトリがNode.jsプロジェクトで`node_modules`ディレクトリがあり、`@vivliostyle/cli@10.2.1`をインストール済みの時、以下の手順でパッチを適用できる（パスの先頭2階層`{a,b}/package`を無視）。

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
$ patch --strip=2 --directory=node_modules/@vivliostyle/cli < pr-712.patch
```
