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

2026年5月5日現在（[9fce4e6](https://github.com/anthropics/claude-code/tree/9fce4e6ed16244127de19b1eee02508c6dc2d29e)）、[anthropics/claude-code#55623](https://github.com/anthropics/claude-code/issues/55623)の影響で、同梱されているinit-firewall.shが正しく動作しない。

<figure>
<figcaption>fix-statsig-resolve-55623.patch</figcaption>

```patch
--- a/.devcontainer/init-firewall.sh
+++ b/.devcontainer/init-firewall.sh
@@ -76,14 +76,14 @@
     echo "Resolving $domain..."
     ips=$(dig +noall +answer A "$domain" | awk '$4 == "A" {print $5}')
     if [ -z "$ips" ]; then
-        echo "ERROR: Failed to resolve $domain"
-        exit 1
+        echo "WARNING: Failed to resolve $domain (skipping)"
+        continue
     fi
     
     while read -r ip; do
         if [[ ! "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
-            echo "ERROR: Invalid IP from DNS for $domain: $ip"
-            exit 1
+            echo "WARNING: Invalid IP from DNS for $domain: $ip (skipping)"
+            continue
         fi
         echo "Adding $ip for $domain"
         ipset add allowed-domains "$ip"
```

</figure>
