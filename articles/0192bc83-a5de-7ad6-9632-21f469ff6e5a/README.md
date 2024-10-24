## JScriptをバッチファイルに埋め込む（Shebangもどき）

詠み人知らず。

- https://miya2000.hatenadiary.org/entry/20090823/p0
- https://qiita.com/snipsnipsnip/items/50e4ca88e3ce3f8cffda

前提として、バッチファイルに構文エラーがあっても実行されない場合には問題にならない。

### JScript

```js
@if(0)==(0) ECHO OFF
CScript //Nologo //E:JScript "%~f0" %*
EXIT /B %ERRORLEVEL%
@end

WScript.StdOut.WriteLine("foo");
```

あるいは1行で

```js
@if(0)==(0) ECHO OFF && CScript //Nologo //E:JScript "%~f0" %* && EXIT /B %ERRORLEVEL% @end

WScript.StdOut.WriteLine("foo");
```

- バッチファイル側
  - `if`文にエコーを封じる@がついたもの
  - `(0)==(0)`が解釈され、trueなので`echo off`以降が実行される
  - 拡張子が`.bat`なのでエンジン指定は必須
  - `exit`で実行が止まるので、以降に構文エラー(=JScript)があっても問題にならない
- JScript側
  - `@if()`文……JScriptの[特殊文法](https://blog.delphinus.dev/2010/09/conditional-compilation-in-jscript.html)
  - `0`が解釈され、falseなので`@if(0)`～`@end`は無視される

### Chakra

```js
<!-- : ^
/*
@cscript /nologo /e:{1b7cd997-e5ff-4932-a7a6-2a9e636da385} "%~f0" %*
@exit /b %errorlevel%
*/

"use strict"
WScript.StdOut.WriteLine(WScript.Arguments(0));
try{WScript.Quit(99);}catch(e){}
```

- バッチファイル側
  - 1行目は `:` によってラベル定義なので問題なし
  - `^` によって制御文字CRLFを打ち消して、次の行の `/*` も1行目と同時に解釈される
  - `exit` まで実行。上述の通り
- Chakra
  - `<!--` をコメントとして扱うので、1行目はコメント
    - [HTML-likeコメント](https://jsprimer.net/basic/comments/)
  - 2~4行目は通常のコメント
