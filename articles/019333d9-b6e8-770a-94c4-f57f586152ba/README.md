## CUERipperメモ

http://cue.tools/wiki/Main_Page

2.2.6

- lossless
- image
- flac
- libFLAC
  - Verify: True
  - MD5: True
- C2ErrorMode: Mode296
  - Autoでは`Exception: Error reading CD: IoctlFailed`が発生（PIONEER BD-RW BDR-UD03 1.14）
  - AutoはMode294->Mode296の順番で試行するが、一部ディスクドライブではMode294に対応していないようだ https://hydrogenaud.io/index.php/topic,122176.0.html
- 667（おまかせ）
- Mode: 8
- Paranoid
