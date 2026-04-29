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
