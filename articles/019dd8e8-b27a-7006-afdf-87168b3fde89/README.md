## mise

- https://github.com/jdx/mise

今度VFMで使うので勉強する。

### インストール

- https://github.com/jdx/mise/blob/0c645defc0e5794528ec2ee48084e463fbe51845/README.md#quickstart

```shellsession
$ curl https://mise.run | sh
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 10669  100 10669    0     0  86258      0 --:--:-- --:--:-- --:--:-- 86739
mise: installing mise...
######################################################################## 100.0%
mise: installed successfully to /home/mukai/.local/bin/mise
mise: run the following to activate mise in your shell:
echo "eval \"\$(/home/mukai/.local/bin/mise activate bash)\"" >> ~/.bashrc

mise: run `mise doctor` to verify this is set up correctly
$ echo "eval \"\$(/home/mukai/.local/bin/mise activate bash)\"" >> ~/.bashrc
$ cat .bashrc | tail -n 1
eval "$(/home/mukai/.local/bin/mise activate bash)"
```

シェルを再起動して

```shellsession
$ mise doctor
version: 2026.4.25 linux-x64 (2026-04-28)
activated: yes
shims_on_path: no
self_update_available: yes
...
No problems found
```

### 使い方を覚える

単発でnodeを実行する

```shellsession
$ mise exec node@24 -- which node
gpg: 2026年04月16日 16時15分43秒 JSTに施された署名
gpg:                EDDSA鍵5BE8A3F6C8A5C01D106C0AD820B1A390B168D356を使用
gpg: "Antoine du Hamel <antoine.duhamel@platformatic.dev>"からの正しい署名 [不明の]
gpg:                 別名"Antoine du Hamel <duhamelantoine1995@gmail.com>" [不明の]
node@24.15.0    11.12.1                                                        ✔
/home/mukai/.local/share/mise/installs/node/24/bin/node
$ mise exec node@22 -- which node
gpg: 2026年03月25日 05時37分28秒 JSTに施された署名
gpg:                RSA鍵890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4を使用
gpg: "RafaelGSS <rafael.nunu@hotmail.com>"からの正しい署名 [不明の]
node@22.22.2    10.9.7                                                         ✔
/home/mukai/.local/share/mise/installs/node/22/bin/node
```

プロジェクトで使用するNode.jsのバージョンを固定する

```shellsession
$ mkdir {a,b}
$ cd a && mise use node@22 && cd ..
node@22.22.2
mise /tmp/tmp.1fxOWzjxzs/a/mise.toml tools: node@22.22.2
$ cd b && mise use node@24 && cd ..
node@24.15.0
mise /tmp/tmp.1fxOWzjxzs/b/mise.toml tools: node@24.15.0
$ cd b
b$ node -v
v24.15.0
b$ cd ../a
a$ node -v
v22.22.2
```
