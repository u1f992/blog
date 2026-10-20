import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { v7 as uuidv7 } from "uuid";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const readme = path.join(root, "articles", uuidv7(), "README.md");

fs.mkdirSync(path.dirname(readme));
fs.writeFileSync(readme, "");
console.log(path.relative(process.cwd(), readme));
