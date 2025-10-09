## WSL＋Dockerディスク食いすぎ

ディスクがみるみるいっぱいになりついに何も保存できなくなったので確認すると、`%USERPROFILE%\AppData\Local\Docker\wsl\disk\docker_data.vhdx`が150GBを超えていた。

- https://stackoverflow.com/questions/70946140/docker-desktop-wsl-ext4-vhdx-too-large

根本的な原因はVHDXは自動縮小しないからということらしい。つまり対処法は「[WSLのディスクサイズを削減](../0192bc8a-4a12-77fc-964d-f225677966f8/README.md)」と同じ。ついでにWSLのディスクもつぶしておくとよさそう。

```
ECHO y | docker container prune
ECHO y | docker image prune
ECHO y | docker volume prune
ECHO y | docker builder prune
ECHO y | docker system prune

wsl --shutdown
(
ECHO select vdisk file="C:\Users\mukai\AppData\Local\Docker\wsl\disk\docker_data.vhdx"
ECHO attach vdisk readonly
ECHO compact vdisk
ECHO detach vdisk
ECHO exit
) | diskpart
```

`docker_data.vhdx`は150GB→1GBまで縮小された。さすがにどうにかしてほしい。私程度でもこうなるのなら、みんなもっと困らないのだろうか？

[回答](https://stackoverflow.com/a/72048670)にあるDocker Desktopの`Troubleshoot > Clean / Purge data > WSL 2 > Delete`を実行すると、さらに5GBほど空いた。
