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

一見archは不要そうだが`gs.wasm`が生成されない……

`MODULARIZE`したい

https://emscripten.org/docs/tools_reference/settings_reference.html#modularize

```
# emmake make --jobs=$(nproc) XE=".js" GS_LDFLAGS="-s ALLOW_MEMORY_GROWTH=1 -s MODULARIZE=1 -s EXPORT_ES6=1 -s FORCE_FILESYSTEM=1 -s INVOKE_RUN=0 -s EXPORTED_RUNTIME_METHODS=['FS','callMain']"
```

```js
// @ts-check

import fs from "node:fs";

import Module from "./gs.js";

/**
 * @param {{args:string[];stdin:Uint8Array;inputFiles:{filePath:string;content:Uint8Array;}[];outputFilePaths:string[]}} param0
 */
async function ghostscript({ args, stdin, inputFiles, outputFilePaths }) {
  /** @type {{src:"stdout"|"stderr";charCode:number;}[]} */
  const outputStreams = [];
  let stdinOffset = 0;

  const module = await Module({
    preRun(mod) {
      // https://emscripten.org/docs/api_reference/Filesystem-API.html#FS.init
      mod.FS.init(
        /** @type {()=>number|null} */
        () => (stdinOffset < stdin.length ? stdin[stdinOffset++] : null),
        /** @type {(charCode:number)=>void} */
        (charCode) => {
          if (charCode !== null)
            outputStreams.push({ src: "stdout", charCode });
        },
        /** @type {(charCode:number)=>void} */
        (charCode) => {
          if (charCode !== null)
            outputStreams.push({ src: "stderr", charCode });
        }
      );
    },
  });

  for (const { filePath, content } of inputFiles) {
    module.FS.writeFile(filePath, content);
  }

  // https://github.com/emscripten-core/emscripten/pull/14865
  const exitCode = module.callMain(args);

  /** @type {{[filePath:string]:Uint8Array}} */
  const outputFiles = {};
  for (const filePath of outputFilePaths) {
    outputFiles[filePath] = module.FS.readFile(filePath);
  }

  return { exitCode, outputStreams, outputFiles };
}

const ret = await ghostscript({
  args: [
    "-dBATCH",
    "-dNOPAUSE",
    "-dSAFER",
    "-sDEVICE=png16m",
    "-r300",
    "-sOutputFile=/output.png",
    "/input.pdf",
  ],
  stdin: new Uint8Array([]),
  inputFiles: [
    { filePath: "/input.pdf", content: fs.readFileSync("input.pdf") },
  ],
  outputFilePaths: ["/output.png"],
});

fs.writeFileSync("output.png", ret.outputFiles["/output.png"]);

const log = new TextDecoder().decode(
  new Uint8Array(ret.outputStreams.map(({ charCode }) => charCode))
);
console.log(log);

```