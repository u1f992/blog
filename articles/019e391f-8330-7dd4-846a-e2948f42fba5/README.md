## Yaruのカラーバリアント（アクセントカラー）について

学生の頃使っていたUbuntu（おそらく20.04 LTS）には公式のアクセントカラー機能はなく、[Jannomag/Yaru-Colors](https://github.com/Jannomag/Yaru-Colors)を使っていた記憶がある。しかし現在Ubuntuをセットアップすると、TweaksにYaru-\*バリアントが含まれていることに気づいた。それどころか、設定の［外観＞カラー］からアクセントカラーを選べるようになっている。

22.04 LTS以降で、公式にこの機能が搭載された。これはYaru-Colorsの直接の成果ではないようだ。またこの変更と前後してYaru-Colorsの更新は停止している。

- [Yaru Accent Colors are coming to Jammy! - Project Discussion / Desktop - Ubuntu Community Hub](https://discourse.ubuntu.com/t/yaru-accent-colors-are-coming-to-jammy/27200)
- [appearance: add accent colors to yaru ubuntu/yaru#3416](https://github.com/ubuntu/yaru/pull/3416)

さらに24.10以降は、libadwaita／GNOMEアップストリームのアクセントカラーAPIを使用する実装（＋静的アイコンアセット）に切り替わっている。

- [Initial upstream accents support ubuntu/yaru#4105](https://github.com/ubuntu/yaru/pull/4105)
- [Shell: use native accent color ubuntu/yaru#4123](https://github.com/ubuntu/yaru/pull/4123)
- [Update gtk theme with upstream and add accented assets ubuntu/yaru#4400](https://github.com/ubuntu/yaru/pull/4400)

現在利用している24.04のTweaksでは、［外観＞Styles＞アイコン＞Yaru-magenta］［外観＞Styles＞レガシーなアプリケーション＞Yaru-magenta］の2系統の設定があり、それぞれ`org.gnome.desktop.interface`の`icon-theme`と`gtk-theme`（これはGTK3を指すので「レガシー」）を書き換えている（[ref](https://gitlab.gnome.org/GNOME/gnome-tweaks/-/blob/46.0/gtweak/tweaks/tweak_group_appearance.py#L25-79)）。設定の［外観＞カラー］は、これら2つのキーを一手に変更する（ref: `https://git.launchpad.net/ubuntu/+source/gnome-control-center`, tag: `applied/1%46.0.1-1ubuntu7`, `panels/ubuntu/cc-ubuntu-colors-row.c:88-138`）。
