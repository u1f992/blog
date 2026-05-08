## WSL内にDocker Engineをセットアップし、Windows側にDocker CLIだけ配置する

クリーンなWindows 11環境にWSLをセットアップしUbuntu 24.04をインストールした状態を想定する。

- [Install WSL | Microsoft Learn](https://web.archive.org/web/20260504153105/https://learn.microsoft.com/en-us/windows/wsl/install) ([latest](https://learn.microsoft.com/en-us/windows/wsl/install))

Docker EngineはWSLのディストロ内で、対応する方法でインストールする。`sudo`なしで使用できるところまでセットアップする。

- [Install Docker Engine on Ubuntu | Docker Docs](https://github.com/docker/docs/blob/60163a77f0442205aee2fa8662454e089ab3b67d/content/manuals/engine/install/ubuntu.md) ([latest](https://docs.docker.com/engine/install/ubuntu/))
- [Linux post-installation steps for Docker Engine | Docker Docs](https://github.com/docker/docs/blob/60163a77f0442205aee2fa8662454e089ab3b67d/content/manuals/engine/install/linux-postinstall.md) ([latest](https://docs.docker.com/engine/install/linux-postinstall/))

Ubuntu 24.04では既定でsystemdが有効化されており、通常のUbuntuの手順に従うだけでWSLの起動時にDockerデーモンが自動で起動するようになる。Windowsのブート直後にはWSLは起動していないので、起動ごとの初回利用前には`wsl -- bash -c "until systemctl is-active --quiet docker; do sleep 0.5; done"`でWSLとDockerデーモンの起動を待つ。

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
```

WSL側にはsocat、Windows側には[firejox/WinSocat](https://github.com/firejox/WinSocat)を用意する。後ほど自動起動を設定するのでWinSocatにパスを通す必要はない。WinSocatはNamedPipeServerStreamの既定ACLを使うため、同マシンの他ユーザーからもアクセスできる点に留意すること。

```
$ sudo apt-get install -y socat

PS> $ver  = '0.1.3'
PS> $zip  = Join-Path $env:TEMP "winsocat-$ver.zip"
PS> $dest = Join-Path $env:LOCALAPPDATA 'Programs\winsocat'
PS> if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest | Out-Null }
PS> Invoke-WebRequest -Uri "https://github.com/firejox/WinSocat/releases/download/v$ver/winsocat-portable-x64-$ver.zip" -OutFile $zip -UseBasicParsing
PS> Expand-Archive -Path $zip -DestinationPath $dest -Force
```

ブリッジはWSL側でsystemdサービスとして登録し、Dockerデーモンに紐づけて起動（`Requires`、`After`）終了（`PartOf`）を行なう。

```
$ WINUSER=<myuser>
$ sudo tee /etc/systemd/system/winsocat-docker.service >/dev/null <<UNIT
[Unit]
Description=WinSocat bridge for Docker named pipe
Requires=docker.service
After=docker.service
PartOf=docker.service

[Service]
Type=simple
User=$USER
ExecStart=/mnt/c/Users/$WINUSER/AppData/Local/Programs/winsocat/winsocat.exe NPIPE-LISTEN:docker_engine "WSL:socat STDIO unix-connect:/var/run/docker.sock"
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
UNIT
$ sudo systemctl daemon-reload
$ sudo systemctl enable --now winsocat-docker.service
```

```
> shutdown /s /t 0

> wsl -- bash -c "until systemctl is-active --quiet docker; do sleep 0.5; done"
> docker version --format "client={{.Client.Version}} server={{.Server.Version}}"
client=29.4.3 server=29.4.3

> docker run --rm hello-world
```

<details>
<summary>TCPを直接使用する方法</summary>

技術的には以下でも動作するはずなのだが、Windows→WSL方向のTCP half-close処理について長期間修正されていない問題がある。

- `--interactive`なしの`docker run hello-world`では表示されない（[docker/cli#3586](https://github.com/docker/cli/issues/3586)）。
- さらにstdinがない環境（CI等）では`--interactive`を付けても表示されない（[docker/cli#6220](https://github.com/docker/cli/issues/6220)）。

将来ソケットの変換に疑問を感じたときのために説明を残しておく。

---

まずはデフォルトのNATモードネットワークでのセットアップを説明する。Dockerデーモンを通常の`docker.sock`だけでなく、`0.0.0.0:2375`でも待ち受けさせる。2375はDocker REST API用のwell-knownポート[^well-known]。空の`ExecStart=`が既定の`ExecStart=`をクリアする。

[^well-known]: [Service Name and Transport Protocol Port Number Registry](https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml?search=Docker)

NATモードのWSLでは、`0.0.0.0`にバインドされたサービスがlocalhost forwarderによってWindows側`[::1]`に橋渡しされる。NATモードではWSLのネットワークは`172.x.x.x`に閉じており、`0.0.0.0`にバインドしてもLAN上の他のマシンからはアクセスできない（mirroredモードでは別途考慮事項あり。後述）。

```
$ sudo mkdir -p /etc/systemd/system/docker.service.d
$ sudo tee /etc/systemd/system/docker.service.d/tcp-listener.conf >/dev/null <<'EOF'
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375
EOF
```

WSLがバックグラウンドで終了しないようにする。2つの設定はそれぞれ停止を抑止する対象が違う。`vmIdleTimeout`はVM、`instanceIdleTimeout`はディストロ[^idle-setting]。

[^idle-setting]: [microsoft/WSL#13291](https://github.com/microsoft/WSL/issues/13291)

WinSocatの手順では、Windows側のプロセスが常駐することでタイムアウトが阻害されていたようだ（未確認だが自動終了しないことのみ確か）。

なおこの設定を行ってもWindowsのブート直後はWSLは起動していない。Dockerの利用前一度起こす必要があるのは共通。

```
PS> $content = @"
[wsl2]
vmIdleTimeout=-1

[general]
instanceIdleTimeout=-1
"@
PS> Set-Content -LiteralPath "$env:USERPROFILE\.wslconfig" -Value $content -Encoding ASCII
```

WSLを再起動して設定を反映させる。

```
> wsl --shutdown
```

WinSocatの手順ではWindows版Docker CLIがデフォルトで見に行く`\\.\pipe\docker_engine`を直接作成していたが、TCPの場合は指定する必要がある。`DOCKER_HOST`環境変数では、`localhost`または`tcp://[::1]:2375`とする必要がある。`127.0.0.1`は通らない。挙動から推測するとNATモードのlocalhost forwarderはWindows側にIPv6リスナーのみ作っているようだ。

```
PS> [Environment]::SetEnvironmentVariable('DOCKER_HOST','tcp://localhost:2375','User')
```

```
> shutdown /s /t 0

> wsl -- bash -c "until systemctl is-active --quiet docker; do sleep 0.5; done"
> docker version --format "client={{.Client.Version}} server={{.Server.Version}}"
client=29.4.3 server=29.4.3

> docker run -i --rm hello-world
```

ここで`-i`が必要。

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

mirroredモードではWindows／WSL間のトラフィックがHyper-V firewallを通る。WSLのHyper-V firewallは既定で`DefaultInboundAction=Block`のため、許可に変更しないとWindowsホストからWSL内へ届かない。なお`{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}`はWSL VMの固定ID。WSLソース[`src/windows/common/WslCoreNetworkingSupport.h` L139](https://github.com/microsoft/WSL/blob/478b83e3dff7055d7a976dc5aaa8cc4eec0158d9/src/windows/common/WslCoreNetworkingSupport.h#L139) ([latest](https://github.com/microsoft/WSL/blob/master/src/windows/common/WslCoreNetworkingSupport.h)) に`c_wslFirewallVmCreatorId`として直書きされている。

```
PS> Set-NetFirewallHyperVVMSetting -Name {40E0AC32-46A5-438A-A0B2-2B479E8F2E90} -DefaultInboundAction Allow
```

環境変数`DOCKER_HOST`はIPv4リテラルで指定する。WSL2 mirrored modeはIPv6ループバック（`::1`）を橋渡ししない（[networking.md Mirrored mode networking](https://github.com/MicrosoftDocs/wsl/blob/a3e8ddd36d4c785dca38b9bc2b4a4bd87011096a/WSL/networking.md#mirrored-mode-networking) ([latest](https://learn.microsoft.com/en-us/windows/wsl/networking)): IPv6 localhost address `::1` is not supported.）。

```
PS> [Environment]::SetEnvironmentVariable('DOCKER_HOST','tcp://127.0.0.1:2375','User')
```

</details>
