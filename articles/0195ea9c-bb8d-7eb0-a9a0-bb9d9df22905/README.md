## Vivliostyle CLIでフォルダ内のMarkdownを1ファイルにまとめて組版するスニペット

ファイルをまたぐと改ページされてしまうが、節ごとにファイルを分割したい時もある。最近だと、ファイルは短いほどAIの補助を受けやすそうだ。

watch.jsから`entry`をインポートする際、副作用で1回結合処理が走る。watch.jsをエントリポイントにすると監視を開始する。バックグラウンド実行は`Start-Job`なり`nohup`なりでうまくやる。

ESMなら`process.argv[1] === url.fileURLToPath(import.meta.url)`で同じことができるらしい。

<figure>
<figcaption>watch.js</figcaption>

```js
// @ts-check

/*
 * ```
 * > $job=Start-Job { node watch.js }
 * > npx vivliostyle preview
 * ...
 * > Remove-Job $job -Force
 * ```
 *
 * ```
 * $ node watch.js &
 * $ WATCH_PID=$!
 * $ npx vivliostyle preview
 * ...
 * $ kill $WATCH_PID
 * ```
 */

const fs = require("node:fs");
const path = require("node:path");

const manuscripts = {
  "01-foo": [
    "01-bar.md",
    "02-baz.md",
  ],
  "02-qux": ["01-quux.md"],
};

exports.entry = Object.keys(manuscripts).map((dir) => `${dir}.md`);

/**
 * @param {string[]} lines
 */
function trimEmptyTopAndBottom(lines) {
  const start = lines.findIndex((line) => line.trim() !== "");
  const end =
    lines.length - [...lines].reverse().findIndex((line) => line.trim() !== "");
  return start === -1 ? [] : lines.slice(start, end);
}

/**
 * @param {string[]} filenames
 */
function concatFiles(filenames) {
  return filenames
    .reduce((/** @type {string[]} */ blocks, filename) => {
      const content = fs.readFileSync(filename, "utf-8");
      const lines = content.split(/\r?\n/);
      const trimmedLines = trimEmptyTopAndBottom(lines);
      return trimmedLines.length === 0
        ? blocks
        : blocks.concat(blocks.length > 0 ? [""] : [], trimmedLines);
    }, [])
    .concat([""])
    .join("\n");
}

// Debounce per file to avoid duplicate "change" events, especially in editors like VS Code.
const DEBOUNCE_MS = 100;
const debounceTimers = new Map();

for (const [dirname, filenames] of Object.entries(manuscripts)) {
  const filepaths = filenames.map((filename) =>
    path.posix.join(dirname, filename)
  );
  fs.writeFileSync(`${dirname}.md`, concatFiles(filepaths), {
    encoding: "utf-8",
  });

  if (require.main === module) {
    for (const filepath of filepaths) {
      fs.watch(filepath, (eventType) => {
        if (eventType !== "change") {
          return;
        }

        if (debounceTimers.has(filepath)) {
          clearTimeout(debounceTimers.get(filepath));
        }
        debounceTimers.set(
          filepath,
          setTimeout(() => {
            debounceTimers.delete(filepath);
            console.log(`[${new Date().toISOString()}] Rebuild ${dirname}.md`);
            fs.writeFileSync(`${dirname}.md`, concatFiles(filepaths), {
              encoding: "utf-8",
            });
          }, DEBOUNCE_MS)
        );
      });
    }
  }
}
```

</figure>
<figure>
<figcaption>vivliostyle.config.js</figcaption>

```js
// @ts-check

const { entry } = require("./watch.js");

/** @type {import('@vivliostyle/cli').VivliostyleConfigSchema} */
const vivliostyleConfig = {
  title: "title",
  author: "author",
  language: "ja",
  theme: "./css",
  image: "ghcr.io/vivliostyle/cli:8.19.0",
  entry,
  output: ["./output.pdf"],
  workspaceDir: ".vivliostyle",
};

module.exports = vivliostyleConfig;
```

</figure>
