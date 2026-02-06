## PDFの指定したページをトリミングして出力

```
$ docker run --rm --mount type=bind,source=.,target=/workdir --user texlive --entrypoint /usr/local/texlive/2024/bin/x86_64-linux/pdfjam registry.gitlab.com/islandoftex/images/texlive:TL2024-historic-doc --trim "左 下 右 上" --clip true --fitpaper true input.pdf -o output.pdf
```

```
  --KEY VALUE
               Specify options to '\includepdfmerge', in the LaTeX
               'pdfpages' package.  See the the pdfpages documentation
               (usually 'texdoc pdfpages') for more information.
               Here KEY is the name of any of the many options for
               '\includepdfmerge', and VALUE is a corresponding value.
               Examples:
                   --nup 2x1     (for 2-up side-by-side imposition)
                   --scale 0.7   (to scale all input pages to 70% size)
                   --offset '1cm 0.5cm'
                                 (to offset all pages -- note the quotes!)
                   --frame true  (to put a frame round each input page)
                   --booklet true (to reorder the pages in signatures,
                                   generally useful with --nup)
                   --signature N (specify the signature size, as the
                                  number of original pages in a signature
                                  in the final document. Caveat: booklet
                                  is a short form for signature, so if
                                  you use booklet true, signature will be
                                  ignored)
                   --trim '1cm 2cm 1cm 2cm' --clip true
                                 (to trim those amounts from left, bottom,
                                  right and top, respectively, of input
                                  pages)
                   --angle NNN (The angle of rotation in degrees. Angles
                                that are not either 90, 180 or 270 will
                                still create straight rectangular pages,
                                only the content will be rotated.)
               etc., etc.  For more information see the manual for
               the 'pdfpages' package, at
               https://www.ctan.org/tex-archive/macros/latex/contrib/pdfpages
```

<!--
docker run --rm --mount type=bind,source=.,target=/workdir --user texlive --entrypoint /usr/local/texlive/2024/bin/x86_64-linux/pdfjam registry.gitlab.com/islandoftex/images/texlive:TL2024-historic-doc --trim "380.6mm 35.3mm 167.6mm 35.3mm" --clip true --fitpaper true input.pdf -o output.pdf

上35.3mm
左380.6mm
下35.3mm
右167.6mm
-->

<details>
<summary>過去のメモ</summary>

メモ：こっちのほうが楽かも

```python
import fitz


def in2pt(in_: float) -> float:
    return in_ * 72


LEFT_PAGE = (
    in2pt(1.857),
    in2pt(1.85),
    in2pt(1.857) + in2pt(5.83),
    in2pt(1.85) + in2pt(8.27),
)
RIGHT_PAGE = (
    in2pt(8.867),
    in2pt(1.85),
    in2pt(8.867) + in2pt(5.83),
    in2pt(1.85) + in2pt(8.27),
)

pdf = fitz.open("../../Downloads/cover0325.pdf")
dst = fitz.open()

for page, cropbox in (
    (0, LEFT_PAGE),
    (1, LEFT_PAGE),
    # (5, RIGHT_PAGE),
    (7, LEFT_PAGE),
    (7, RIGHT_PAGE),
    # (10, LEFT_PAGE),
):
    pdf[page].set_cropbox(fitz.Rect(*cropbox))
    dst.insert_pdf(pdf, page, page)

dst.save("out.pdf")
```

座標指定は左下原点のbp

#### pdfcroppages.py

```py
import argparse
import os
import pathlib
import subprocess
import tempfile


def parse_pages(raw: str):
    pages: list[int] = []
    parts = raw.split(",")
    for part in parts:
        if "-" in part:
            start, end = map(int, part.split("-"))
            pages.extend(range(start, end + 1))
        else:
            pages.append(int(part))
    return pages


def generate_cropping_tex(
    page: int, viewport: tuple[float, float, float, float], posix_rel_path: str
):
    return f"""\\documentclass{{standalone}}
\\usepackage{{graphicx}}
\\begin{{document}}
\\includegraphics[page={page}, viewport={" ".join([str(coord) for coord in viewport])}, clip]{{{posix_rel_path}}}
\\end{{document}}
"""


def run_pdflatex(input: pathlib.Path):
    _ = subprocess.run(
        ["pdflatex", "-output-directory", str(input.parent), str(input)],
        check=True,
        capture_output=True,
    )
    assert input.with_suffix(".aux").exists()
    assert input.with_suffix(".log").exists()
    assert input.with_suffix(".pdf").exists()


def run_pdfunite(input: list[pathlib.Path], output: pathlib.Path):
    _ = subprocess.run(
        [
            "pdfunite",
            *[str(_) for _ in input],
            str(output),
        ],
        check=True,
        capture_output=True,
    )
    assert output.exists()


def main():
    parser = argparse.ArgumentParser(
        description="Crop a PDF file using a specified box"
    )
    parser.add_argument("input", type=str, help="Path to the input PDF file")
    parser.add_argument("pages", type=str, help="Comma-separated list of pages to crop")
    parser.add_argument("lx", type=float, help="X-coord of the bottom-left corner")
    parser.add_argument("ly", type=float, help="Y-coord of the bottom-left corner")
    parser.add_argument("rx", type=float, help="X-coord of the top-right corner")
    parser.add_argument("ry", type=float, help="Y-coord of the top-right corner")
    parser.add_argument("output", type=str, help="Path to the output PDF file")
    args = parser.parse_args()

    INPUT = pathlib.Path(args.input).resolve()
    OUTPUT = pathlib.Path(args.output).resolve()
    PAGES = parse_pages(args.pages)

    pdfs: list[pathlib.Path] = []

    for page in PAGES:
        temp = tempfile.NamedTemporaryFile(delete=False, suffix=".tex")
        try:
            temp_path = pathlib.Path(temp.name).resolve()
            input_posix_rel_path = INPUT.relative_to(
                temp_path.parent, walk_up=True
            ).as_posix()

            with open(temp.name, "w", encoding="utf-8") as f:
                f.write(
                    generate_cropping_tex(
                        page,
                        (args.lx, args.ly, args.rx, args.ry),
                        input_posix_rel_path,
                    )
                )

            run_pdflatex(temp_path)
            pdfs.append(temp_path.with_suffix(".pdf"))

            for suffix in [".aux", ".log"]:
                os.remove(str(temp_path.with_suffix(suffix)))

        finally:
            temp.close()  # Automatically removed

    try:
        # FIXME: pdfunite crashes with absolute input paths.
        cwd = pathlib.Path.cwd()
        run_pdfunite([pdf.relative_to(cwd, walk_up=True) for pdf in pdfs], OUTPUT)

    finally:
        for pdf in pdfs:
            os.remove(str(pdf))


if __name__ == "__main__":
    main()
```

</details>
