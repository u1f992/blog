## ES3相当のJavaScriptでUUID風文字列を生成する

```js
/**
 * RFC4122 version 4 compliant UUID generator
 *
 * Based on: https://stackoverflow.com/a/8809472 (Public Domain / MIT)
 *
 * @returns {string}
 */
function generateUUID() {
  var d = new Date().getTime(); // Timestamp
  var d2 = // Time in microseconds since page-load or 0 if unsupported
    typeof performance !== "undefined" && performance.now
      ? performance.now() * 1000
      : 0;
  return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function (c) {
    var r = Math.random() * 16; // random number between 0 and 16
    if (d > 0) {
      // Use timestamp until depleted
      r = (d + r) % 16 | 0;
      d = Math.floor(d / 16);
    } else {
      // Use microseconds since page-load if supported
      r = (d2 + r) % 16 | 0;
      d2 = Math.floor(d2 / 16);
    }
    return (c === "x" ? r : (r & 0x3) | 0x8).toString(16);
  });
}

WScript.Echo(generateUUID());
```
