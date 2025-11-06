## Ardourのインストール時警告（frequency scaling）に対応する

Ardour 8.12をReady-to-Runインストーラーで素Ubuntu 24.04にインストールすると、下記の警告が出ていた。

```
$ sudo ./Ardour-8.12.0-x86_64.run 
Verifying archive integrity...  100%   MD5 checksums are OK. All good.
Uncompressing Ardour  100%  

Welcome to the Ardour installer

...

!!! WARNING !!! - Your system seems to use frequency scaling.
This can have a serious impact on audio latency.
For best results turn it off, e.g. by choosing the 'performance' governor.

...
```

たしかにpowersaveだ。まあいつもArdourなどパフォーマンスが重要なアプリケーションを使うわけではないのだけど

```
$ cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
powersave
powersave
powersave
powersave
powersave
powersave
powersave
powersave
powersave
powersave
powersave
powersave
powersave
powersave
powersave
powersave
```

<details>
<summary>追加パッケージ<code>cpufrequtils</code>でも確認できる</summary>

```
$ sudo apt install cpufrequtils
$ cpufreq-info -o
          minimum CPU frequency  -  maximum CPU frequency  -  governor
CPU  0       800000 kHz ( 16 %)  -    5000000 kHz (100 %)  -  powersave
CPU  1       800000 kHz ( 16 %)  -    5000000 kHz (100 %)  -  powersave
CPU  2       800000 kHz ( 16 %)  -    5000000 kHz (100 %)  -  powersave
CPU  3       800000 kHz ( 16 %)  -    5000000 kHz (100 %)  -  powersave
CPU  4       800000 kHz ( 16 %)  -    5000000 kHz (100 %)  -  powersave
CPU  5       800000 kHz ( 16 %)  -    5000000 kHz (100 %)  -  powersave
CPU  6       800000 kHz ( 16 %)  -    5000000 kHz (100 %)  -  powersave
CPU  7       800000 kHz ( 16 %)  -    5000000 kHz (100 %)  -  powersave
CPU  8       800000 kHz ( 16 %)  -    5000000 kHz (100 %)  -  powersave
CPU  9       800000 kHz ( 16 %)  -    5000000 kHz (100 %)  -  powersave
CPU 10       800000 kHz ( 16 %)  -    5000000 kHz (100 %)  -  powersave
CPU 11       800000 kHz ( 16 %)  -    5000000 kHz (100 %)  -  powersave
CPU 12       800000 kHz ( 16 %)  -    5000000 kHz (100 %)  -  powersave
CPU 13       800000 kHz ( 16 %)  -    5000000 kHz (100 %)  -  powersave
CPU 14       800000 kHz ( 16 %)  -    5000000 kHz (100 %)  -  powersave
CPU 15       800000 kHz ( 16 %)  -    5000000 kHz (100 %)  -  powersave
```

</details>

- https://discourse.ardour.org/t/cpu-governor-warning-your-system-seems-to-use-frequency-scaling/107872
- https://qiita.com/k0kubun/items/fa1d5fbf62a8bd9d34ef

今回起動時に限り即時変更なら

```
$ sudo bash -c 'for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo performance > "$cpu"; done'
```

再起動後も有効化するには

```
$ sudo apt install cpufrequtils
$ echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils

# $ sudo systemctl disable ondemand
# 上記の記事ではこの手順があったが、Ubuntu 24.04ではondemandサービスは使用されていない
# > Unit ondemand.service could not be found.

$ systemctl reboot
```

消費電力も増えるらしいけど、どんなものだろうか……
