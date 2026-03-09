## 追加したUSBデバイスを追跡する

未知のデバイスならまずは

```shellsession
$ sudo udevadm monitor
```

`--udev`をつけることで（カーネルの生の情報ではなく）udevが処理した後の情報、つまりユーザー空間から見て意味のある段階まで進んだ出来事を表示する。

```shellsession
$ sudo udevadm monitor --udev
```

`--subsystem-match`で絞り込むこともできる。

```shellsession
$ sudo udevadm monitor --subsystem-match=block --udev
```
