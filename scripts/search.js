import { parseArgs } from "node:util";
import { articles, titleOf } from "./articles.js";

const usage = `使い方: npm run search -- [-s] [-l] <pattern>...

articles/*/README.md を全文検索する。
複数のパターンを指定した場合は、すべてにマッチする記事に絞り込む。

  <pattern>              JavaScript の正規表現
  -s, --case-sensitive   大文字と小文字を区別する
  -l, --list             マッチした行を表示せず、記事のパスとタイトルだけを出力する
  -h, --help             この説明を表示する`;

let args;
try {
  args = parseArgs({
    allowPositionals: true,
    options: {
      "case-sensitive": { type: "boolean", short: "s", default: false },
      list: { type: "boolean", short: "l", default: false },
      help: { type: "boolean", short: "h", default: false },
    },
  });
} catch (error) {
  console.error(`${error.message}\n\n${usage}`);
  process.exit(2);
}

if (args.values.help) {
  console.log(usage);
  process.exit(0);
}
if (args.positionals.length === 0) {
  console.error(`パターンを指定してください。\n\n${usage}`);
  process.exit(2);
}

const flags = args.values["case-sensitive"] ? "" : "i";
let patterns;
try {
  patterns = args.positionals.map((p) => new RegExp(p, flags));
} catch (error) {
  console.error(`正規表現が不正です: ${error.message}`);
  process.exit(2);
}

let hit = false;
for (const { relativePath, lines } of articles()) {
  if (!patterns.every((p) => lines.some((line) => p.test(line)))) {
    continue;
  }
  hit = true;
  console.log(`${relativePath}: ${titleOf(lines)}`);
  if (args.values.list) {
    continue;
  }
  lines.forEach((line, index) => {
    if (patterns.some((p) => p.test(line))) {
      console.log(`  ${index + 1}: ${line}`);
    }
  });
  console.log();
}
process.exit(hit ? 0 : 1);
