## Vivliostyle×devcontainerメモ

- https://code.visualstudio.com/docs/devcontainers/containers
- WindowsではWSL経由で良い感じになるので何もしなくてよい
- MacではXQuartzが必要。インストールして再ログインするだけ

#### .devcontainer/Dockerfile

```
FROM ghcr.io/vivliostyle/cli:8.20.0
# RUN apt-get update && apt-get --yes --no-install-recommends install \
#         foo \
#     && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["/usr/bin/bash"]
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
      "extensions": ["esbenp.prettier-vscode"]
    }
  }
}
```
