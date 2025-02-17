## `text-box`メモ

```json
  "scripts": {
    "install:browser":"node -e \"process.env.PLAYWRIGHT_BROWSERS_PATH='.playwright';const {spawnSync}=require('child_process');const opts={shell:true,stdio:'inherit'};spawnSync('npx',['playwright','install-deps'],opts);spawnSync('npx',['playwright','install'],opts)\"",
    "vivliostyle":"node -e \"const {spawnSync}=require('child_process');const opts={shell:true,stdio:'inherit'};const fs=require('fs');const path=require('path');spawnSync('npx',['vivliostyle',...process.argv.slice(1),'--executable-browser',(function find(dir){return fs.readdirSync(dir,{withFileTypes:true}).flatMap(entry=>{const fullPath=path.join(dir,entry.name);return entry.isDirectory()?find(fullPath):path.basename(entry.name, path.extname(entry.name)).toLowerCase()==='chrome'&&(process.platform==='win32'?process.env.PATHEXT.split(path.delimiter).map(ext=>ext.toUpperCase()).includes(path.extname(fullPath).toUpperCase()):(fs.statSync(fullPath).mode&0o111)!==0)?[fullPath]:[];});})('.playwright')[0]],opts)\""
  },
```

`package-lock.json`をいじって`npm ci`でも良いかも。

<table>
<tr><td></td><td></td><th colspan="3">直前</th></tr>
<tr><td></td><td></td><th><code>p</code></th><th><code>p</code>以外</th><th>なし</th></tr>
<tr><th rowspan="3">直後</th><th><code>p</code></th><td><code>none</code></td><td><code>trim-start</code></td><td><code>trim-start</code></td></tr>
<tr><th><code>p</code>以外</th><td><code>trim-end</code></td><td><code>trim-both</code></td><td><code>trim-both</code></td></tr>
<tr><th>なし</th><td><code>trim-end</code></td><td><code>trim-both</code></td><td><code>trim-both</code></td></tr>
</table>

こんな感じか……？

```css
p {
    margin: 0;
    text-align: justify;
    text-indent: 1em;
    text-spacing: auto;
    widows: 1;
    orphans: 1;
}

p:first-child:has(+ p), /* コンテナの先頭かつ直後がpである */
:not(p) + p:has(+ p) {  /* 直前にp以外を持ち、かつ直後がpである */
    color: red;
    text-box: trim-start cap alphabetic;
}

p + p:has(+ :not(p)), /* 直前がpであり、かつ直後がp以外である */
p + p:last-child {    /* 直前がpであり、かつコンテナの最後の要素である */
    color: green;
    text-box: trim-end cap alphabetic;
}

:not(p) + p:has(+ :not(p)),/* 前後がpではない */
:not(p) + p:last-child {   /* 直前がpではなく、かつコンテナの最後である */
    color: aqua;
    text-box: trim-both cap alphabetic;
}
```
