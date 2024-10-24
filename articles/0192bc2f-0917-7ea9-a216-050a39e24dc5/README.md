## Windows Terminalでtmuxを起動するワークアラウンド

Windows Terminal内で[`C:/msys64/msys2_shell.cmd -defterm -here -no-start -ucrt64`](https://www.msys2.org/docs/terminals/)等のコマンドで起動したMSYS2シェルではtmuxを起動できない。scriptコマンドを経由することで問題を回避できる。

```console
$ tmux
open terminal failed: not a terminal

$ script --quiet --command tmux /dev/null

$ cat << EOS > /usr/bin/tmux-wt
#!/bin/bash
script --quiet --command tmux /dev/null
EOS
```

https://github.com/microsoft/terminal/issues/5132#issuecomment-1009022843

<!-- あやしい
なお`script.exe`をフルパスで指定すれば、PowerShellからでも起動できる。

```console
> C:\msys64\usr\bin\script.exe -q -c tmux /dev/null
```
-->
