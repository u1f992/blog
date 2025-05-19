## GhostscriptをWASMにしたい

```
$ docker run --rm --interactive --tty --mount type=bind,source="$(pwd)",target=/workdir --entrypoint /bin/bash --workdir /workdir emscripten/emsdk:4.0.8
```

### ps-wasm

<details>
<summary><a href="https://raw.githubusercontent.com/ochachacha/ps-wasm/2dfe3f2feaf4435e476abb13936272419ab12bec/README.md">README.md</a></summary>

> Note on cross-compilation:
> 
> Cross-compiling ghostscript was the nontrivial part of this project.
> 
> After obtaining the source code from the [source repository](https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs926/ghostscript-9.26.tar.gz), one needs to copy files in the "code_patch" folder into their respective places.
> 
> One also needs to have the EMScripten environment set up; see [here](https://webassembly.org/getting-started/developers-guide/) for a tutorial.
> 
> Then one can run the following command for setting up configure:
> 
> `emconfigure ./configure --disable-threading --disable-cups --disable-dbus --disable-gtk --with-drivers=PS CC=emcc CCAUX=gcc --with-arch_h=~/ghostscript-9.26/arch/wasm.h`
> 
> Followed by the following "make" command:
> 
> `emmake make XE=".html" GS_LDFLAGS="-s ALLOW_MEMORY_GROWTH=1 -s EXIT_RUNTIME=1"`
> 
> And one needs to copy everything from the "bin" folder to the extension folder.
> 
> To include debugging information, instead use the following command, and look for results in "debugbin" (make sure you also copy the map files into the extension folder):
> 
> `emmake make debug XE=".html" GS_LDFLAGS="-s ALLOW_MEMORY_GROWTH=1 -s EXIT_RUNTIME=1 -s ASSERTIONS=2 -g4"`

</details>

#### ダウンロード

```
# wget https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs926/ghostscript-9.26.tar.gz
# tar xvf ghostscript-9.26.tar.gz
# wget https://github.com/ochachacha/ps-wasm/archive/2dfe3f2feaf4435e476abb13936272419ab12bec.zip
# unzip 2dfe3f2feaf4435e476abb13936272419ab12bec.zip
# mv ps-wasm-2dfe3f2feaf4435e476abb13936272419ab12bec ps-wasm
```

#### 差分の検証

`code_patch/arch/wasm.h`はそのまま使えそう。

```
# ls ghostscript-9.26/arch/
arch_autoconf.h.in  osx-x86-x86_64-ppc-gcc.h  windows-arm-msvc.h  windows-x64-msvc.h  windows-x86-msvc.h
```

windows-x64から編集したらしいが、結果的にwindows-x86の設定と同じもののようだ。

```
# diff --unified ghostscript-9.26/arch/windows-x86-msvc.h ps-wasm/code_patch/arch/wasm.h
```

```diff
--- ghostscript-9.26/arch/windows-x86-msvc.h    2018-11-20 10:08:19.000000000 +0000
+++ ps-wasm/code_patch/arch/wasm.h      2023-05-03 03:53:58.000000000 +0000
@@ -13,7 +13,7 @@
    CA 94945, U.S.A., +1(415)492-9861, for further information.
 */
 /* Parameters derived from machine and compiler architecture. */
-/* This file was generated mechanically by genarch.c, for a 32bit */
+/* This file was generated mechanically by genarch.c, for a 64bit */
 /* Microsoft Windows machine, compiling with MSVC. */

         /* ---------------- Scalar alignments ---------------- */
@@ -56,3 +56,4 @@
 #define ARCH_FLOATS_ARE_IEEE 1
 #define ARCH_ARITH_RSHIFT 2
 #define ARCH_DIV_NEG_POS_TRUNCATES 1
+
```

```
# diff --unified ghostscript-9.26/arch/windows-x64-msvc.h ps-wasm/code_patch/arch/wasm.h
```

```diff
--- ghostscript-9.26/arch/windows-x64-msvc.h    2018-11-20 10:08:19.000000000 +0000
+++ ps-wasm/code_patch/arch/wasm.h      2023-05-03 03:53:58.000000000 +0000
@@ -21,7 +21,7 @@
 #define ARCH_ALIGN_SHORT_MOD 2
 #define ARCH_ALIGN_INT_MOD 4
 #define ARCH_ALIGN_LONG_MOD 4
-#define ARCH_ALIGN_PTR_MOD 8
+#define ARCH_ALIGN_PTR_MOD 4
 #define ARCH_ALIGN_FLOAT_MOD 4
 #define ARCH_ALIGN_DOUBLE_MOD 8

@@ -36,7 +36,7 @@
 #define ARCH_SIZEOF_GX_COLOR_INDEX 8
 #endif

-#define ARCH_SIZEOF_PTR 8
+#define ARCH_SIZEOF_PTR 4
 #define ARCH_SIZEOF_FLOAT 4
 #define ARCH_SIZEOF_DOUBLE 8
 #define ARCH_FLOAT_MANTISSA_BITS 24
```

`code_patch/base/gxfapi.h`の意図はなんだ？これは不要かも。

```
# diff --unified ghostscript-9.26/base/gxfapi.h ps-wasm/code_patch/base/gxfapi.h
```

```diff
--- ghostscript-9.26/base/gxfapi.h      2018-11-20 10:08:19.000000000 +0000
+++ ps-wasm/code_patch/base/gxfapi.h     2023-05-03 03:53:58.000000000 +0000
@@ -407,7 +407,7 @@
                                 basefont->FontType == ft_encrypted2 ||\
                                 basefont->FontType == ft_CID_encrypted)

-typedef int (*gs_fapi_get_server_param_callback) (gs_fapi_server *I,
+typedef void (*gs_fapi_get_server_param_callback) (gs_fapi_server *I, // this signature was wrong
                                                   const char *subtype,
                                                   char **server_param,
                                                   int *server_param_size);
```

`code_patch/base/unix-gcc.mak`は`pipe.dev`を削除しているようだ。これは妥当そう。

```
# diff --unified ghostscript-9.26/base/unix-gcc.mak ps-wasm/code_patch/base/unix-gcc.mak
```

```diff
--- ghostscript-9.26/base/unix-gcc.mak  2018-11-20 10:08:19.000000000 +0000
+++ ps-wasm/code_patch/base/unix-gcc.mak        2023-05-03 03:53:58.000000000 +0000
@@ -515,9 +515,9 @@

 XPS_FEATURE_DEVS=$(XPSOBJDIR)/pl.dev $(XPSOBJDIR)/xps.dev

-FEATURE_DEVS=$(GLD)pipe.dev $(GLD)gsnogc.dev $(GLD)htxlib.dev $(GLD)psl3lib.dev $(GLD)psl2lib.dev \
+FEATURE_DEVS=$(GLD)gsnogc.dev $(GLD)htxlib.dev $(GLD)psl3lib.dev $(GLD)psl2lib.dev \
              $(GLD)dps2lib.dev $(GLD)path1lib.dev $(GLD)patlib.dev $(GLD)psl2cs.dev $(GLD)rld.dev $(GLD)gxfapiu$(UFST_BRIDGE).dev\
-             $(GLD)ttflib.dev  $(GLD)cielib.dev $(GLD)pipe.dev $(GLD)htxlib.dev $(GLD)sdct.dev $(GLD)libpng.dev\
+             $(GLD)ttflib.dev  $(GLD)cielib.dev $(GLD)htxlib.dev $(GLD)sdct.dev $(GLD)libpng.dev\
             $(GLD)seprlib.dev $(GLD)translib.dev $(GLD)cidlib.dev $(GLD)psf0lib.dev $(GLD)psf1lib.dev\
              $(GLD)psf2lib.dev $(GLD)lzwd.dev $(GLD)sicclib.dev \
              $(GLD)sjbig2.dev $(GLD)sjpx.dev $(GLD)ramfs.dev \
@@ -527,9 +527,9 @@


 #FEATURE_DEVS=$(PSD)psl3.dev $(PSD)pdf.dev
-#FEATURE_DEVS=$(PSD)psl3.dev $(PSD)pdf.dev $(PSD)dpsnext.dev $(PSD)ttfont.dev $(GLD)pipe.dev
+#FEATURE_DEVS=$(PSD)psl3.dev $(PSD)pdf.dev $(PSD)dpsnext.dev $(PSD)ttfont.dev
 # The following is strictly for testing.
-FEATURE_DEVS_ALL=$(PSD)psl3.dev $(PSD)pdf.dev $(PSD)dpsnext.dev $(PSD)ttfont.dev $(PSD)double.dev $(PSD)trapping.dev $(PSD)stocht.dev $(GLD)pipe.dev $(GLD)gsnogc.dev $(GLD)htxlib.dev $(PSD)jbig2.dev $(PSD)jpx.dev  $(GLD)ramfs.dev
+FEATURE_DEVS_ALL=$(PSD)psl3.dev $(PSD)pdf.dev $(PSD)dpsnext.dev $(PSD)ttfont.dev $(PSD)double.dev $(PSD)trapping.dev $(PSD)stocht.dev $(GLD)gsnogc.dev $(GLD)htxlib.dev $(PSD)jbig2.dev $(PSD)jpx.dev  $(GLD)ramfs.dev
 #FEATURE_DEVS=$(FEATURE_DEVS_ALL)

 # The list of resources to be included in the %rom% file system.
```

`code_patch/Makefile.in`も、`pipe.dev`を削除しているようだ。

```
# diff --unified ghostscript-9.26/Makefile.in ps-wasm/code_patch/Makefile.in
```

```diff
--- ghostscript-9.26/Makefile.in        2018-11-20 10:08:19.000000000 +0000
+++ ps-wasm/code_patch/Makefile.in      2023-05-03 03:53:58.000000000 +0000
@@ -545,18 +545,18 @@

 XPS_FEATURE_DEVS=$(XPSOBJDIR)/pl.dev $(XPSOBJDIR)/xps.dev

-FEATURE_DEVS=$(GLD)pipe.dev $(GLD)gsnogc.dev $(GLD)htxlib.dev $(GLD)psl3lib.dev $(GLD)psl2lib.dev \
+FEATURE_DEVS=$(GLD)gsnogc.dev $(GLD)htxlib.dev $(GLD)psl3lib.dev $(GLD)psl2lib.dev \
              $(GLD)dps2lib.dev $(GLD)path1lib.dev $(GLD)patlib.dev $(GLD)psl2cs.dev $(GLD)rld.dev $(GLD)gxfapiu$(UFST_BRIDGE).dev\
-             $(GLD)ttflib.dev  $(GLD)cielib.dev $(GLD)pipe.dev $(GLD)htxlib.dev $(GLD)sdct.dev $(GLD)libpng.dev\
+             $(GLD)ttflib.dev  $(GLD)cielib.dev $(GLD)htxlib.dev $(GLD)sdct.dev $(GLD)libpng.dev\
             $(GLD)seprlib.dev $(GLD)translib.dev $(GLD)cidlib.dev $(GLD)psf0lib.dev $(GLD)psf1lib.dev\
              $(GLD)psf2lib.dev $(GLD)lzwd.dev $(GLD)sicclib.dev \
              $(GLD)sjbig2.dev $(GLD)sjpx.dev $(GLD)ramfs.dev \
              $(GLD)pwgd.dev

 #FEATURE_DEVS=$(PSD)psl3.dev $(PSD)pdf.dev
-#FEATURE_DEVS=$(PSD)psl3.dev $(PSD)pdf.dev $(PSD)dpsnext.dev $(PSD)ttfont.dev $(GLD)pipe.dev
+#FEATURE_DEVS=$(PSD)psl3.dev $(PSD)pdf.dev $(PSD)dpsnext.dev $(PSD)ttfont.dev
 # The following is strictly for testing.
-FEATURE_DEVS_ALL=$(PSD)psl3.dev $(PSD)pdf.dev $(PSD)dpsnext.dev $(PSD)ttfont.dev $(PSD)double.dev $(PSD)trapping.dev $(PSD)stocht.dev $(GLD)pipe.dev $(GLD)gsnogc.dev $(GLD)htxlib.dev @JBIG2DEVS@ @JPXDEVS@ @UTF8DEVS@ $(GLD)ramfs.dev
+FEATURE_DEVS_ALL=$(PSD)psl3.dev $(PSD)pdf.dev $(PSD)dpsnext.dev $(PSD)ttfont.dev $(PSD)double.dev $(PSD)trapping.dev $(PSD)stocht.dev $(GLD)gsnogc.dev $(GLD)htxlib.dev @JBIG2DEVS@ @JPXDEVS@ @UTF8DEVS@ $(GLD)ramfs.dev
 #FEATURE_DEVS=$(FEATURE_DEVS_ALL)

 # The list of resources to be included in the %rom% file system.
```

#### ビルド

まずは指示通りやってみる。

```
# cp --recursive --no-target-directory ps-wasm/code_patch ghostscript-9.26
# cd ghostscript-9.26
# emconfigure ./configure --disable-threading --disable-cups --disable-dbus --disable-gtk --with-drivers=PS CC=emcc CCAUX=gcc --with-arch_h=arch/wasm.h
# emmake make --jobs=$(nproc) XE=".html" GS_LDFLAGS="-s ALLOW_MEMORY_GROWTH=1 -s EXIT_RUNTIME=1"
# ls bin/
gs.html  gs.js  gs.wasm
```

もちろんちゃんとビルドできる。

ひとつずつ剥がしていく。まず`emconfigure`を使用する場合はCCの指定は不要。

```
# emconfigure python3 -c "import os; print(os.environ['CC'])"
configure: python3 -c 'import os; print(os.environ['"'"'CC'"'"'])'
/emsdk/upstream/emscripten/emcc
```

`--with-drivers`・`--disable-threading`は不要なのでは？実際外してもビルド可能だ。

`--disable-cups`は？ https://ghostscript.readthedocs.io/en/latest/thirdparty.html の「CUPS (AGPL Release Only) - CUPS raster format output」のことだと思うが。ビルドできているようだ。

じゃあ`--disable-dbus --disable-gtk`も勝手に無効になってくれたりしないか？なるようだ。ビルド、実行ともに問題ない。

`CCAUX`は勝手にGCCになるのでは？そうではないらしい。

```
root@46b7e3a7c55a:/workdir/ghostscript-9.26# cat Makefile | grep CCAUX
CCAUX=/emsdk/upstream/emscripten/emcc
CCAUXLD=$(CCAUX)
CCAUX_=$(CCAUX) $(CCFLAGSAUX)
CCAUX_NO_WARN=$(CCAUX_)
```

`CCAUX`の指定は必須のようだ。

```
root@46b7e3a7c55a:/workdir/ghostscript-9.26# emmake make --jobs=$(nproc) XE=".html" GS_LDFLAGS="-s ALLOW_MEMORY_GROWTH=1 -s EXIT_RUNTIME=1"

...

/emsdk/upstream/emscripten/emcc  -DHAVE_MKSTEMP  -DHAVE_FSEEKO    -DHAVE_SETLOCALE   -DHAVE_BSWAP32 -DHAVE_BYTESWAP_H -DHAVE_STRERROR    -DHAVE_PREAD_PWRITE=1 -DGS_RECURSIVE_MUTEXATTR=PTHREAD_MUTEX_RECURSIVE -O2 -Wall -Wstrict-prototypes -Wundef -Wmissing-declarations -Wmissing-prototypes -Wwrite-strings -fno-strict-aliasing -Werror=declaration-after-statement -fno-builtin -fno-common -Werror=return-type -DHAVE_STDINT_H=1 -DHAVE_DIRENT_H=1 -DHAVE_SYS_DIR_H=1 -DHAVE_SYS_TIME_H=1 -DHAVE_SYS_TIMES_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_LIBDL=1 -DGX_COLOR_INDEX_TYPE="unsigned long long" -D__USE_UNIX98=1 -DGS_MEMPTR_ALIGNMENT=8   -DHAVE_RESTRICT=1 -fno-strict-aliasing -DHAVE_POPEN_PROTO=1    -I./ijs   -o ./obj/ijs_server.o -c ./ijs/ijs_server.c
./obj/aux/echogs: 1: Syntax error: word unexpected (expecting "then")
make: *** [base/ijs.mak:79: obj/ijs.o] Error 2
make: *** Waiting for unfinished jobs....
2 warnings generated.
1 warning generated.
emmake: error: 'make --jobs=14 XE=.html 'GS_LDFLAGS=-s ALLOW_MEMORY_GROWTH=1 -s EXIT_RUNTIME=1'' failed (returned 2)
```

最終的に残ったコマンドは以下の通り。

```
# emconfigure ./configure CCAUX=gcc --with-arch_h=arch/wasm.h
# emmake make --jobs=$(nproc) XE=".html" GS_LDFLAGS="-s ALLOW_MEMORY_GROWTH=1 -s EXIT_RUNTIME=1"
```

続いてconfigureのこの部分を解消したい。でもlibjpeg（`jpeg/`）とかプロジェクトルートにあるので、無視してよいのでは？

```
 Support for external codecs:
  ZLIB support:                       no
  Pixar log-format algorithm:         no
  JPEG support:                       no
  Old JPEG support:                   no
  JPEG 8/12 bit dual mode:            no
  ISO JBIG support:                   no
  LZMA2 support:                      no
```

arch要らないよね？ないと`gs.wasm`が生成されない……

<details>
<summary><code>emconfigure ./configure CCAUX=gcc</code></summary>

```
root@46b7e3a7c55a:/workdir/ghostscript-9.26# emconfigure ./configure CCAUX=gcc
configure: ./configure CCAUX=gcc
checking for gcc... /emsdk/upstream/emscripten/emcc
checking whether the C compiler works... yes
checking for C compiler default output file name... a.out
checking for suffix of executables...
checking whether we are cross compiling... no
checking for suffix of object files... o
checking whether we are using the GNU C compiler... yes
checking whether /emsdk/upstream/emscripten/emcc accepts -g... yes
checking for /emsdk/upstream/emscripten/emcc option to accept ISO C89... none needed
checking how to run the C preprocessor... /emsdk/upstream/emscripten/emcc -E
checking for gcc... gcc
checking whether the C compiler works... yes
checking for C compiler default output file name... a.out
checking for suffix of executables...
checking whether we are cross compiling... no
checking for suffix of object files... o
checking whether we are using the GNU C compiler... yes
checking whether gcc accepts -g... yes
checking for gcc option to accept ISO C89... none needed
checking how to run the C preprocessor... gcc -E
checking for a sed that does not truncate output... /usr/bin/sed
checking for ranlib... /emsdk/upstream/emscripten/emranlib
checking for pkg-config... no
checking for strip... /usr/bin/strip
checking if compiler supports restrict... yes
checking supported compiler flags...    -O2
   -Wall
   -Wstrict-prototypes
   -Wundef
   -Wmissing-declarations
   -Wmissing-prototypes
   -Wwrite-strings
   -fno-strict-aliasing
   -Werror=declaration-after-statement
   -fno-builtin
   -fno-common
   -Werror=return-type
   -gdwarf-2
   -g3
   -O0
 ...done.
checking compiler/linker address santizer support...  ...done.
checking for grep that handles long lines and -e... /usr/bin/grep
checking for egrep... /usr/bin/grep -E
checking for ANSI C header files... yes
checking for sys/types.h... yes
checking for sys/stat.h... yes
checking for stdlib.h... yes
checking for string.h... yes
checking for memory.h... yes
checking for strings.h... yes
checking for inttypes.h... yes
checking for stdint.h... yes
checking for unistd.h... yes
checking whether byte ordering is bigendian... no
checking sse2 support... yes
checking for dirent.h that defines DIR... yes
checking for library containing opendir... none required
checking for ANSI C header files... (cached) yes
checking errno.h usability... yes
checking errno.h presence... yes
checking for errno.h... yes
checking fcntl.h usability... yes
checking fcntl.h presence... yes
checking for fcntl.h... yes
checking limits.h usability... yes
checking limits.h presence... yes
checking for limits.h... yes
checking malloc.h usability... yes
checking malloc.h presence... yes
checking for malloc.h... yes
checking for memory.h... (cached) yes
checking for stdlib.h... (cached) yes
checking for string.h... (cached) yes
checking for strings.h... (cached) yes
checking sys/ioctl.h usability... yes
checking sys/ioctl.h presence... yes
checking for sys/ioctl.h... yes
checking sys/param.h usability... yes
checking sys/param.h presence... yes
checking for sys/param.h... yes
checking sys/time.h usability... yes
checking sys/time.h presence... yes
checking for sys/time.h... yes
checking sys/times.h usability... yes
checking sys/times.h presence... yes
checking for sys/times.h... yes
checking syslog.h usability... yes
checking syslog.h presence... yes
checking for syslog.h... yes
checking for unistd.h... (cached) yes
checking dirent.h usability... yes
checking dirent.h presence... yes
checking for dirent.h... yes
checking ndir.h usability... no
checking ndir.h presence... no
checking for ndir.h... no
checking sys/dir.h usability... yes
checking sys/dir.h presence... yes
checking for sys/dir.h... yes
checking sys/ndir.h usability... no
checking sys/ndir.h presence... no
checking for sys/ndir.h... no
checking for inttypes.h... (cached) yes
checking sys/window.h usability... no
checking sys/window.h presence... no
checking for sys/window.h... no
checking for an ANSI C-conforming const... yes
checking for inline... inline
checking for mode_t... yes
checking for off_t... yes
checking for size_t... yes
checking for struct stat.st_blocks... yes
checking whether time.h and sys/time.h may both be included... yes
checking whether struct tm is in sys/time.h or time.h... time.h
checking for dlopen in -ldl... yes
checking dlfcn.h usability... yes
checking dlfcn.h presence... yes
checking for dlfcn.h... yes
checking size of unsigned long long... 8
checking for cos in -lm... yes
checking for pread... yes
checking for pwrite... yes
checking whether pwrite is declared... yes
checking whether pread is declared... yes
checking whether popen is declared... yes
checking for pthread_create in -lpthread... yes
checking recursive mutexes.......... checking for local jpeg library source... jpeg
checking for jmemsys.h... yes
checking for local zlib source... yes
checking for local png library source... yes
checking for local lcms2mt library source... yes
checking for fseeko... yes
checking whether lrintf is declared... yes
checking for X... disabled
checking for mkstemp... yes
checking for fopen64... yes
checking for fseeko... (cached) yes
checking for mkstemp64... yes
checking for setlocale... yes
checking for strerror... yes
checking for isnan... yes
checking for isinf... yes
checking for fpclassify... no
checking whether gcc needs -traditional... no
checking for pid_t... yes
checking vfork.h usability... no
checking vfork.h presence... no
checking for vfork.h... no
checking for fork... yes
checking for vfork... yes
checking for working fork... yes
checking for working vfork... (cached) yes
checking for stdlib.h... (cached) yes
checking for GNU libc compatible malloc... yes
checking for working memcmp... yes
checking return type of signal handlers... void
checking whether lstat correctly handles trailing slash... yes
checking whether stat accepts an empty string... no
checking for vprintf... yes
checking for _doprnt... no
checking for bzero... yes
checking for dup2... yes
checking for floor... yes
checking for gettimeofday... yes
checking for memchr... yes
checking for memmove... yes
checking for memset... yes
checking for mkdir... yes
checking for mkfifo... yes
checking for modf... yes
checking for pow... yes
checking for putenv... yes
checking for rint... yes
checking for setenv... yes
checking for sqrt... yes
checking for strchr... yes
checking for strrchr... yes
checking for strspn... yes
checking for strstr... yes
checking minimum memory pointer alignment... done
checking for sqrtf... yes
checking for strnlen... yes
checking byteswap support... yes
checking for byteswap.h... yes
checking whether to explicitly disable strict aliasing... yes
configure: creating ./config.status
config.status: creating auxflags.mak
checking for a sed that does not truncate output... /usr/bin/sed
checking for ranlib... /emsdk/upstream/emscripten/emranlib
checking for pkg-config... no
checking for strip... /usr/bin/strip
checking if compiler supports restrict... yes
checking supported compiler flags...    -O2
   -Wall
   -Wstrict-prototypes
   -Wundef
   -Wmissing-declarations
   -Wmissing-prototypes
   -Wwrite-strings
   -fno-strict-aliasing
   -Werror=declaration-after-statement
   -fno-builtin
   -fno-common
   -Werror=return-type
   -gdwarf-2
   -g3
   -O0
 ...done.
checking compiler/linker address santizer support...  ...done.
checking for grep that handles long lines and -e... /usr/bin/grep
checking for egrep... /usr/bin/grep -E
checking for ANSI C header files... yes
checking for sys/types.h... yes
checking for sys/stat.h... yes
checking for stdlib.h... yes
checking for string.h... yes
checking for memory.h... yes
checking for strings.h... yes
checking for inttypes.h... yes
checking for stdint.h... yes
checking for unistd.h... yes
checking whether byte ordering is bigendian... no
checking sse2 support... no
checking for dirent.h that defines DIR... yes
checking for library containing opendir... none required
checking for ANSI C header files... (cached) yes
checking errno.h usability... yes
checking errno.h presence... yes
checking for errno.h... yes
checking fcntl.h usability... yes
checking fcntl.h presence... yes
checking for fcntl.h... yes
checking limits.h usability... yes
checking limits.h presence... yes
checking for limits.h... yes
checking malloc.h usability... yes
checking malloc.h presence... yes
checking for malloc.h... yes
checking for memory.h... (cached) yes
checking for stdlib.h... (cached) yes
checking for string.h... (cached) yes
checking for strings.h... (cached) yes
checking sys/ioctl.h usability... yes
checking sys/ioctl.h presence... yes
checking for sys/ioctl.h... yes
checking sys/param.h usability... yes
checking sys/param.h presence... yes
checking for sys/param.h... yes
checking sys/time.h usability... yes
checking sys/time.h presence... yes
checking for sys/time.h... yes
checking sys/times.h usability... yes
checking sys/times.h presence... yes
checking for sys/times.h... yes
checking syslog.h usability... yes
checking syslog.h presence... yes
checking for syslog.h... yes
checking for unistd.h... (cached) yes
checking dirent.h usability... yes
checking dirent.h presence... yes
checking for dirent.h... yes
checking ndir.h usability... no
checking ndir.h presence... no
checking for ndir.h... no
checking sys/dir.h usability... yes
checking sys/dir.h presence... yes
checking for sys/dir.h... yes
checking sys/ndir.h usability... no
checking sys/ndir.h presence... no
checking for sys/ndir.h... no
checking for inttypes.h... (cached) yes
checking sys/window.h usability... no
checking sys/window.h presence... no
checking for sys/window.h... no
checking for an ANSI C-conforming const... yes
checking for inline... inline
checking for mode_t... yes
checking for off_t... yes
checking for size_t... yes
checking for struct stat.st_blocks... yes
checking whether time.h and sys/time.h may both be included... yes
checking whether struct tm is in sys/time.h or time.h... time.h
checking for dlopen in -ldl... yes
checking dlfcn.h usability... yes
checking dlfcn.h presence... yes
checking for dlfcn.h... yes
checking size of unsigned long long... 8
checking for cos in -lm... yes
checking for pread... yes
checking for pwrite... yes
checking whether pwrite is declared... yes
checking whether pread is declared... yes
checking whether popen is declared... yes
checking for pthread_create in -lpthread... yes
checking recursive mutexes.......... checking for iconv_open... yes
checking for stringprep in -lidn... no
checking for systempapername in -lpaper... no
configure: WARNING: disabling support for libpaper
checking for FcInitLoadConfigAndFonts in -lfontconfig... no
checking for dbus_message_iter_get_basic in -ldbus... no
checking for local freetype library source... yes
checking for local jpeg library source... jpeg
checking for jmemsys.h... yes
checking for local zlib source... yes
checking for local png library source... yes
checking for local lcms2mt library source... yes
Running libtiff configure script...
checking build system type... x86_64-unknown-linux-gnu
checking host system type... x86_64-unknown-linux-gnu
checking for a BSD-compatible install... /usr/bin/install -c
checking whether build environment is sane... yes
checking for a thread-safe mkdir -p... /usr/bin/mkdir -p
checking for gawk... no
checking for mawk... mawk
checking whether make sets $(MAKE)... yes
checking whether make supports nested variables... yes
checking how to create a pax tar archive... gnutar
checking whether to enable maintainer-specific portions of Makefiles... no
checking for gcc... /emsdk/upstream/emscripten/emcc
checking whether the C compiler works... yes
checking for C compiler default output file name... a.out
checking for suffix of executables...
checking whether we are cross compiling... no
checking for suffix of object files... o
checking whether we are using the GNU C compiler... yes
checking whether /emsdk/upstream/emscripten/emcc accepts -g... yes
checking for /emsdk/upstream/emscripten/emcc option to accept ISO C89... none needed
checking whether /emsdk/upstream/emscripten/emcc understands -c and -o together... yes
checking for style of include used by make... GNU
checking dependency style of /emsdk/upstream/emscripten/emcc... gcc3
checking for C compiler warning flags... -Wall -W
checking whether ln -s works... yes
checking for cmake... /usr/bin/cmake
checking how to print strings... printf
checking for a sed that does not truncate output... /usr/bin/sed
checking for grep that handles long lines and -e... /usr/bin/grep
checking for egrep... /usr/bin/grep -E
checking for fgrep... /usr/bin/grep -F
checking for ld used by /emsdk/upstream/emscripten/emcc... /emsdk/upstream/emscripten/emcc
checking if the linker (/emsdk/upstream/emscripten/emcc) is GNU ld... yes
checking for BSD- or MS-compatible name lister (nm)... /emsdk/upstream/bin/llvm-nm
checking the name lister (/emsdk/upstream/bin/llvm-nm) interface... BSD nm
checking the maximum length of command line arguments... 1572864
checking how to convert x86_64-unknown-linux-gnu file names to x86_64-unknown-linux-gnu format... func_convert_file_noop
checking how to convert x86_64-unknown-linux-gnu file names to toolchain format... func_convert_file_noop
checking for /emsdk/upstream/emscripten/emcc option to reload object files... -r
checking for objdump... objdump
checking how to recognize dependent libraries... pass_all
checking for dlltool... no
checking how to associate runtime and link libraries... printf %s\n
checking for archiver @FILE support... @
checking for strip... strip
checking for ranlib... /emsdk/upstream/emscripten/emranlib
checking command to parse /emsdk/upstream/bin/llvm-nm output from /emsdk/upstream/emscripten/emcc object... ok
checking for sysroot... no
checking for a working dd... /usr/bin/dd
checking how to truncate binary pipes... /usr/bin/dd bs=4096 count=1
.././tiff/configure: line 7359: /usr/bin/file: No such file or directory
checking for mt... no
checking if : is a manifest tool... no
checking how to run the C preprocessor... /emsdk/upstream/emscripten/emcc -E
checking for ANSI C header files... yes
checking for sys/types.h... yes
checking for sys/stat.h... yes
checking for stdlib.h... yes
checking for string.h... yes
checking for memory.h... yes
checking for strings.h... yes
checking for inttypes.h... yes
checking for stdint.h... yes
checking for unistd.h... yes
checking for dlfcn.h... yes
checking for objdir... .libs
checking if /emsdk/upstream/emscripten/emcc supports -fno-rtti -fno-exceptions... yes
checking for /emsdk/upstream/emscripten/emcc option to produce PIC... -fPIC -DPIC
checking if /emsdk/upstream/emscripten/emcc PIC flag -fPIC -DPIC works... yes
checking if /emsdk/upstream/emscripten/emcc static flag -static works... yes
checking if /emsdk/upstream/emscripten/emcc supports -c -o file.o... yes
checking if /emsdk/upstream/emscripten/emcc supports -c -o file.o... (cached) yes
checking whether the /emsdk/upstream/emscripten/emcc linker (/emsdk/upstream/emscripten/emcc) supports shared libraries... emcc (Emscripten gcc/clang-like replacement + linker emulating GNU ld) 4.0.8 (70404efec4458b60b953bc8f1529f2fa112cdfd1)
clang version 21.0.0git (https:/github.com/llvm/llvm-project 23e3cbb2e82b62586266116c8ab77ce68e412cf8)
Target: wasm32-unknown-emscripten
Thread model: posix
InstalledDir: /emsdk/upstream/bin
yes
checking whether -lc should be explicitly linked in... yes
checking dynamic linker characteristics... GNU/Linux ld.so
checking how to hardcode library paths into programs... immediate
checking whether stripping libraries is possible... yes
checking if libtool supports shared libraries... yes
checking whether to build shared libraries... yes
checking whether to build static libraries... yes
checking whether we are using the GNU C++ compiler... yes
checking whether /emsdk/upstream/emscripten/em++ accepts -g... yes
checking dependency style of /emsdk/upstream/emscripten/em++... gcc3
checking how to run the C++ preprocessor... /emsdk/upstream/emscripten/em++ -E
checking for ld used by /emsdk/upstream/emscripten/em++... /emsdk/upstream/emscripten/emcc
checking if the linker (/emsdk/upstream/emscripten/emcc) is GNU ld... yes
em++: error: no input files
checking whether the /emsdk/upstream/emscripten/em++ linker (/emsdk/upstream/emscripten/emcc) supports shared libraries... yes
checking for /emsdk/upstream/emscripten/em++ option to produce PIC... -fPIC -DPIC
checking if /emsdk/upstream/emscripten/em++ PIC flag -fPIC -DPIC works... yes
checking if /emsdk/upstream/emscripten/em++ static flag -static works... yes
checking if /emsdk/upstream/emscripten/em++ supports -c -o file.o... yes
checking if /emsdk/upstream/emscripten/em++ supports -c -o file.o... (cached) yes
checking whether the /emsdk/upstream/emscripten/em++ linker (/emsdk/upstream/emscripten/emcc) supports shared libraries... yes
checking dynamic linker characteristics... (cached) GNU/Linux ld.so
checking how to hardcode library paths into programs... immediate
checking whether make supports nested variables... (cached) yes
checking for sin in -lm... yes
checking assert.h usability... yes
checking assert.h presence... yes
checking for assert.h... yes
checking fcntl.h usability... yes
checking fcntl.h presence... yes
checking for fcntl.h... yes
checking io.h usability... no
checking io.h presence... no
checking for io.h... no
checking limits.h usability... yes
checking limits.h presence... yes
checking for limits.h... yes
checking malloc.h usability... yes
checking malloc.h presence... yes
checking for malloc.h... yes
checking search.h usability... yes
checking search.h presence... yes
checking for search.h... yes
checking sys/time.h usability... yes
checking sys/time.h presence... yes
checking for sys/time.h... yes
checking for unistd.h... (cached) yes
checking for an ANSI C-conforming const... yes
checking for inline... inline
checking whether byte ordering is bigendian... no
checking for off_t... yes
checking for size_t... yes
checking whether time.h and sys/time.h may both be included... yes
checking whether struct tm is in sys/time.h or time.h... time.h
checking for _LARGEFILE_SOURCE value needed for large files... no
checking whether optarg is declared... yes
checking size of signed short... 2
checking size of unsigned short... 2
checking size of signed int... 4
checking size of unsigned int... 4
checking size of signed long... 4
checking size of unsigned long... 4
checking size of signed long long... 8
checking size of unsigned long long... 8
checking size of unsigned char *... 4
checking size of size_t... 4
checking for signed 8-bit type... signed char
checking for unsigned 8-bit type... unsigned char
checking for signed 16-bit type... signed short
checking for unsigned 16-bit type... unsigned short
checking for signed 32-bit type... signed int
checking for unsigned 32-bit type... unsigned int
checking for signed 64-bit type... signed long long
checking for unsigned 64-bit type... unsigned long long
checking for 'size_t' format specifier... "%u"
checking for signed size type... signed int
checking for ptrdiff_t... yes
checking for pointer difference type... ptrdiff_t
checking for int8... no
checking for int16... no
checking for int32... no
checking for floor... yes
checking for isascii... yes
checking for memmove... yes
checking for memset... yes
checking for mmap... yes
checking for pow... yes
checking for setmode... no
checking for snprintf... yes
checking for sqrt... yes
checking for strchr... yes
checking for strrchr... yes
checking for strstr... yes
checking for strtol... yes
checking for strtoul... yes
checking for strtoull... yes
checking for getopt... yes
checking for snprintf... (cached) yes
checking for strcasecmp... yes
checking for strtoul... (cached) yes
checking for strtoull... (cached) yes
checking for lfind... yes
checking native cpu bit order... lsb2msb
checking for special C compiler options needed for large files... no
checking for _FILE_OFFSET_BITS value needed for large files... no
checking for inflateEnd in -lz... no
checking zlib.h usability... no
checking zlib.h presence... no
checking for zlib.h... no
checking for jpeg_read_scanlines in -ljpeg... no
checking jpeglib.h usability... no
checking jpeglib.h presence... no
checking for jpeglib.h... no
checking for X... no
checking for the pthreads library -lpthreads... no
checking whether pthreads work without any flags... yes
checking for joinable pthread attribute... PTHREAD_CREATE_JOINABLE
checking if more special flags are required for pthreads... no
checking whether we are using the Microsoft C compiler... no
checking GL/gl.h usability... yes
checking GL/gl.h presence... yes
checking for GL/gl.h... yes
checking OpenGL/gl.h usability... no
checking OpenGL/gl.h presence... no
checking for OpenGL/gl.h... no
checking windows.h usability... no
checking windows.h presence... no
checking for windows.h... no
checking for OpenGL library... -lGL
checking GL/glu.h usability... yes
checking GL/glu.h presence... yes
checking for GL/glu.h... yes
checking OpenGL/glu.h usability... no
checking OpenGL/glu.h presence... no
checking for OpenGL/glu.h... no
checking for OpenGL Utility library... no
checking GL/glut.h usability... yes
checking GL/glut.h presence... yes
checking for GL/glut.h... yes
checking GLUT/glut.h usability... no
checking GLUT/glut.h presence... no
checking for GLUT/glut.h... no
checking for GLUT library... -lglut
checking that generated files are newer than configure... done
configure: creating ./config.status
config.status: creating Makefile
config.status: creating build/Makefile
config.status: creating contrib/Makefile
config.status: creating contrib/addtiffo/Makefile
config.status: creating contrib/dbs/Makefile
config.status: creating contrib/dbs/xtiff/Makefile
config.status: creating contrib/iptcutil/Makefile
config.status: creating contrib/mfs/Makefile
config.status: creating contrib/pds/Makefile
config.status: creating contrib/ras/Makefile
config.status: creating contrib/stream/Makefile
config.status: creating contrib/tags/Makefile
config.status: creating contrib/win_dib/Makefile
config.status: creating html/Makefile
config.status: creating html/images/Makefile
config.status: creating html/man/Makefile
config.status: creating libtiff-4.pc
config.status: creating libtiff/Makefile
config.status: creating man/Makefile
config.status: creating port/Makefile
config.status: creating test/Makefile
config.status: creating tools/Makefile
config.status: creating libtiff/tif_config.h
config.status: libtiff/tif_config.h is unchanged
config.status: creating libtiff/tiffconf.h
config.status: libtiff/tiffconf.h is unchanged
config.status: executing depfiles commands
config.status: executing libtool commands

Libtiff is now configured for x86_64-unknown-linux-gnu

  Installation directory:             /usr/local
  Documentation directory:            ${prefix}/share/doc/tiff-4.0.9
  C compiler:                         /emsdk/upstream/emscripten/emcc -g -O2 -Wall -W
  C++ compiler:                       /emsdk/upstream/emscripten/em++ -g -O2
  Enable runtime linker paths:        no
  Enable linker symbol versioning:    no
  Support Microsoft Document Imaging: yes
  Use win32 IO:                       no

 Support for internal codecs:
  CCITT Group 3 & 4 algorithms:       yes
  Macintosh PackBits algorithm:       yes
  LZW algorithm:                      yes
  ThunderScan 4-bit RLE algorithm:    yes
  NeXT 2-bit RLE algorithm:           yes
  LogLuv high dynamic range encoding: yes

 Support for external codecs:
  ZLIB support:                       no
  Pixar log-format algorithm:         no
  JPEG support:                       no
  Old JPEG support:                   no
  JPEG 8/12 bit dual mode:            no
  ISO JBIG support:                   no
  LZMA2 support:                      no

  C++ support:                        yes

  OpenGL support:                     no


Continuing with Ghostscript configuration...
checking for cups-config... no
checking cups/cups.h usability... no
checking cups/cups.h presence... no
checking for cups/cups.h... no
checking for local ijs library source... yes
checking for local Luratech JBIG2 library source... no
checking for local jbig2dec library source... ./jbig2dec
Continuing with Ghostscript configuration...
checking for local Luratech JPEG2K library source... no
checking for fseeko... yes
checking whether lrintf is declared... yes
checking for local OpenJPEG library source... yes
checking for memalign... yes
checking for X... no
checking for mkstemp... yes
checking for fopen64... no
checking for fseeko... (cached) yes
checking for mkstemp64... no
checking for setlocale... yes
checking for strerror... yes
checking for isnan... no
checking for isinf... no
checking for fpclassify... no
checking whether /emsdk/upstream/emscripten/emcc needs -traditional... no
checking for pid_t... yes
checking vfork.h usability... no
checking vfork.h presence... no
checking for vfork.h... no
checking for fork... yes
checking for vfork... yes
checking for working fork... no
checking for working vfork... (cached) yes
checking for stdlib.h... (cached) yes
checking for GNU libc compatible malloc... yes
checking for working memcmp... yes
checking return type of signal handlers... void
checking whether lstat correctly handles trailing slash... yes
checking whether stat accepts an empty string... no
checking for vprintf... yes
checking for _doprnt... no
checking for bzero... yes
checking for dup2... yes
checking for floor... yes
checking for gettimeofday... yes
checking for memchr... yes
checking for memmove... yes
checking for memset... yes
checking for mkdir... yes
checking for mkfifo... yes
checking for modf... yes
checking for pow... yes
checking for putenv... yes
checking for rint... yes
checking for setenv... yes
checking for sqrt... yes
checking for strchr... yes
checking for strrchr... yes
checking for strspn... yes
checking for strstr... yes
checking minimum memory pointer alignment... done
checking for sqrtf... yes
checking for strnlen... yes
checking byteswap support... yes
checking for byteswap.h... yes
checking whether to explicitly disable strict aliasing... yes
checking alignment of short... 2
checking alignment of int... 4
checking alignment of long... 4
checking alignment of void *... 4
checking alignment of float... 4
checking alignment of double... 8
checking size of char... 1
checking size of short... 2
checking size of int... 4
checking size of long... 4
checking size of long long... 8
checking size of void *... 4
checking size of float... 4
checking size of double... 8
checking if pointers are signed... no
checking if dividing negative by positive truncates... yes
checking if arithmetic shift works properly... yes
configure: creating ./config.status
config.status: creating arch-config/arch_autoconf.h
config.status: creating Makefile
```

</details>
