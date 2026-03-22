## ジャンプホストありのSSH設定

ジャンプホストの設定がないアプリケーションでは、予めSSH設定が必要。

<figure>
<figcaption>~/.ssh/config</figcaption>

```
Host foobar
    HostName 192.168.x.x
    ProxyJump jump-user@jump-host
```

</figure>

```shellsession
$ ssh user@foobar
```

これは`ssh -J jump-user@jump-host user@192.168.x.x`と同じこと。
