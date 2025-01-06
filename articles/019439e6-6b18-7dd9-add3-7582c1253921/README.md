## コマンドプロンプトの起動時スクリプト

- https://github.com/Schniz/fnm?tab=readme-ov-file#windows-command-prompt-aka-batch-aka-wincmd
- https://superuser.com/questions/144347/is-there-windows-equivalent-to-the-bashrc-file-in-linux/144348#144348
- https://ss64.com/nt/cmd.html

```
> reg add "HKEY_CURRENT_USER\Software\Microsoft\Command Processor" /v AutoRun /t REG_SZ /d "%USERPROFILE%\autorun.cmd" /f
```

なお初期値は設定なし

