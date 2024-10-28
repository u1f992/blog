## WindowsにおけるPythonのshebang（？）

- https://qiita.com/snipsnipsnip/items/50e4ca88e3ce3f8cffda

ちなみに`py`ランチャーは`#!/usr/bin/python`をいい感じにしてくれるらしい。

- https://docs.python.org/ja/3/using/windows.html#shebang-lines

ここで話題にするのは、バッチファイルにPythonを埋め込みたいという話。

```
@py -x "%~f0" "%*" & exit /b %errorlevel%

import time

print("Hello")
time.sleep(10000)
```

`py(thon) -x`オプションがキモ。1行目を無視してくれる。

```
> py --help | Select-String -CaseSensitive "^-x"

-x     : skip first line of source, allowing use of non-Unix forms of #!cmd
```

引数のクォーテーション周りの挙動が怪しい気もする？とりあえず全部つけておけば問題ないだろうと思っている。

