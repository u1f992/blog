## 「Dockerを使える環境」のバリエーション

マルチプラットフォーム（ここではLinux／Windows／macOS対応）で動作するアプリケーションで、Dockerコマンドに素朴にパスが通っていることを前提とした機能を実装する場合に想定すべき状況について整理します。

<table>
<tr><td></td><th>Docker Engineのみ</th><th>Docker Desktopあり</th></tr>
<tr><th>Linux</th><td><a href="#linux--docker-engineのみ">↩</a></td><td><a href="#docker-desktop-for-linux">↩</a></td></tr>
<tr><th>Windows</th><td><a href="#非linuxプラットフォームでdocker-engineを直接インストール">↩</a></td><td><a href="#docker-desktop-for-windowsmac">↩</a></td></tr>
<tr><th>macOS</th><td><a href="#非linuxプラットフォームでdocker-engineを直接インストール">↩</a></td><td><a href="#docker-desktop-for-windowsmac">↩</a></td></tr>
</table>

### Linux + Docker Engineのみ

この文書で整理する中で最もストレートで、他の基盤となっているセットアップです。

- [Install Docker Engine on Ubuntu | Docker Docs](https://github.com/docker/docs/blob/60163a77f0442205aee2fa8662454e089ab3b67d/content/manuals/engine/install/ubuntu.md) ([latest](https://docs.docker.com/engine/install/ubuntu/))

### Docker Desktop for Windows／Mac

Linux以外におけるストレートなセットアップです。Docker（Engine）は本来Linux固有の機能で構成された技術[^windows-container]であり、非Linuxプラットフォームで動作させるためには何らかの手段でLinuxを動作させる必要があります。Docker Desktopはこの内部Linux VMの管理と、ネットワークやファイルシステムといったホスト側システムとの透過的な統合などを担っています。WindowsではWSL[^wsl2]／Hyper-V[^hyper-v]、macOSではVirtualization.framework[^mac-deprecated-vmm]上でLinuxを動作させています。

[^windows-container]: Windowsコンテナについてはよく知りませんが、コンテナという概念をWindowsカーネルの分離機構で実現したものと理解しています。

[^wsl2]: Microsoftのドキュメントにならって、WSL 2を単にWSLと呼びます。

[^hyper-v]: Hyper-Vが有効なエディション（Pro／Enterprise／Education）でのみ使用可能です。これらにおいてもWSLが有効な場合はWSLが既定になるとみられます（未確認）。（[Docker Desktop WSL 2 backend on Windows | Docker Docs](https://github.com/docker/docs/blob/60163a77f0442205aee2fa8662454e089ab3b67d/content/manuals/desktop/features/wsl/_index.md) ([latest](https://docs.docker.com/desktop/features/wsl/))）

[^mac-deprecated-vmm]: macOSではその他deprecatedなオプションとして、QEMU／HyperKit（Intel-based）を選択できます。（[Virtual Machine Manager for Docker Desktop on Mac | Docker Docs](https://github.com/docker/docs/blob/60163a77f0442205aee2fa8662454e089ab3b67d/content/manuals/desktop/features/vmm.md) ([latest](https://docs.docker.com/desktop/features/vmm/))）。

従業員250名以上あるいは年間売上1,000万USD（または同等の現地通貨）以上の事業利用には有償サブスクリプションが必要です[^docker-license]。

[^docker-license]: [Docker Desktop license agreement | Docker Docs](https://github.com/docker/docs/blob/60163a77f0442205aee2fa8662454e089ab3b67d/content/manuals/subscription/desktop-license.md) ([latest](https://docs.docker.com/subscription/desktop-license/))

- [Install WSL | Microsoft Learn](https://web.archive.org/web/20260504153105/https://learn.microsoft.com/en-us/windows/wsl/install) ([latest](https://learn.microsoft.com/en-us/windows/wsl/install))
- [Install Docker Desktop on Windows | Docker Docs](https://github.com/docker/docs/blob/60163a77f0442205aee2fa8662454e089ab3b67d/content/manuals/desktop/setup/install/windows-install.md) ([latest](https://docs.docker.com/desktop/setup/install/windows-install/))
- [Install Docker Desktop on Mac | Docker Docs](https://github.com/docker/docs/blob/60163a77f0442205aee2fa8662454e089ab3b67d/content/manuals/desktop/setup/install/mac-install.md) ([latest](https://docs.docker.com/desktop/setup/install/mac-install/))
  - メモ：インストールはヘッドレスでできるが、GUIで初回起動しないとPATHを通してもらえない。
    - Allow "Docker" to find devices on local networks? -> Allow
    - Docker Subscription Service Agreement -> Accept
    - Use recommended settings (requires password) -> Finish
    - Welcome to Docker -> Skip
  - メモ：Docker Desktopを起動しないとDockerデーモンも起動しない。Docker Desktopはログイン済みでないと起動しない。`% open -a Docker  The application /Applications/Docker.app cannot be opened for an unexpected reason, error=Error Domain=RBSRequestErrorDomain Code=5 "Launch failed." UserInfo={NSLocalizedFailureReason=Launch failed., NSUnderlyingError=0x600003c9e670 {Error Domain=OSLaunchdErrorDomain Code=125 "Domain does not support specified action" UserInfo={NSLocalizedFailureReason=Domain does not support specified action}}}`　ヘッドレス運用のためには自動ログインを構成する必要がある

### Docker Desktop for Linux

Docker DesktopはLinuxにも提供されています。これは他のプラットフォームと同様に専用のVMを内部で動作させる仕組みになっており、Docker Engineの単体利用とは根本的に異なるものです。

- [Install Docker Desktop on Linux | Docker Docs](https://github.com/docker/docs/blob/60163a77f0442205aee2fa8662454e089ab3b67d/content/manuals/desktop/setup/install/linux/_index.md) ([latest](https://docs.docker.com/desktop/setup/install/linux/))

### 非LinuxプラットフォームでDocker Engineを直接インストール

WindowsではWSLに直接、macOSでは別途薄いLinux VM管理層を用いて、Docker Engineのみをインストールすることが可能です。macOSでの管理層について、執筆時点では[Colima](https://github.com/abiosoft/colima)が最も有名（28.6k stars）であるようです。

- [colima/README.md at v0.10.1 · abiosoft/colima](https://github.com/abiosoft/colima/blob/v0.10.1/README.md) ([latest](https://github.com/abiosoft/colima/blob/main/README.md))
