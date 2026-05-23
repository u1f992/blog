## babarot/gomiのインストールスクリプト

- [babarot/gomi](https://github.com/babarot/gomi) ([f6a2c41](https://github.com/babarot/gomi/tree/f6a2c41991e9e6ce073293db5d1ae5d53656295f))

READMEでは以下の手順が第一に挙げられている（[ref](https://github.com/babarot/gomi/blob/f6a2c41991e9e6ce073293db5d1ae5d53656295f/README.md?plain=1#L80)）。

```
$ curl -fsSL https://gomi.dev/install | bash
```

URLは独自ドメインだが、実体は[hack/install](https://github.com/babarot/gomi/blob/f6a2c41991e9e6ce073293db5d1ae5d53656295f/hack/install)を指している。[.github/workflows/pages.yaml](https://github.com/babarot/gomi/blob/f6a2c41991e9e6ce073293db5d1ae5d53656295f/.github/workflows/pages.yaml)によって、mainの更新時にdocs/install/index.htmlが生成されている。

デフォルトのインストール先は~/binになっており、XDG Base Directory Specification（[Version 0.8](https://specifications.freedesktop.org/basedir/0.8/), [latest](https://specifications.freedesktop.org/basedir/latest/)）の~/.local/bin/ではない。なおこのディレクトリは[Version 0.7](https://specifications.freedesktop.org/basedir/0.7/)にはなく、Version 0.8で追加された。特に議論にはなっていないが、READMEにはこのパスも言及されていることから、開発者としても認識した上で~/binにしているのだろう。

`PREFIX`でインストール先を指定できるので問題はない。

```bash
curl -fsSL https://gomi.dev/install | PREFIX=~/.local/bin bash
```
