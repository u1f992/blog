## Ubuntuのリアルタイム性能を上げる

特に設定した覚えのないUbuntu 24.04だが、`PREEMPT_DYNAMIC`なので、GRUBの起動パラメータに`preempt=full`を追加することで低レイテンシー機能を有効化できるようだ。

```
$ uname -a
Linux mukai-MS-7B98 6.14.0-37-generic #37~24.04.1-Ubuntu SMP PREEMPT_DYNAMIC Thu Nov 20 10:25:38 UTC 2 x86_64 x86_64 x86_64 GNU/Linux
$ sudo cat /sys/kernel/debug/sched/preempt
none (voluntary) full lazy
```

そもそもプリエンプションとは、実行中のタスクを中断して別タスクに切り替える仕組み。音声処理などでは単一タスクが長時間CPUを専有する事態を避け、音声処理タスクが必要な瞬間にすぐCPUを使用できるようにする必要がある。これを実現するのが`full`あるいは`lazy`。`preempt=full`は（ほぼ）あらゆる時点でプリエンプションを起こすことができるようになりレイテンシは最小になるが、コンテキスト切り替えのコストがかさんでスループットは下がりやすい。`preempt=lazy`はこの問題に対する折衷案的な動作になっている。

```
$ sudo nano /etc/default/grub  # GRUB_CMDLINE_LINUXの末尾に半角スペースを開けてpreempt=fullあるいはlazyを追記
$ sudo update-grub
$ systemctl reboot

$ sudo cat /sys/kernel/debug/sched/preempt
none voluntary (full) lazy
```

一方でUbuntuではリアルタイムカーネルのバイナリが提供されている。24.04ではPREEMPT_RTがマージされた6.12より古いカーネルだが、問題があったら上流に報告しやすいのが自前ビルドより良い点。

```
$ apt search linux-realtime
ソート中... 完了
全文検索... 完了  
linux-image-unsigned-6.8.1-1015-realtime/noble-updates 6.8.1-1015.16 amd64
  Linux kernel image for version 6.8.1 on 64 bit x86 SMP

linux-modules-6.8.1-1015-realtime/noble-updates 6.8.1-1015.16 amd64
  Linux kernel extra modules for version 6.8.1 on 64 bit x86 SMP

linux-modules-extra-6.8.1-1015-realtime/noble-updates 6.8.1-1015.16 amd64
  Linux kernel extra modules for version 6.8.1 on 64 bit x86 SMP

linux-realtime/noble-updates 6.8.1-1015.16 amd64
  Complete Linux kernel for real-time systems.

linux-realtime-cloud-tools-6.8.1-1015/noble-updates 6.8.1-1015.16 amd64
  Linux kernel version specific cloud tools for version 6.8.1-1015

linux-realtime-headers-6.8.1-1015/noble-updates,noble-updates 6.8.1-1015.16 all
  Header files related to Linux kernel version 6.8.1

linux-realtime-tools-6.8.1-1015/noble-updates 6.8.1-1015.16 amd64
  Linux kernel version specific tools for version 6.8.1-1015

ubuntu-realtime/noble-updates 1.1.2~24.04.1 amd64
  Install and configure linux-realtime kernel for real-time systems.
```
