import fs from "node:fs";
import path from "node:path";
import { articles, root, titleOf } from "./articles.js";

const entries = articles().map(({ relativePath, lines }) => `- [${titleOf(lines)}](${relativePath})\n`);
fs.writeFileSync(path.join(root, "README.md"), `# 雑記帳\n\n${entries.join("")}`);
