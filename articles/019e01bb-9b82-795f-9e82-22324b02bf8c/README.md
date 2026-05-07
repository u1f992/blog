## Legion T5-28IMB05におけるWoL有効化

ずばりそれの設定`Power > Automatic Power On > Wake on Lan`が`Enable`になっている。

`Power > After Power Loss`も`Power Off`から`Power On`に変えておけば、停電後に締め出されることはなさそう。

OS側でも設定が必要

```
$ ip link show enp3s0  # MACを控える

$ sudo ethtool enp3s0 | grep -E 'Supports Wake-on|Wake-on:'
	Supports Wake-on: pumbg
	Wake-on: d
$ ls /etc/netplan/
50-cloud-init.yaml  50-cloud-init.yaml.orig
$ sudo tee /etc/netplan/99-wakeonlan.yaml > /dev/null <<'EOF'
network:
  version: 2
  ethernets:
    enp3s0:
      wakeonlan: true
EOF
$ sudo chmod 600 /etc/netplan/99-wakeonlan.yaml  # Permissions for /etc/netplan/99-wakeonlan.yaml are too open. の警告が出る
$ sudo netplan generate
$ sudo netplan apply
$ sudo ethtool enp3s0 | grep -E 'Supports Wake-on|Wake-on:'
	Supports Wake-on: pumbg
	Wake-on: g
```

```
$ wakeonlan -i <broadcast> <mac>
```
