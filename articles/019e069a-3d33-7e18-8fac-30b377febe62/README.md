## WSL内にDocker Engineをセットアップし、Windows側にDocker CLIだけ配置する

クリーンなWindows 11環境にWSLをセットアップしUbuntu 24.04をインストールした状態を想定する。

- [Install WSL | Microsoft Learn](https://web.archive.org/web/20260504153105/https://learn.microsoft.com/en-us/windows/wsl/install) ([latest](https://learn.microsoft.com/en-us/windows/wsl/install))

Docker EngineはWSLのディストロ内で、対応する方法でインストールする。`sudo`なしで使用できるところまでセットアップする。

- [Install Docker Engine on Ubuntu | Docker Docs](https://github.com/docker/docs/blob/60163a77f0442205aee2fa8662454e089ab3b67d/content/manuals/engine/install/ubuntu.md) ([latest](https://docs.docker.com/engine/install/ubuntu/))
- [Linux post-installation steps for Docker Engine | Docker Docs](https://github.com/docker/docs/blob/60163a77f0442205aee2fa8662454e089ab3b67d/content/manuals/engine/install/linux-postinstall.md) ([latest](https://docs.docker.com/engine/install/linux-postinstall/))

Ubuntu 24.04では既定でsystemdが有効化されており、以下の通りDockerデーモンは自動で起動する。

```
$ # ...
$ exit

> wsl --shutdown && wsl

$ docker run hello-world
```

この起動時に、Dockerデーモンを通常の`docker.sock`だけでなく、`0.0.0.0:2375`でも待ち受けさせる。2375はDocker REST API用のwell-knownポート[^well-known]。空の`ExecStart=`が既定の`ExecStart=`をクリアする。

[^well-known]: [Service Name and Transport Protocol Port Number Registry](https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml?search=Docker)

```
$ sudo mkdir -p /etc/systemd/system/docker.service.d
$ sudo tee /etc/systemd/system/docker.service.d/tcp-listener.conf >/dev/null <<'EOF'
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375
EOF
```

NATモードのWSLでは、`0.0.0.0`にバインドされたサービスがlocalhost forwarderによってWindows側`[::1]`に橋渡しされる。NATモードではWSLのネットワークは`172.x.x.x`に閉じており、`0.0.0.0`にバインドしてもLAN上の他のマシンからはアクセスできない（mirroredモードでは別途考慮事項あり。後述）。

WSLがバックグラウンドで終了しないようにする。2つの設定はそれぞれ停止を抑止する対象が違う。`vmIdleTimeout`はVM、`instanceIdleTimeout`はディストロ[^idle-setting]。

[^idle-setting]: [microsoft/WSL#13291](https://github.com/microsoft/WSL/issues/13291)

```
PS> $content = @"
[wsl2]
vmIdleTimeout=-1

[general]
instanceIdleTimeout=-1
"@
PS> Set-Content -LiteralPath "$env:USERPROFILE\.wslconfig" -Value $content -Encoding ASCII
```

バッテリーで動作するラップトップなどではWSL常時起動は避けたい可能性がある。WSLは接続している端末の有無で起動継続を判断しており、Dockerソケットの利用状況は考慮されない。常時起動を用いない場合は、Docker利用中には`wsl`コマンドを起動させたままにすればよいはず。

なおこの設定を行っても、Windowsのブート直後はWSLは起動していない。Dockerの初回利用前に`wsl -- bash -c "until systemctl is-active --quiet docker; do sleep 0.5; done"`などで一度起こす必要がある。

WSLを再起動して設定を反映させる。

```
> wsl --shutdown
```

Docker CLIを適当な場所に起き、パスを通す。WinGetでも取得できるが、レシピは公式ではなくコミュニティが管理しているようだ。直接取得すればよいだろう。

```
PS> wsl -- docker --version
Docker version 29.4.3, build 055a478
PS> $ver  = '29.4.3'
PS> $zip  = Join-Path $env:TEMP "docker-$ver.zip"
PS> $dest = Join-Path $env:LOCALAPPDATA 'Programs'
PS> $bin  = Join-Path $dest 'docker'
PS> if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest | Out-Null }
PS> Invoke-WebRequest -Uri "https://download.docker.com/win/static/stable/x86_64/docker-$ver.zip" -OutFile $zip -UseBasicParsing
PS> Expand-Archive -Path $zip -DestinationPath $dest -Force

PS> $bin = Join-Path $env:LOCALAPPDATA 'Programs\docker'
PS> $userPath = [Environment]::GetEnvironmentVariable('PATH','User')
PS> if (-not ($userPath -split ';' -contains $bin)) { [Environment]::SetEnvironmentVariable('PATH', "$bin;$userPath", 'User') }
PS> [Environment]::SetEnvironmentVariable('DOCKER_HOST','tcp://localhost:2375','User')
```

`DOCKER_HOST`環境変数では、`localhost`または`tcp://[::1]:2375`とする必要がある。挙動から推測するとNATモードのlocalhost forwarderはWindows側にIPv6リスナーのみ作っているようだ。`127.0.0.1`は通らない。

```
> shutdown /s /t 0

> wsl -- bash -c "until systemctl is-active --quiet docker; do sleep 0.5; done"
> docker version --format "client={{.Client.Version}} server={{.Server.Version}}"
client=29.4.3 server=29.4.3

> docker run -i --rm hello-world
```

### 制限

`/mnt`を介してWindows側のディスクを扱うことはできるが、WSLのパス表記で記載する必要がある。

`--interactive`なしの`docker run hello-world`や別途SSHサーバーをセットアップして直接`ssh $HOST docker run hello-world`とすると、出力が表示されない。[docker/cli#4548](https://github.com/docker/cli/pull/4548) 要約：Windows／WSL間のTCPのhalf-closeの扱いに問題がある。

ソケットは平文。`172.x.x.x`に閉じているので他マシンからはアクセスできないが、同マシンの他ユーザーからはアクセスできる（はず）。

### mirrored networkingモードの追加手順

他の要件で`networkingMode=mirrored`にする必要がある場合、いくつか追加の考慮事項がある。

```
PS> $content = @"
[wsl2]
vmIdleTimeout=-1
networkingMode=mirrored

[general]
instanceIdleTimeout=-1
"@
PS> Set-Content -LiteralPath "$env:USERPROFILE\.wslconfig" -Value $content -Encoding ASCII
```

WSL内のdockerdは`127.0.0.1`にバインドする。`0.0.0.0`ではWindows側から公開されてしまい、LAN到達が可能になってしまう。平文なのでこれは避けなければならない。

```
$ sudo mkdir -p /etc/systemd/system/docker.service.d
$ sudo tee /etc/systemd/system/docker.service.d/tcp-listener.conf >/dev/null <<'EOF'
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H unix:///var/run/docker.sock -H tcp://127.0.0.1:2375
EOF
```

mirroredモードではWindows／WSL間ののトラフィックがHyper-V firewallを通る。WSLのHyper-V firewallは既定で`DefaultInboundAction=Block`のため、許可に変更しないとWindowsホストからWSL内へ届かない。なお`{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}`はWSL VMの固定ID。WSLソース[`src/windows/common/WslCoreNetworkingSupport.h` L139](https://github.com/microsoft/WSL/blob/478b83e3dff7055d7a976dc5aaa8cc4eec0158d9/src/windows/common/WslCoreNetworkingSupport.h#L139) ([latest](https://github.com/microsoft/WSL/blob/master/src/windows/common/WslCoreNetworkingSupport.h)) に`c_wslFirewallVmCreatorId`として直書きされている。

```
PS> Set-NetFirewallHyperVVMSetting -Name {40E0AC32-46A5-438A-A0B2-2B479E8F2E90} -DefaultInboundAction Allow
```

環境変数`DOCKER_HOST`はIPv4リテラルで指定する。WSL2 mirrored modeはIPv6ループバック（`::1`）を橋渡ししない（[networking.md Mirrored mode networking](https://github.com/MicrosoftDocs/wsl/blob/a3e8ddd36d4c785dca38b9bc2b4a4bd87011096a/WSL/networking.md#mirrored-mode-networking) ([latest](https://learn.microsoft.com/en-us/windows/wsl/networking)): IPv6 localhost address `::1` is not supported.）。

```
PS> [Environment]::SetEnvironmentVariable('DOCKER_HOST','tcp://127.0.0.1:2375','User')
```
