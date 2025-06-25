## PDF内のラスタ画像を置換

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
