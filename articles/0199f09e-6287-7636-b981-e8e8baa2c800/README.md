## SSH／RDPからでもカメラやマイクに触りたい

SSHで入っているマシンで`/dev/video0`に触ろうとしたら動かなかった。

```
$ ls -l /dev/video*
crw-rw----+ 1 root video 81, 0 10月 17 12:15 /dev/video0
crw-rw----+ 1 root video 81, 1 10月 17 12:15 /dev/video1
$ uv run --with opencv-python python -c "import cv2; ret, _ = cv2.VideoCapture(0).read(); ret"
[ WARN:0@0.008] global cap_v4l.cpp:914 open VIDEOIO(V4L2:/dev/video0): can't open camera by index
[ WARN:0@0.009] global obsensor_stream_channel_v4l2.cpp:82 xioctl ioctl: fd=-1, req=-2140645888
[ WARN:0@0.009] global obsensor_stream_channel_v4l2.cpp:138 queryUvcDeviceInfoList ioctl error return: 9
[ WARN:0@0.009] global obsensor_stream_channel_v4l2.cpp:82 xioctl ioctl: fd=-1, req=-2140645888
[ WARN:0@0.009] global obsensor_stream_channel_v4l2.cpp:138 queryUvcDeviceInfoList ioctl error return: 9
[ERROR:0@0.009] global obsensor_uvc_stream_channel.cpp:163 getStreamChannelGroup Camera index out of range
```

既定では、映像やオーディオデバイスはGUIセッションに紐付いている。誰かが不正にログインした場合に自宅の映像や音声を引き抜かれてしまったら大事故だから、妥当に思える。

リモートアクセスでも使用するためには次のように設定してマシン再起動する。

```
$ sudo cat /etc/udev/rules.d/99-remote-media-uaccess.rules
SUBSYSTEM=="video4linux", TAG+="uaccess", MODE="0666"
SUBSYSTEM=="sound", TAG+="uaccess", MODE="0666"
```

uaccessタグはsystemd-logindと連携して、現在アクティブなユーザーにアクセス権を付与する。

```
$ uv run --with opencv-python python -c "import cv2; ret, _ = cv2.VideoCapture(0).read(); ret"
True
```
