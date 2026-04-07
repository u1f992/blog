## Claude CodeのDev Containerセットアップを一手でセットアップする

Claude CodeのリポジトリにはDev Containerのセットアップが含まれており、`--dangerously-skip-permissions`とともに紹介されている。

- https://code.claude.com/docs/en/devcontainer

> The container’s enhanced security measures (isolation and firewall rules) allow you to run `claude --dangerously-skip-permissions` to bypass permission prompts for unattended operation.

GitHub CLIを次のように使用すると`git clone`を経由せずにカレントディレクトリに展開できる。`--wildcards`はGNU tar系のオプションなのでMacでは注意（`--include`？）。

```shellsession
$ gh api repos/anthropics/claude-code/tarball/main | tar xz --strip-components=1 --wildcards '*/.devcontainer/*'
```

`--strip-components`は各エントリのパスからN番目以下を詰めるオプション。ダウンロードするtarballは以下のような構造なので、

```shellsession
$ gh api repos/anthropics/claude-code/tarball/main | tar tz | grep '\.devcontainer'
anthropics-claude-code-b543a25/.devcontainer/
anthropics-claude-code-b543a25/.devcontainer/Dockerfile
anthropics-claude-code-b543a25/.devcontainer/devcontainer.json
anthropics-claude-code-b543a25/.devcontainer/init-firewall.sh
```

`anthropics-claude-code-b543a25/`が切り取られてカレントディレクトリに`.devcontainer/`ディレクトリが作成される。

ちなみに`--strip-components=2`ならファイルが直接カレントディレクトリに保存され、`--strip-components=3`以上になると何も保存されない。

