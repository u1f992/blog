## シンボリックリンクを含むGitリポジトリ

例：https://github.com/U-1F992/nthaka

`example/lib/nthaka`がリポジトリのルート（`../..`）を指している。

Windowsではこんな感じで作る。

```
> cd example
> sudo cmd /c mklink /D .\lib\nthaka ..\..
```

クローンする時も管理者権限が必要。

```
> sudo git clone -c core.symlink=true https://github.com/U-1F992/nthaka.git
```
