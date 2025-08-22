## GitHub上のPythonパッケージをインストールする

ルートがPythonプロジェクトになっているGitHubリポジトリは`git+https://github.com/～`とすればよいのだけど、例えば[MarkItDown](https://github.com/microsoft/markitdown)はモノレポになっていて、コアとCLIアプリは[packages/markitdown](https://github.com/microsoft/markitdown/tree/main/packages/markitdown)にある。このようなリポジトリに対してはURLフラグメント`subdirectory`を指定するとよい。

- [VCS Support - pip documentation v25.2](https://pip.pypa.io/en/stable/topics/vcs-support/#url-fragments)

`uv tool`や`pipx`と組み合わせるとさらに便利。

```
PS > uv tool install git+https://github.com/microsoft/markitdown#subdirectory=packages/markitdown
```

よく読んだらMarkItDownはPyPIにもアップロードされていた。ぼんやりしていたみたい。
