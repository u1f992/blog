## Ubuntu ServerのLVMデフォルト割り当て

Ubuntu Serverのインストーラー（Subiquity）は、LVMを選択した場合にディスク全体を論理ボリュームに割り当てない。LVMスナップショットや将来の拡張のために、VG（Volume Group）に空き領域を残す設計になっている。

### 割り当てルール

ディスクサイズに応じた段階的なルールが適用される（[subiquity/controllers/filesystem.py](https://discourse.ubuntu.com/t/how-is-the-size-of-the-lvm-container-decided/24608)）。

| ディスクサイズ | LVへの割り当て |
|---|---|
| 10GiB未満 | 全体 |
| 10-20GiB | 10GiB |
| 20-200GiB | 半分 |
| 200GiB超 | 最大100GiB |

### 事前対策（インストール時）

対話型インストーラーでは全体割り当てを選択できない。autoinstallを使用し、`sizing-policy: all`を指定する。

```yaml
#cloud-config
autoinstall:
  version: 1
  storage:
    layout:
      name: lvm
      sizing-policy: all
```

### 事後対策（インストール後）

```shellsession
$ sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
$ sudo resize2fs /dev/ubuntu-vg/ubuntu-lv
```

### 一次情報

- [How is the size of the LVM container decided? - Ubuntu Community Hub](https://discourse.ubuntu.com/t/how-is-the-size-of-the-lvm-container-decided/24608)
- [Bug #1907128 "Subiquity only provisions half of available space"](https://bugs.launchpad.net/bugs/1907128)
- [Autoinstall configuration reference manual](https://canonical-subiquity.readthedocs-hosted.com/en/latest/reference/autoinstall-reference.html)
