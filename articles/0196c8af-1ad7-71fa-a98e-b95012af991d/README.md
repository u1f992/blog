## Emscriptenのdevcontainer環境

Dockerfileと補完とフォーマットの設定

#### .devcontainer/emscripten.dockerfile

```
FROM emscripten/emsdk:4.0.8
RUN apt-get update && apt-get --yes --no-install-recommends install \
        clang-format \
    && rm -rf /var/lib/apt/lists/*
```

#### .devcontainer/devcontainer.json

```json
{
    "build": {
        "dockerfile": "./Dockerfile",
        "context": "."
    },
    "customizations": {
        "vscode": {
            "extensions": [
                "ms-vscode.cpptools-extension-pack",
                "xaver.clang-format"
            ]
        }
    }
}
```

### .vscode/c_cpp_properties.json

```json
{
    "configurations": [
        {
            "name": "CMake",
            "compileCommands": "${config:cmake.buildDirectory}/compile_commands.json",
            "configurationProvider": "ms-vscode.cmake-tools",
            "includePath": ["/emsdk/upstream/emscripten/system/include/**"]
        }
    ],
    "version": 4
}
```

### .vscode/settings.json

```json
{
    "[c]": {
        "editor.formatOnSave": true,
        "editor.defaultFormatter": "xaver.clang-format"
    },
    "[cpp]": {
        "editor.formatOnSave": true,
        "editor.defaultFormatter": "xaver.clang-format"
    },
    "files.associations": {
        "emscripten.h": "c"
    }
}
```
