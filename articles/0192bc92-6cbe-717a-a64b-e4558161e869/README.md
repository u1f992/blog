## MSYS2でddrescueのビルド

https://www.gnu.org/software/ddrescue/

現時点ではv1.28まで出ている。http://ftpmirror.gnu.org/ddrescue/

- `lzip`
- `base-devel`
- `gcc`

`mingw-*`ではない。あくまでMSYS2上で動かすものなので。

```
$ wget http://ftpmirror.gnu.org/ddrescue/ddrescue-1.28.tar.lz
$ tar xvf ddrescue-1.28.tar.lz
$ cd ddrescue-1.28
$ ./configure
$ make
$ make install
$ ddrescue --version
```
