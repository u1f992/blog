## GNU Screen 4.9.1のビルド

https://qiita.com/jp_yen/items/443f29945a154555745c

#### screen.c.patch

```diff
1116a1117
> #ifndef __MSYS__
1118a1120
> #endif
1152a1155
> #ifndef __MSYS__
1154a1158
> #endif
```
