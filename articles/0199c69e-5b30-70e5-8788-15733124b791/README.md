## 環境変数の取り扱いの指針

空文字を真とするか迷うことが多い。シェルの挙動では空文字は偽。

```
$ sh -c 'if [ "$VAR" ]; then echo "true"; else echo "false"; fi'
false
$ VAR="" sh -c 'if [ "$VAR" ]; then echo "true"; else echo "false"; fi'
false
$ VAR="foo" sh -c 'if [ "$VAR" ]; then echo "true"; else echo "false"; fi'
true
```

つまりJavaScriptで同じ挙動にするなら単に`!envVar`でよい。おそらくこの理解は因果関係が逆転していて、実際にはJavaScriptがシェルの慣習に合わせたのだろう。

```js
import { inspect } from "node:util";

const envVar = process.env["VAR"];
//    ^? string | undefined

if (!envVar) {
  envVar;
  // ^? "" | undefined
  console.log(`"" or undefined: ${inspect(envVar)}`);
} else {
  envVar;
  // ^? string
  console.log(`string: ${inspect(envVar)}`);
}
```

```
$ node example.js
"" or undefined: undefined
$ VAR="" node example.js
"" or undefined: ''
$ VAR="foo" node example.js
string: 'foo'
```
