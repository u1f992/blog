## メモリ上のELFバイナリを実行するPythonコード

```python
import ctypes


_libc = ctypes.CDLL("libc.so.6", use_errno=True)

_libc.memfd_create.argtypes = [ctypes.c_char_p, ctypes.c_uint]
_libc.memfd_create.restype = ctypes.c_int


def memfd_create(name: str, flags: int):
    """
    `int memfd_create(const char *name, unsigned int flags);`
    """
    fd = _libc.memfd_create(name.encode("utf-8"), flags)
    if fd == -1:
        err = ctypes.get_errno()
        raise OSError(err, os.strerror(err))
    return fd


_libc.fexecve.argtypes = [
    ctypes.c_int,
    ctypes.POINTER(ctypes.c_char_p),
    ctypes.POINTER(ctypes.c_char_p),
]
_libc.fexecve.restype = ctypes.c_int


def fexecve(fd: int, argv: typing.Collection[str], envp: typing.Collection[str]):
    """
    `int fexecve(int fd, char *const argv[], char *const envp[]);`
    """
    argc = (ctypes.c_char_p * (len(argv) + 1))(
        *[arg.encode("utf-8") for arg in argv] + [None]
    )
    envc = (ctypes.c_char_p * (len(envp) + 1))(
        *[env.encode("utf-8") for env in envp] + [None]
    )

    if _libc.fexecve(fd, argc, envc) == -1:
        err = ctypes.get_errno()
        raise OSError(err, os.strerror(err))


def execute(elf_data: bytes):
    fd = memfd_create("elf_memfd", 0)
    os.write(fd, elf_data)
    try:
        fexecve(fd, ["/proc/self/exe"], os.environ)
    except OSError as e:
        print(f"fexecve failed: {e}")
```
