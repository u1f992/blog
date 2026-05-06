## SSH接続先のWindowsでDocker Desktopを起動する

SSH接続ではクレデンシャルヘルパーが失敗する（[docker/cli#4353](https://github.com/docker/cli/issues/4353)）。

```
$ ssh "$HOST"

> powershell
PS> $DBIN = "C:\Program Files\Docker\Docker\resources\bin"

PS> # 元のクレデンシャルヘルパーを退避
PS> if (Test-Path "$DBIN\docker-credential-desktop.exe") { Move-Item "$DBIN\docker-credential-desktop.exe" "$DBIN\docker-credential-desktop.exe.bak" -Force }

PS> # ダミー実行ファイルを注入
PS> @'
@echo off
if /I %1==list (echo {} & exit /b 0)
if /I %1==get (echo credentials not found in native keychain & exit /b 1)
exit /b 0
'@ | Set-Content -LiteralPath "$DBIN\docker-credential-desktop.bat" -Encoding ASCII -NoNewline

PS> wsl

wsl$ # WSL側のダミー実行ファイルをXDG Base Directoryに注入
wsl$ mkdir -p ~/.local/bin
wsl$ cat > ~/.local/bin/docker-credential-desktop.exe <<'EOF'
#!/bin/sh
exec /mnt/c/Windows/System32/cmd.exe /c 'C:\Program Files\Docker\Docker\resources\bin\docker-credential-desktop.bat' "$@"
EOF
wsl$ chmod +x ~/.local/bin/docker-credential-desktop.exe
```

```
$ ssh "$HOST"

> powershell
PS> # Docker Desktopを開始
PS> Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
PS> wsl -- bash -c "until docker info >/dev/null 2>&1; do sleep 3; done"

PS> # Windows側でのpull
PS> docker pull hello-world
PS> docker run --rm hello-world
PS> docker rmi --force hello-world

PS> # WSL側でのpull
PS> wsl
wsl$ docker pull hello-world
wsl$ docker run --rm hello-world
wsl$ docker rmi --force hello-world
wsl$ exit

PS> # XDG Base DirectoryのPATHへの追加は.profileで行われているので、bashコマンドから直接行なう場合はl（ログイン）オプションが必要
PS> # 別の方法：.bashrcを編集する、都度PATH=$HOME/.local/bin:$PATHをつける
PS> wsl -- bash -lc "docker pull hello-world && docker run --rm hello-world"
```

`ssh "$HOST" '<command>'`形式のワンショットセッションはConsole側ログオンを持たないため`Start-Process`（`cmd /c start`）ではDocker Desktopが立たない。タスクスケジューラ経由で起動するためのタスク定義を仕込んで実行する。

`-LogonType S4U`（Service-for-User）を必ず指定する。既定の`InteractiveToken`だとタスクスケジューラが「mukaiの対話ログオンセッションを探して、そのトークンで起動」を試み、対話ログオンが現存しない時には`/run`が成功を返しても実体は走らない（`LastTaskResult:267011 = SCHED_S_TASK_HAS_NOT_RUN`）。S4Uはパスワード無しで非対話セッション0上にプロセスを生成する。Docker Desktopのバックエンドはセッション0でも問題なく動作しengineが立ち上がる。

```
$ ssh "$HOST" 'powershell -NoProfile -Command "Register-ScheduledTask -TaskName StartDockerDesktop -Action (New-ScheduledTaskAction -Execute \"C:\Program Files\Docker\Docker\Docker Desktop.exe\") -Trigger (New-ScheduledTaskTrigger -Once -At \"00:00\") -Principal (New-ScheduledTaskPrincipal -UserId mukai -LogonType S4U) -Force | Out-Null"'
```

以降は`Start-Process`の代わりに`schtasks /run`を叩けばよい。Docker Desktop側の対応で、何度実行しても複数起動しないようになっているようだ。

```
$ ssh "$HOST" schtasks /run /tn StartDockerDesktop
$ ssh "$HOST" 'wsl -- bash -c "until docker info >/dev/null 2>&1; do sleep 3; done"'
$ ssh "$HOST" docker pull hello-world
$ ssh "$HOST" docker run --rm hello-world
```
