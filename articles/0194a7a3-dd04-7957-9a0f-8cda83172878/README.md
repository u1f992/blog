## 漢字かな交じり文の読みを調べる（Windows＋Excel）

- https://learn.microsoft.com/en-us/office/vba/api/excel.application.getphonetic

```ts
import fs from "node:fs";

const winax = await (async () => {
  try {
    return (await import("winax")).default;
  } catch {
    return null;
  }
})();

function withCache(fn: (input: string) => string, cacheFile: string) {
  return (input: string) => {
    const cache = (() => {
      try {
        const parsed = JSON.parse(
          fs.readFileSync(cacheFile, {
            encoding: "utf-8",
          }),
        );
        return parsed && typeof parsed === "object" ? parsed : {};
      } catch {
        return {};
      }
    })() as Record<string, any>;
    if (input in cache) {
      return cache[input];
    }
    cache[input] = fn(input);
    fs.writeFileSync(cacheFile, JSON.stringify(cache), {
      encoding: "utf-8",
    });
    return cache[input];
  };
}

function excelGetPhonetic(input: string) {
  if (winax === null) {
    return input;
  }
  try {
    const excel = new winax.Object("Excel.Application");
    try {
      return excel.GetPhonetic(input) as string;
    } catch {
      return input;
    } finally {
      excel.Quit();
    }
  } catch {
    return input;
  }
}

console.log(withCache(excelGetPhonetic, "cache.json")("寿限無"));
```
