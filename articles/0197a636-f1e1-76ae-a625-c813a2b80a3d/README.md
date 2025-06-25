## PDF内のビットマップ画像を別の画像に置換するそこそこまともな方法

### Python

- https://stackoverflow.com/questions/34937871/how-can-i-replace-image-in-pdf-programmatically-using-command-line-ideally

```python
import typing
import pymupdf

class PDFImage(typing.NamedTuple):
    """
    https://pymupdf.readthedocs.io/ja/latest/document.html#Document.get_page_images
    """
    xref: int
    smask: int
    width: int
    height: int
    bpc: int
    colorspace: str
    alt_colorspace: str
    name: str
    filter:str
    referencer: int

doc = pymupdf.open("output.pdf")
page = doc[0]
img_list = list(map(lambda x: PDFImage(*x), page.get_images(full=True)))

print(img_list)
# [PDFImage(xref=4, smask=0, width=128, height=128, bpc=8, colorspace='ICCBased', alt_colorspace='', name='X4', filter='FlateDecode', referencer=6)]


new_image = pymupdf.Pixmap("m100_cmyk.tiff")
page.replace_image(4, pixmap=new_image)

doc.save("output_.pdf", garbage=3, deflate=True)
```

```
$ gs -dSAFER -dNOPAUSE -dBATCH -o- -sDEVICE=ink_cov output_.pdf
GPL Ghostscript 10.05.0 (2025-03-12)
Copyright (C) 2025 Artifex Software, Inc.  All rights reserved.
This software is supplied under the GNU AGPLv3 and comes with NO WARRANTY:
see the file COPYING for details.
Processing pages 1 through 1.
Page 1
 0.00000  1.56637  0.00000  0.00000 CMYK OK
```

### JavaScript

```javascript
// @ts-check

import fs from "node:fs";
import * as mupdf from "mupdf";

const doc = mupdf.PDFDocument.openDocument("output.pdf").asPDF();
if (doc === null) {
  throw new Error();
}
const pdfDoc = /** @type {mupdf.PDFDocument} */ (doc);
const page = pdfDoc.loadPage(0);
for (const { key, value, parent } of getPageImages(page)) {
  const image = doc.loadImage(value);

  // const png = image.toPixmap().asPNG();
  // fs.writeFileSync("old.png", png);

  const newImageBuffer = fs.readFileSync("m100_cmyk.tiff");
  const newImageObj = new mupdf.Image(newImageBuffer);
  const newImage = doc.addImage(newImageObj);

  parent.put(key, newImage);
}
const buf = pdfDoc.saveToBuffer();
fs.writeFileSync("new.pdf", buf.asUint8Array());

/**
 * @param {mupdf.PDFPage} page
 *
 * サンプルの関数では`mupdf.Image`を得ることができるが、`mupdf.Image`からは画像を置き換えるためのxrefを取り出せない。 https://mupdfjs.readthedocs.io/en/latest/deprecated.html#extracting-document-images-and-text
 *
 * ```
 * export function getPageImages(page) {
 *   const images = [];
 *   page.toStructuredText("preserve-images").walk({
 *     onImageBlock(bbox, matrix, image) {
 *       images.push({ bbox, matrix, image });
 *     },
 *   });
 *   return images;
 * }
 * ```
 */
export function getPageImages(page) {
  /**
   * @param {mupdf.PDFObject} xobjects
   * @returns {{ key: string | number; value: mupdf.PDFObject; parent: mupdf.PDFObject }[]}
   */
  function getImages(xobjects) {
    const ret = [];
    xobjects.forEach((value, key) => {
      const indirectObj = value;
      const isIndirect = value.isIndirect();
      if (isIndirect) {
        value = value.resolve();
      }

      const subtype = value.get("Subtype");
      if (!subtype.isName()) {
        return;
      }
      const name = subtype.asName();
      if (name === "Image") {
        if (isIndirect) {
          // We need indirect object of image for `PDFDocument.prototype.loadImage`
          // > Load an Image from a PDFObject (typically an indirect reference to an image resource).
          // https://mupdf.readthedocs.io/en/latest/reference/javascript/types/PDFDocument.html#PDFDocument.prototype.loadImage
          ret.push({ key, value: indirectObj, parent: xobjects });
        } else {
          // FIXME: ここに到達することがあるのか不明。対処がこれで正しいかも不明。
          console.warn('name === "Image" && !isIndirect');

          // > Add obj to the PDF as a numbered object, and return an indirect reference to it.
          // https://mupdf.readthedocs.io/en/latest/reference/javascript/types/PDFDocument.html#PDFDocument.prototype.addObject
          ret.push({
            key,
            value: xobjects._doc.addObject(value),
            parent: xobjects,
          });
        }
      } else if (name === "Form") {
        ret.push(...getImages(value.get("Resources").get("XObject")));
      }
    });
    return ret;
  }

  let pageObj = page.getObject();
  if (pageObj.isIndirect()) {
    pageObj = pageObj.resolve();
  }
  return getImages(pageObj.get("Resources").get("XObject"));
}
```

<details>
<summary>素材</summary>

```
$ magick -size 128x128 canvas:black black.png
$ magick -size 128x128 canvas:"cmyk(0,100%,0,0)" -colorspace CMYK m100_cmyk.tiff
```

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Masked Image PDF Test</title>
  <style>
    body {
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
    }
    .circle {
      width: 128px;
      height: 128px;
      border-radius: 50%;
      overflow: hidden;
    }
    .circle img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      display: block;
    }
  </style>
</head>
<body>
  <div class="circle">
    <img src="black.png" alt="Black square image">
  </div>
</body>
</html>
```

</details>
