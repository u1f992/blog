## TypeScript　パッケージ自体はNode.jsに依存していないけどテストだけNode.jsの型を使いたい

このとき、`test/`でだけNode.jsの型（`@types/node`）を使用したい。ただし、`dist/`の構造は以下のようにテストのコードを含めないものとし、`test/`はNode.jsのType Strippingで実行する。

```
.
├── dist
│   ├── index.d.ts
│   ├── index.d.ts.map
│   ├── index.js
│   └── index.js.map
├── src
│   └── index.ts
├── test
│   └── index.test.ts
└── tsconfig.json
```

tsconfig.jsonを編集する。ここではNode.jsの型を使用していない。以下の箇所はデフォルトから編集が必要。

```diff
--- tsconfig.json.orig  2026-02-10 09:32:52.888632799 +0900
+++ tsconfig.json       2026-02-10 10:22:14.927391481 +0900
@@ -2,8 +2,8 @@
   // Visit https://aka.ms/tsconfig to read more about this file
   "compilerOptions": {
     // File Layout
-    // "rootDir": "./src",
-    // "outDir": "./dist",
+    "rootDir": "./src",
+    "outDir": "./dist",
 
     // Environment Settings
     // See also https://aka.ms/tsconfig/module
@@ -15,6 +15,9 @@
     // "types": ["node"],
     // and npm install -D @types/node
 
+    // Interoperability with Node.js Type Stripping
+    "rewriteRelativeImportExtensions": true,
+
     // Other Outputs
     "sourceMap": true,
     "declaration": true,
@@ -40,5 +43,7 @@
     "noUncheckedSideEffectImports": true,
     "moduleDetection": "force",
     "skipLibCheck": true,
-  }
+  },
+  // error TS6059: File '/.../test/index.test.ts' is not under 'rootDir' '/.../src'. 'rootDir' is expected to contain all source files.
+  "include": ["src"]
 }
```

test/tsconfig.jsonを作成し、こちらではNode.jsの型を使用する。tsconfig.jsonから継承される`compilerOptions.rootDir`と`include`を上書きする必要がある。`include`では、`../src`は`import`から解決されて取り込まれるので不要。もちろん解決された先の型検査も行われる。このtsconfig.jsonは型検査のみに使用するものだから、`noEmit`を有効化する。`"rewriteRelativeImportExtensions": true`を継承しているので`*.ts`拡張子のインポートは許可される（`noEmit`と相まって許可の効果だけが残る）。

> Default: `true` if `rewriteRelativeImportExtensions`; `false` otherwise. - https://www.typescriptlang.org/tsconfig/#allowImportingTsExtensions

```json
{
  "extends": "../tsconfig.json",
  "compilerOptions": {
    "rootDir": "..",
    "types": ["node"],
    "noEmit": true
  },
  "include": ["."]
}
```

このファイルはプロジェクトルートに`tsconfig.test.json`などとして置いてもよいのだが、VS Codeに拾ってもらえずエディタ上ではエラーになってしまう。おそらく何らか別の設定が必要。

ビルドとテストはそれぞれ次のようになる。

```
"scripts": {
  "build": "tsc",
  "test": "tsc --project test/tsconfig.json && node --test \"test/**/*.test.ts\""
},
```
