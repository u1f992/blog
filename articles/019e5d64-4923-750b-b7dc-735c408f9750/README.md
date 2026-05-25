## TypeScriptプロジェクトのテンプレート

```shellsession
$ mkdir proj
$ cd proj
```

最初のコミットは修正などの操作がその他のコミットと異なるので、`--allow-empty`で空コミットにして回避するとよいという意見がある。

- https://qiita.com/NorsteinBekkler/items/b2418cd5e14a52189d19

```shellsession
$ git init .
$ git branch -m main
$ git commit -m "Initial commit" --allow-empty
$ gh repo gitignore view Node > .gitignore
```

先にoriginを設定しておくと、`repository`・`bugs`・`homepage`が自動で設定される。特に`repository`はOIDCリリースに必須

- https://github.com/npm/documentation/blob/203cdd5dffbd5dc5a125f3b750717f69fd652171/content/packages-and-modules/securing-your-code/trusted-publishers.mdx?plain=1#L348

> To publish from GitHub, your package's `repository.url` field in `package.json` must exactly match your GitHub repository.

GitHubかどうかの判定があるようだ。https://github.com/u1f992/blog なら`repository`・`bugs`・`homepage`が設定されたが、https://foobar.invalid/proj では`repository`しか設定されなかった。

```shellsession
$ git remote add origin https://github.com/u1f992/blog
```

`version`を`0.0.0`にしておくと、初回リリースタグを`npm version`で打てる。

```shellsession
$ npm init --yes
$ npm pkg set version=0.0.0
$ npm pkg set main=dist/index.js
$ npm pkg set type=module
$ npm install --save-dev typescript @types/node@22 prettier eslint @eslint/js typescript-eslint
$ npx tsc --init
$ npm pkg set build=tsc
$ npm pkg set 'scripts.test=tsc --project tests/tsconfig.json && node --test "tests/**/*.test.ts"'
$ npm pkg set 'scripts.format=prettier --write "src/**/*.ts" "tests/**/*.ts"'
$ npm pkg set 'scripts.lint=eslint --flag unstable_native_nodejs_ts_config --fix "src/**/*.ts" "tests/**/*.ts"'

$ jq '."//" += {"$.scripts.lint":["see https://github.com/eslint/eslint/issues/19985"]}' package.json > package.json.tmp && mv package.json.tmp package.json
```

```diff
$ diff --unified tsconfig.json.orig tsconfig.json
--- tsconfig.json.orig  2026-05-25 13:39:12.125831935 +0900
+++ tsconfig.json       2026-05-25 13:40:00.923930363 +0900
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
@@ -15,6 +15,10 @@
     // "types": ["node"],
     // and npm install -D @types/node
 
+    // Interoperability with Node.js Type Stripping
+    // see https://github.com/u1f992/blog/blob/c2e08fa8fc20d6bfc154381e798154435898fc06/articles/019c44f4-bc9c-7487-b398-712364c3c380/README.md
+    "rewriteRelativeImportExtensions": true,
+
     // Other Outputs
     "sourceMap": true,
     "declaration": true,
@@ -40,5 +44,8 @@
     "noUncheckedSideEffectImports": true,
     "moduleDetection": "force",
     "skipLibCheck": true,
-  }
+  },
+  // error TS6059: File '/ ... /tests/ ... .ts' is not under 'rootDir' '/ ... /src'. 'rootDir' is expected to contain all source files.
+  // see https://github.com/u1f992/blog/blob/c2e08fa8fc20d6bfc154381e798154435898fc06/articles/019c44f4-bc9c-7487-b398-712364c3c380/README.md
+  "include": ["src"]
 }
```

<figure>
<figcaption>tests/tsconfig.json</figcaption>

```jsonc
// see https://github.com/u1f992/blog/blob/c2e08fa8fc20d6bfc154381e798154435898fc06/articles/019c44f4-bc9c-7487-b398-712364c3c380/README.md
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

</figure>
<figure>
<figcaption>prettier.config.ts</figcaption>

```typescript
import type { Config } from "prettier";

/**
 * @see https://github.com/prettier/prettier/blob/3.8.3/docs/configuration.md
 */
const prettierConfig: Config = {};

export default prettierConfig;
```

</figure>
<figure>
<figcaption>eslint.config.ts</figcaption>

```typescript
import js from "@eslint/js";
import { defineConfig } from "eslint/config";
import tseslint from "typescript-eslint";

/**
 * @see https://github.com/typescript-eslint/typescript-eslint/blob/v8.59.4/docs/getting-started/Quickstart.mdx
 */
const eslintConfig = defineConfig(
  js.configs.recommended,
  tseslint.configs.recommended,
);

export default eslintConfig;
```

[ESLint - Configure Language Options](https://github.com/eslint/eslint/blob/v10.4.0/docs/src/use/configure/migration-guide.md#configure-language-options)についてのメモ。この`globals`の設定は、プロジェクト全体がTypeScriptなら特に効果がない。

`globals`は未定義変数の利用`no-undef`の除外ルール。typescript-eslintでは`no-undef`は無効化するように推奨されており（[ref](https://github.com/typescript-eslint/typescript-eslint/blob/v8.59.4/docs/troubleshooting/faqs/ESLint.mdx#i-get-errors-from-the-no-undef-rule-about-global-variables-not-being-defined-even-though-there-are-no-typescript-errors)）、`tseslint.configs.recommended`にも反映されている。これは、変数が未定義ならそもそもtscが弾くため。
