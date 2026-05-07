## DHCPでIPv4を掴みそこねているLinuxクライアントにSSHアクセスする

Raspberry Pi 4 Model Bをセットアップした。Raspberry Pi Imager経由でUbuntu Server 24.04をダウンロードしmicroSDに書き込んだ。オプションでユーザーを作成し、SSHも有効にしておいた。しかし起動しても`sudo arp-scan -I br0 --localnet`にそれらしいものが現れない。

そういえば、Ubuntu Serverは既定でDUIDを使用し、一部のDHCPサーバーはこれに応答しないためIPアドレスを掴みそこねる場合があるんだった（[過去のセットアップ](../0199d804-fa2f-7925-82e1-003224f2d920/README.md)）。

```
$ sudo tcpdump -i br0 -n -e port 67 or port 68
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on br0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
16:34:08.975319 dc:a6:32:70:a6:27 > ff:ff:ff:ff:ff:ff, ethertype IPv4 (0x0800), length 335: 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from dc:a6:32:70:a6:27, length 293
16:34:13.804403 dc:a6:32:70:a6:27 > ff:ff:ff:ff:ff:ff, ethertype IPv4 (0x0800), length 335: 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from dc:a6:32:70:a6:27, length 293
16:34:17.454969 dc:a6:32:70:a6:27 > ff:ff:ff:ff:ff:ff, ethertype IPv4 (0x0800), length 335: 0.0.0.0.68 > 255.255.255.255.67: BOOTP/DHCP, Request from dc:a6:32:70:a6:27, length 293
```

ビンゴっぽい。Requestに対して応答がない。

IPv6が有効なLinuxホストは、起動時にNICのMACから自動的に`fe80::/10`のリンクローカルアドレスを生成する（とClaudeが教えてくれた）ので、全ノードマルチキャストにpingを投げてMACでフィルタすればリンクローカルアドレスを取得してSSHアクセスできる。

```
$ ping6 -c 3 -I br0 ff02::1
$ ip -6 neigh show dev br0 | grep -i "dc:a6:32:70:a6:27"
fe80::xxxx:xxxx:xxxx:xxxx
$ ssh ubuntu@fe80::xxxx:xxxx:xxxx:xxxx%br0

...

pi@ubuntu:~$
```

あとは`dhcp-identifier: mac`を設定して再起動すればIPv4も掴むはず。
