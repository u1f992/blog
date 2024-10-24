## PDF切り出しに使うTeXのテンプレート

まれによく使う。

```tex
\documentclass{standalone}
\usepackage{graphicx}
\begin{document}

% GIMPにインポートして各座標を調べておく。300dpiはあったほうがいい。単位はbp。
% PDFの座標は左下が0,0であることに要注意。
\includegraphics[page=1, viewport=左下x 左下y 右上x 右上y, clip]{input.pdf}

\end{document}
```
