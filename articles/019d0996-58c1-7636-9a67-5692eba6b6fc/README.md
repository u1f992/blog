## package.jsonにはコメントを書ける

npmはトップレベルの`"//"`を決して使用せず、package.jsonのコメントとして使用してよいことになっている。

npmの原作者である[Isaac Schlueter](https://github.com/isaacs)氏がNode.jsのメーリングリストで次の通り回答している。

- https://groups.google.com/g/nodejs/c/NmL7jdeuw0M/m/yTqI05DRQrIJ (2013/01/07)

<!-- prettier-ignore-start -->

> As long as I have a say in the matter, package.json file will always<br>
> be json. If anything, future versions of npm and node will *\remove\*<br>
> features rather than add them. (I'm looking at you, \`scripts.install\`<br>
> ;)
> 
> That being said, I completely understand the desire to put additional<br>
> data into your JSON configuration files. That's why the "//" key will<br>
> never be used by npm for any purpose, and is reserved for comments.
> 
> If you want to use a multiple line comment, you can use either an<br>
> array, or multiple "//" keys.
> 
> { "//": "this is the first line of a comment",<br>
> "//": "this is the second line of the comment" }
> 
> { "//": [<br>
> "first line",<br>
> "second line" ] }
> 
> If your editor doesn't display this to your satisfaction, then fix<br>
> your editor. Vim, emacs, sublime text, textmate, and most other<br>
> editors support custom extensions and color schemes. Some of those<br>
> are even open source, so you can really go nuts if you want to.
> 
> You're not a bad person if you use comments in your configs. I would<br>
> tend to read that as a code smell, but the world is a complicated<br>
> place, and we all sometimes do things we're not proud of. If you need<br>
> to add comments to your JSON config file, consider if perhaps the keys<br>
> are not understandable enough, or if there is some more semantic way<br>
> to express what you're trying to do.
> 
> (The point was made about comments in code. I have the same opinion<br>
> there: comments are a sign of an overly complicated or poorly<br>
> understood design. But often it's the lesser evil.)
> 
> Any pull requests to Node, npm, or read-package-json which add<br>
> pre-formatting, cson, package.js, #-comments, etc, will be rejected.<br>
> Patches unwelcome.

<!-- prettier-ignore-end -->

JSDOMのメンテナであり、2014年時点でnpmの重要なコントリビューターであった[Domenic Denicola](https://github.com/domenic)氏も次の通り回答している。

- https://github.com/npm/npm/issues/4482#issuecomment-32267045 (2014/01/14)
- https://github.com/npm/npm/issues/4482#issuecomment-32269036 (2014/01/14)

<!-- prettier-ignore-start -->

> Yeah, this is not happening. You can always use
> 
> ```json
> {
>   "//": "a comment",
>   "//": "another comment"
> }
> ```
> 
> ---
> 
> Notice my comments were at top level.

<!-- prettier-ignore-end -->

以上から、package.jsonには「コメントを書ける」と説明するべきだ。これはハックではなく正当なJSONであり、まず拡張子で嘘をついていない[^extension]。仕様に準拠[^unique-keys]しながらnpmのルールとしてコメントに配慮しているのは、賛同こそすれ糾弾すべき点など決してない。醜いという声もあるようだけれど、美醜の大半は慣れの不足から来るものとすれば、一貫した哲学があり制約に誠実な記法を拒絶することは批判の矛先を誤っている。

[^extension]: 拡張子はテキストファイルが自身の仕様を表現するために許された僅かな空間であるとともに契約でもある。ファイル名や配置によって仕様が変わるとするのは正気の沙汰ではない。筆者はTypeScriptの`tsconfig.json`がJSONを冠しながら実態はJSONCやJSON5ですらない独自処理（<a href="https://github.com/microsoft/TypeScript/blob/v5.9.3/src/compiler/parser.ts#L1646">https://github.com/microsoft/TypeScript/blob/v5.9.3/src/compiler/parser.ts#L1646</a>）であることは、時代をたしかに変えた素晴らしい言語の最悪で取り返しがつかない汚点の一つだとたびたび主張している。VS Codeの設定ファイルについても同様。

[^unique-keys]: ただし「The names within an object SHOULD be unique.」ではある（<a href="https://datatracker.ietf.org/doc/html/rfc8259#section-4">https://datatracker.ietf.org/doc/html/rfc8259#section-4</a>）。データを使用しない約束である以上、文法エラーとなるMUST NOTでなければ問題はないはずだ。

上のコメントの通り、Isaac Schlueter氏は感情的といえるほど強い意思をもってpackage.jsonがJSONであることにこだわっていた。package.jsonはいまや無数のツールがめいめいに読み込む、JavaScriptエコシステムの不動点となっている。package.jsonがJSONに保たれたことによって、今日あらゆるツールが、最も効率的と期待できる容易かつ安全な方法でpackage.jsonを扱うことができている。ツールが現れては消え、分裂し、互換性のない拡張が乱立してきた混沌に満ちた経緯を思えば、package.jsonがJSONであり続けた重み、そして「モダンな」ツールをいくつか取り出して反論してみることがどれほど浅慮かは明らかだ。コメントのための拡張はpackage.jsonで行うべきことではない。たとえばBunが進めるように、パッケージシステムごと新しくこさえるなら一定の正当性があると私は考える。

懸念点があるとすれば、npmが`"//"`を使用しないというルールはnpmのソースコードにもドキュメントにも記録されていないように見えること、また前掲のコメントはnpmのアクティブなメンバーによるものではないということだろうか[^npm-activity]。とはいえnpmの根本的な機能に対して実績のある2名のコメントは、今後この仕様を残すことを求める根拠としては十分だろう。もっとも、Isaac Schlueter氏は上のコメントで「コメントを書きたくなること自体が設計の問題」と指摘している点は覚えておくべきだ。

[^npm-activity]: Isaac Schlueter氏は2021年11月以降npm CLIへの直接的なコードのコミットは行っておらず（<a href="https://github.com/npm/cli/commits/latest/?author=isaacs">https://github.com/npm/cli/commits/latest/?author=isaacs</a>）、執筆時点でnpmのメンバーではない（<a href="https://github.com/orgs/npm/people">https://github.com/orgs/npm/people</a>）。Domenic Denicola氏についても、2014年6月以降はnpm CLI本体での活動は見られない（<a href="https://github.com/npm/cli/commits/latest/?author=domenic">https://github.com/npm/cli/commits/latest/?author=domenic</a>）。
