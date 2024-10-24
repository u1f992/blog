## Invoke-WebRequestのリダイレクトをトレースしたい（wip）

元はといえば（JScriptでも使える）`XMLHttpRequest`がリダイレクトを無効にしたりトレースしたりする機能がないのが悪い。

https://scrapbox.io/nwtgck/fetch()%E3%81%A7%E3%82%82XMLHttpRequest%E3%81%A7%E3%82%82%E3%83%87%E3%83%95%E3%82%A9%E3%83%AB%E3%83%88%E3%81%A7%E3%83%AA%E3%83%80%E3%82%A4%E3%83%AC%E3%82%AF%E3%83%88%E3%82%92%E8%BF%BD%E8%B7%A1%E3%81%97%E3%81%A6XHR%E3%81%A0%E3%81%A8%E3%83%AA%E3%83%80%E3%82%A4%E3%83%AC%E3%82%AF%E3%83%88%E3%81%95%E3%81%9B%E3%81%AA%E3%81%84%E6%96%B9%E6%B3%95%E3%81%AF%E3%81%AA%E3%81%84

```ps1
try { $res = Invoke-WebRequest -Method Head -Uri $uri -MaximumRedirection 0 } catch { $res = $_.Exception.Response }
```

`-MaximumRedirection 0`とすればリダイレクトしたときに`catch`に流れて、例外から`Response`を得られる。成功すればもちろんふつうに取得できる。これをdo-whileループにしたらいけるだろうと思う。
