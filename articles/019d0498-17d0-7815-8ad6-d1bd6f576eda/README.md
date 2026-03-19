## GitHub CLIにはgitignoreを生成する機能がある

- https://cli.github.com/manual/gh_repo_gitignore

```
$ gh repo gitignore list | grep Node
Node
$ gh repo gitignore view Node > .gitignore
```

