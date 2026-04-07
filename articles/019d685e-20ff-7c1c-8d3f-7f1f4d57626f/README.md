## このローカルリポジトリでだけ一時的に特定のファイルの変更を無視したい

`.git/info/exclude`に書き込む。たとえば.devcontainer/ディレクトリを無視したい場合

```shellsession
$ echo ".devcontainer/" >> .git/info/exclude
```

