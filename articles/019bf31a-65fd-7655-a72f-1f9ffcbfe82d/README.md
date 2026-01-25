# Ubuntu（Desktop, 24.04）のデフォルトのコンピューター名

DMI System InformationのFamilyを見て、有効な値がない（Default string）場合はProduct Nameを見るという挙動だと推測する。

```
mukai@mukai-ThinkPad-X1-Carbon-Gen-12:~$ sudo dmidecode | grep --after-context=9 "System Information"
System Information
        Manufacturer: LENOVO
        Product Name: 21KCCTO1WW
        Version: ThinkPad X1 Carbon Gen 12
        Serial Number: XXXXXXXX
        UUID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
        Wake-up Type: Power Switch
        SKU Number: LENOVO_MT_21KC_BU_Think_FM_ThinkPad X1 Carbon Gen 12
        Family: ThinkPad X1 Carbon Gen 12
```

```
mukai@mukai-MS-7B98:~/Documents/blog$ sudo dmidecode | grep --after-context=9 "System Information"
System Information
        Manufacturer: Micro-Star International Co., Ltd.
        Product Name: MS-7B98
        Version: 1.0
        Serial Number: Default string
        UUID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
        Wake-up Type: Power Switch
        SKU Number: Default string
        Family: Default string
```
