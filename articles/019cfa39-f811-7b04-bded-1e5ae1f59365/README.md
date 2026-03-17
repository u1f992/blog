## PCのハードウェアの生の情報をダンプする

スクリプト添付済み。lzipとflashromを使用する

```
fw_dump_gihyo-Vostro-15-3510_20260317_143618
├── _errors.log
├── acpi
│   ├── APIC
│   ├── ...
│   └── dynamic
│       ├── SSDT12
│       ├── ...
│       └── SSDT19
├── efivars
│   ├── AbtStatus-a0b1889e-00eb-445b-8ca9-e91ce43c907d
│   ├── ...
│   └── dbxDefault-8be4df61-93ca-11d2-aa0d-00e098032b8c
├── smbios.bin
└── spiflash_bios.bin

5 directories, 259 files
```

`dmidecode --from-dump smbios.bin`とすれば、PCの情報を抽出するのと同様に扱える。
