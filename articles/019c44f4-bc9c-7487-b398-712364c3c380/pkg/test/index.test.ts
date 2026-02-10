import assert from "node:assert";
import test from "node:test";

import { HOGE } from "../src/index.ts";

test(() => {
  assert.deepStrictEqual(HOGE, "なんらか");
});
