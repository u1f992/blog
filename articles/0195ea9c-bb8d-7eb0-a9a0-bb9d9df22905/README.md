## Vivliostyle CLIでフォルダ内のMarkdownを1ファイルにまとめて組版するスニペット

出力HTMLは別ディレクトリに置いたほうがよさそう。

この方法だとリアルタイムプレビューが効かない。vivliostyle.config.jsに埋め込むのではなく別スクリプトで用意しておいて、[paulmillr/chokidar](https://github.com/paulmillr/chokidar)とかで監視して（別ディレクトリに）出力したほうがいいかも。

<figure>
<figcaption>vivliostyle.config.js</figcaption>

```js
// @ts-check

const fs = require("node:fs");
const path = require("node:path");

/**
 * @param {string} dir
 */
function getMarkdownFiles(dir) {
  return fs
    .readdirSync(dir)
    .filter((filename) => filename.endsWith(".md"))
    .sort()
    .map((filename) => path.posix.join(dir, filename));
}
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
  return (
    filenames
      .reduce((/** @type {string[]} */ blocks, filename) => {
        const content = fs.readFileSync(filename, "utf-8");
        const lines = content.split(/\r?\n/);
        const trimmedLines = trimEmptyTopAndBottom(lines);
        if (trimmedLines.length === 0) {
          return blocks;
        }
        if (blocks.length > 0) {
          blocks.push("");
        }
        return blocks.concat(trimmedLines);
      }, [])
      .join("\n") + "\n"
  );
}
/**
 * @param {string} dir
 */
function concatMarkdownFiles(dir) {
  const outputPath = path.join(dir, "_.md");
  const files = getMarkdownFiles(dir).filter(
    (file) => path.resolve(file) !== path.resolve(outputPath)
  );
  const content = concatFiles(files);
  fs.writeFileSync(outputPath, content, { encoding: "utf-8" });
  return outputPath;
}

/** @type {import('@vivliostyle/cli').VivliostyleConfigSchema} */
const vivliostyleConfig = {
  title: "title",
  author: "author",
  language: "ja",
  theme: "./css",
  image: "ghcr.io/vivliostyle/cli:8.19.0",
  entry: [
    concatMarkdownFiles("01"),
    concatMarkdownFiles("02"),
    /* ... */
  ],
  output: ["./output.pdf"],
  workspaceDir: ".vivliostyle",
};

module.exports = vivliostyleConfig;
```

</figure>
