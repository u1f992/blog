## CSS `rgb()`の小数点数を特定要素に設定する

Chromiumにおいて、[`rgb()`](https://developer.mozilla.org/ja/docs/Web/CSS/color_value/rgb)関数は小数点数も受け付けるし、PDF出力にもちゃんと反映されるけど、特定要素のスタイルとして設定する場合には<code>elem.setAttribute("style", &#96;${elem.getAttribute("style")}; background-color: rgb(0 0.1 0.2);&#96;)</code>としなければ丸められてしまう。

[村上さん](https://github.com/vivliostyle/vivliostyle.js/issues/1432#issuecomment-2552691859)によれば、丸める挙動は好ましくはないけどバグとは言えないらしい。

> The precision with which sRGB component values are retained, and thus the number of significant figures in the serialized value, is not defined in this specification, but must at least be sufficient to round-trip eight bit values. Values must be rounded towards +∞, not truncated. ――https://drafts.csswg.org/css-color-4/#css-serialization-of-srgb

```
> python main.py
elem_style_setProperty
 0 0 0 rg
---
elem_style_backgroundColor
 0 0 0 rg
---
elem_style[backgroundColor]
 0 0 0 rg
---
elem_getAttribute_setAttribute
 0 0.000400 0.000800 rg
---
```

<details>
<summary>main.py</summary>

```py
import os
import pathlib
import subprocess

from playwright.sync_api import sync_playwright


def generate_pdf(html_content: str, script: str, output: pathlib.Path):
    with (
        sync_playwright() as playwright,
        playwright.chromium.launch(headless=False) as browser,
        browser.new_context() as context,
        context.new_page() as page,
    ):
        page.set_content(html_content)
        page.evaluate(script)
        # input("press enter")
        page.pdf(path=output, print_background=True)


def extract_rgb_fill_from_pdf(pdf_path: pathlib.Path) -> str:
    return "\n".join(
        [
            line
            for line in subprocess.run(
                [
                    "gswin64c",
                    "-dPDFDEBUG",
                    "-dBATCH",
                    "-dNOPAUSE",
                    "-sDEVICE=nullpage",
                    str(pdf_path),
                ],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
            ).stderr.splitlines()
            if " rg" in line
        ]
    )


def main():
    cwd = pathlib.Path.cwd()

    html_content = """
<html>
  <body>
    <div
      id="elem"
      style="display: inline-block; width: 100px; height: 100px"
    ></div>
  </body>
</html>
"""

    for title, script in (
        (
            "elem_style_setProperty",
            'document.getElementById("elem").style.setProperty("background-color", "rgb(0 0.1 0.2)");',
        ),
        (
            "elem_style_backgroundColor",
            'document.getElementById("elem").style.backgroundColor = "rgb(0 0.1 0.2)";',
        ),
        (
            "elem_style[backgroundColor]",
            'document.getElementById("elem").style["backgroundColor"] = "rgb(0 0.1 0.2)";',
        ),
        (
            "elem_getAttribute_setAttribute",
            'const elem = document.getElementById("elem"); elem.setAttribute("style", `${elem.getAttribute("style")}; background-color: rgb(0 0.1 0.2);`);',
        ),
    ):
        print(title)
        output_pdf = cwd.joinpath(f"{title}.pdf")
        try:
            generate_pdf(
                html_content,
                script,
                output_pdf,
            )
            print(extract_rgb_fill_from_pdf(output_pdf))
        finally:
            if output_pdf.exists():
                os.remove(output_pdf)
        print("---")


if __name__ == "__main__":
    main()
```

</details>
