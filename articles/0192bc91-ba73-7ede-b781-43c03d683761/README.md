## VirtualBoxの右上に出てくる通知センターを消す

https://www.reddit.com/r/virtualbox/comments/y5lr8x/virtualbox_70_disable_notification_center/

すでに設定をいじっていたらそれを消して、`SuppressMessages`を追加する

```.VirtualBox/VirtualBox.xml.patch
13d12
<       <ExtraDataItem name="GUI/NotificationCenter/Alignment" value="Bottom"/>
16a16
>       <ExtraDataItem name="GUI/SuppressMessages" value="confirmGoingFullscreen,remindAboutMouseIntegration,remindAboutAutoCapture"/>

```

`<ExtraDataItem name="GUI/NotificationCenter/Order" value=""/>`もあるらしい

## VirtualBoxのVRAMを256MBまで増やす

GUIでは128MBまでしか設定できない。

https://askubuntu.com/questions/587083/virtualbox-how-to-increase-video-memory

```
> VBoxManage modifyvm "Name of VM" --vram 256
```

ただし、3Dアクセラレーションを利用する場合はホストのVRAMがパススルーされるので、VRAMを増やしてもおいしくないらしい。
