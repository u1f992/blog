## ChromiumとGhostscriptで表現できる色

5桁の固定小数点で表しているようだ。大した精度ではないな……。

ChromiumでそうなのかGhostscriptでそうなのかはよくわからない。

```javascript
// @ts-check

import child_process from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import { fileURLToPath } from "node:url";
import {
  Worker,
  isMainThread,
  parentPort,
  workerData,
} from "node:worker_threads";

import { Decimal } from "decimal.js";
import { chromium } from "playwright";

if (isMainThread) {
  // ---- Main thread ----

  /**
   * @param {number} bits
   * @param {{ precision?: number }} opts
   */
  function* steps(bits, opts = {}) {
    const precision = opts.precision || 50;
    const D = Decimal.clone({ precision });
    const max = new D(2).pow(bits).minus(1);
    for (let i = new D(0); i.lessThanOrEqualTo(max); i = i.plus(1)) {
      yield i.div(max).toFixed(precision);
    }
  }

  const cpuCount = os.cpus().length;
  const allSteps = Array.from(steps(16, { precision: 50 }));
  /** @type {string[][]} */
  const chunks = Array.from({ length: cpuCount }, () => []);
  allSteps.forEach((step, i) => chunks[i % cpuCount].push(step));

  /** @type {[Set<string>, Set<string>, Set<string>]} */
  const actualSteps = [new Set(), new Set(), new Set()];

  await Promise.all(
    chunks.map(
      (chunk) =>
        /** @type {Promise<void>} */ (
          new Promise((resolve, reject) => {
            const worker = new Worker(fileURLToPath(import.meta.url), {
              workerData: chunk,
            });
            worker.on("message", (partial) => {
              for (let i = 0; i < 3; i++) {
                for (const v of partial[i]) {
                  actualSteps[i].add(v);
                }
              }
              resolve();
            });
            worker.on("error", reject);
            worker.on("exit", (code) => {
              if (code !== 0)
                reject(new Error(`Worker exited with code ${code}`));
            });
          })
        )
    )
  );

  fs.writeFileSync(
    "output.json",
    JSON.stringify(
      actualSteps.map((s) => Array.from(s).sort()),
      null,
      2
    )
  );
} else {
  // ---- Worker thread ----

  /** @type {string[]} */
  const steps = workerData;
  /** @type {[Set<string>, Set<string>, Set<string>]} */
  const partialSteps = [new Set(), new Set(), new Set()];

  const browser = await chromium.launch();
  try {
    for (const c of steps) {
      const page = await browser.newPage();
      await page.setContent(
        `<html><body style="background-color: color(srgb ${c} ${c} ${c})"></body></html>`,
        { waitUntil: "load" }
      );
      const pdf = await page.pdf({
        width: "10px",
        height: "10px",
        printBackground: true,
      });
      new TextDecoder()
        .decode(
          child_process.spawnSync(
            "gswin64c",
            ["-dBATCH", "-dNOPAUSE", "-dPDFDEBUG", "-sDEVICE=nullpage", "-"],
            { input: pdf }
          ).stderr
        )
        .split("\n")
        .map((line) => line.trim())
        .filter((line) => line.endsWith("rg") || line.endsWith("RG"))
        .forEach((line) => {
          const [r, g, b] = line.split(" ").slice(0, 3);
          partialSteps[0].add(r);
          partialSteps[1].add(g);
          partialSteps[2].add(b);
        });
      await page.close();
    }
  } finally {
    await browser.close();
  }

  parentPort?.postMessage(partialSteps.map((s) => Array.from(s)));
}
```

```jsonc
[
  [
    "0",
    "0.000100",
    "0.000200",
    "0.000300",
    "0.000400",
    "0.000500",
    "0.000600",
    "0.000700",
    "0.000800",
    "0.000900",
    "0.001000",
    "0.001100",
    // ...
    "0.999600",
    "0.999700",
    "0.999800",
    "0.999900",
    "1"
  ]
  // ...
]
```

```
> json[0].length
10001
> JSON.stringify(json[0])===JSON.stringify(json[1])
true
> JSON.stringify(json[1])===JSON.stringify(json[2])
true
```
