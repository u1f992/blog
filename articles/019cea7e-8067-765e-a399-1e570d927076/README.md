## Windows 11マシンでSSH Serverを有効化

- https://learn.microsoft.com/ja-jp/windows-server/administration/openssh/openssh_install_firstuse?tabs=powershell&pivots=windows-11

管理者として実行したPowerShellで

```
PS C:\WINDOWS\system32> (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
True
PS C:\WINDOWS\system32> Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'


Name  : OpenSSH.Client~~~~0.0.1.0
State : Installed

Name  : OpenSSH.Server~~~~0.0.1.0
State : NotPresent



PS C:\WINDOWS\system32> Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0


Path          :
Online        : True
RestartNeeded : False



PS C:\WINDOWS\system32> Set-Service -Name sshd -StartupType 'Automatic'
```

再起動後、sshdが自動起動しファイアウォールが自動設定されていることを確認する。

```
PS C:\WINDOWS\system32> Get-Service sshd

Status   Name               DisplayName
------   ----               -----------
Running  sshd               OpenSSH SSH Server


PS C:\WINDOWS\system32> Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue


Name                          : OpenSSH-Server-In-TCP
DisplayName                   : OpenSSH SSH Server (sshd)
Description                   : Inbound rule for OpenSSH SSH Server (sshd)
DisplayGroup                  : OpenSSH Server
Group                         : OpenSSH Server
Enabled                       : True
Profile                       : Private
Platform                      : {}
Direction                     : Inbound
Action                        : Allow
EdgeTraversalPolicy           : Block
LooseSourceMapping            : False
LocalOnlyMapping              : False
Owner                         :
PrimaryStatus                 : OK
Status                        : 規則は、ストアから正常に解析されました。 (65536)
EnforcementStatus             : NotApplicable
PolicyStoreSource             : PersistentStore
PolicyStoreSourceType         : Local
RemoteDynamicKeywordAddresses : {}
PolicyAppId                   :
PackageFamilyName             :
```

デフォルトで`Profile : Private`となっているため、`Public`になっているイーサネットからは接続できない。`Any`（`Private,Public,Domain`）に設定してアドレスを絞る。

また、パスワードが設定されていないとログインできない。

```
PS C:\WINDOWS\system32> Get-NetConnectionProfile


Name                     : ネットワーク 2
InterfaceAlias           : イーサネット
InterfaceIndex           : 10
NetworkCategory          : Public
DomainAuthenticationKind : None
IPv4Connectivity         : Internet
IPv6Connectivity         : Internet



PS C:\WINDOWS\system32> Set-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -Profile Any -RemoteAddress 192.168.0.0/16
```
