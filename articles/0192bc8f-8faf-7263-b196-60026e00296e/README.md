## ChatGPTにプロジェクトのファイル全部食わせる

```
$ python -c "import subprocess;[print(chr(96)*3+filename+chr(10)+open(filename,encoding='utf-8').read()+chr(10)+chr(96)*3+chr(10)) for filename in subprocess.run(['git','ls-files'],capture_output=True,text=True,check=True).stdout.strip().split(chr(10))]"
```

`chr(96)`は`` ` ``、`chr(10)`は`\n`。エスケープのことを考えるのが面倒くさいため。

```python
import subprocess

[
    print(
        chr(96) * 3
        + filename
        + chr(10)
        + open(filename, encoding='utf-8').read()
        + chr(10)
        + chr(96) * 3
        + chr(10)
    )
    for filename in subprocess.run(
        ["git", "ls-files"], capture_output=True, text=True, check=True
    )
    .stdout.strip()
    .split(chr(10))
]
```

シェルワンライナーでもできるな

```
$ for file in $(git ls-files); do echo "#### $file"; echo ""; echo "\`\`\`"; cat "$file"; echo ""; echo "\`\`\`"; echo ""; done
```
