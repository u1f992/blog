## PDFから「しおり」を抽出

```
$ pdftk book.pdf dump_data | grep -E 'BookmarkTitle' | python3 -c "import sys, html; [print(html.unescape(line.strip())) for line in sys.stdin]" | grep -E '第[0-9]+章'
```

日本語だとエンコードされてしまうから、Pythonを挟むのが肝
