## MSYS2シェル内でvimを開くとき

MSYS2にもVimを入れているけど、こっちのVimはLSPと相性が悪い（LSPの中にはMSYS2形式のパスを食わないものがいる・MSYS2にもNodeが必要・など）

Windows用VimをMSYS2から起動することはできるが、HOME環境変数を参照するため、Vimを直接起動したときとは違うvimrcを参照してしまう。この挙動はしゃらくさくて、MSYS2で開くと`~/.vimrc`Windowsでは`%USERPROFILE%\_vimrc`を開いてくる

ので、HOMEを無効にしつつWindows用vimを開きたい。

```
$ env -u HOME /c/Program\ Files/Vim/vim91/vim.exe

$ alias vim="env -u HOME /c/Program\ Files/Vim/vim91/vim.exe"
```
