## PDFの指定したページをトリミングして出力

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
