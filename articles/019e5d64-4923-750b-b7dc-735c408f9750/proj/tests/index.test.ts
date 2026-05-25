import assert from "node:assert/strict";
import { describe, it } from "node:test";

import { add } from "../src/index.ts";

describe("add", () => {
  it("1 + 2 = 3", () => {
    assert.equal(add(1, 2), 3);
  });
});
