## WSLのディスクサイズを削減

よく中身を見て使うこと！

https://qiita.com/siruku6/items/c91a40d460095013540d

`Optimize-VHD`はHyper-Vを有効にしないと（＝Pro版でないと）使用できないようだ。

```
ECHO y | docker container prune
ECHO y | docker image prune
ECHO y | docker volume prune
ECHO y | docker builder prune
ECHO y | docker system prune

wsl --shutdown
(
ECHO select vdisk file="C:\Users\mukai\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu_79rhkp1fndgsc\LocalState\ext4.vhdx"
ECHO attach vdisk readonly
ECHO compact vdisk
ECHO detach vdisk
ECHO exit
) | diskpart

PAUSE
```
