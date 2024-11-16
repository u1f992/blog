## MSYS2 UCRT64でgdome2をビルドする

[gdome2](http://gdome2.cs.unibo.it/)

- http://gdome2.cs.unibo.it/
- https://www.gnu.org/software/gettext/manual/html_node/config_002eguess.html
- https://packages.debian.org/bookworm/libgdome2-0

```
PS > mkdir gdome2
PS > cd .\gdome2\
PS > Invoke-WebRequest -Uri https://github.com/msys2/msys2-installer/releases/download/2024-07-27/msys2-base-x86_64-20240727.sfx.exe -OutFile msys2-base-x86_64-20240727.sfx.exe
PS > .\msys2-base-x86_64-20240727.sfx.exe -y "-o$PWD\"
PS > .\msys64\msys2_shell.cmd -defterm -here -no-start -ucrt64
```

#### build-gdome2.sh

インストール直後に実行した場合`pacman --sync --refresh --sysupgrade --noconfirm`でシステム更新が行われてシェルごと強制終了されるので、再度シェルを起動して実行する。

```bash
#!/bin/bash -eu

pacman --sync --refresh --sysupgrade --noconfirm

pacman --sync --noconfirm \
    base-devel \
    mingw-w64-ucrt-x86_64-autotools \
    mingw-w64-ucrt-x86_64-glib2 \
    mingw-w64-ucrt-x86_64-libxml2 \
    mingw-w64-ucrt-x86_64-toolchain

curl --location --remote-name http://gdome2.cs.unibo.it/tarball/gdome2-0.8.1.tar.gz
tar xvf gdome2-0.8.1.tar.gz gdome2-0.8.1/
cd gdome2-0.8.1/

curl \
    --location --output config.sub 'https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD' \
    --location --output config.guess 'https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD'
 
curl \
    --location --remote-name https://sources.debian.org/data/main/g/gdome2/0.8.1%2Bdebian-9/debian/patches/01glibconfig.patch \
    --location --remote-name https://sources.debian.org/data/main/g/gdome2/0.8.1%2Bdebian-9/debian/patches/02fix_manpage.patch \
    --location --remote-name https://sources.debian.org/data/main/g/gdome2/0.8.1%2Bdebian-9/debian/patches/03no_glib_1.patch \
    --location --remote-name https://sources.debian.org/data/main/g/gdome2/0.8.1%2Bdebian-9/debian/patches/04bufptr_ftbfs.patch \
    --location --remote-name https://sources.debian.org/data/main/g/gdome2/0.8.1%2Bdebian-9/debian/patches/05gcc10_ftbfs.patch \
    --location --remote-name https://sources.debian.org/data/main/g/gdome2/0.8.1%2Bdebian-9/debian/patches/06libxml2.patch \
    --location --remote-name https://sources.debian.org/data/main/g/gdome2/0.8.1%2Bdebian-9/debian/patches/07test-bench-fputs.patch
for patch in *.patch
do
    patch --strip=1 --binary < "$patch"
done

CFLAGS=-Wno-implicit-int ./configure
CFLAGS=-Wno-implicit-int mingw32-make --jobs=$(nproc)
CFLAGS=-Wno-implicit-int mingw32-make install
```
