import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

export const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

export function articles() {
  const dir = path.join(root, "articles");
  return fs
    .readdirSync(dir)
    .sort()
    .map((id) => path.join("articles", id, "README.md"))
    .filter((relativePath) => fs.existsSync(path.join(root, relativePath)))
    .map((relativePath) => ({
      relativePath,
      lines: fs.readFileSync(path.join(root, relativePath), "utf8").split(/\r?\n/),
    }));
}

export function titleOf(lines) {
  const heading = lines.find((line) => line.startsWith("## "));
  return heading === undefined ? "" : heading.slice(3);
}
