## WindowsでCodex CLIのMCPにPlaywrightを追加する

[Claude Codeでも壊れる](https://qiita.com/u1f992/items/29160e7a9238652fd337)し、やっぱりWindowsを使わないのが正解。

- https://github.com/openai/codex/blob/main/docs/config.md#mcp_servers
- https://github.com/openai/codex/issues/2508#issuecomment-3257031806

<figure>
<figcaption>%USERPROFILE%\.codex\config.toml</figcaption>

```toml
[mcp_servers.playwright]
command = "C:\\Program Files\\nodejs\\npx.cmd"
args = ["-y", "@playwright/mcp@latest"]
# see https://github.com/openai/codex/issues/2508#issuecomment-3257031806
env = { "SYSTEMROOT" = "C:\\Windows" }
```

</figure>
