## VirtualBoxのディスクイメージの履歴をクリアする

削除したISOがいつまでも表示されてうっとおしい。

https://forums.virtualbox.org/viewtopic.php?t=78320

```
> .\vboxmanage.exe setextradata global "GUI/RecentListCD"
```

`vboxmanage`等のコマンドの使い方わからん。
