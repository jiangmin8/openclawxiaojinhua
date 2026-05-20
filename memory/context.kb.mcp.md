# MCP 协议 — OpenClaw 集成

> 日期：2026-05-20
> 源：https://docs.openclaw.ai/mcp

## OpenClaw MCP 能力

OpenClaw 通过插件系统暴露 MCP 服务器：
- `search_open_claw` — 知识库搜索
- `query_docs_filesystem_open_claw` — 虚拟文件系统读取文档
- Resource: `clawdbot` skill

## 插件体系

```bash
openclaw plugins install clawhub:<package>   # ClawHub
openclaw plugins install npm:<package>       # npm
openclaw plugins install git:<repo>          # git
openclaw plugins install ./my-plugin         # 本地
```

插件可注册：tools / hooks / services / Gateway methods / CLI commands

## MCP 在雅典娜的潜力

1. **工具标准化出口** — 把现有工具包装为 MCP 端点，别的 AI Agent 也能调用
2. **Skill 发布** — 把 archetypes 打包为 MCP skills 可分发
3. **跨 Agent 通信** — MCP + A2A 实现多实例协同
4. **工具发现** — MCP tools/list 让外部系统自动发现能力

## 下一步

- [ ] 验证当前 OpenClaw Gateway 的 MCP 端点
- [ ] 测试注册自定义工具为 MCP resource
- [ ] 评估性能开销
