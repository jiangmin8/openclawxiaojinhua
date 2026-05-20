---
title: MEMORY - 知识库索引
version: 2.0
date: 2026-05-15
tags:
  - memory
  - knowledge-base
---

# MEMORY - 知识库索引

> [!note] 使用说明
> MEMORY.md 在每个 DM 会话开始时自动加载。子文件通过 `memory_search` 和 `memory_get` 工具按需访问，不在系统提示词中全量加载。

## 知识库子文件

| 文件路径 | 内容 | 优先级 | 状态 |
|:---|:---|:---|:---|
| `memory/context.base.md` | 固定环境信息 — 设备、IP、端口、硬件配置、网络拓扑 | 基础 | ✅ 已初始化 |
| `memory/context.project.md` | 当前项目上下文与进度 | 项目级 | 📝 按需更新 |
| `memory/context.archive.md` | 已完成项目归档（含关键决策） | 参考 | 📝 按需更新 |
| `memory/context.kb.md` | 专题知识库（OpenClaw、Ollama、WSL2、Python、网络设备） | 知识 | ✅ 已初始化 |
| `memory/context.user.pref.md` | 大哥偏好设置与习惯 | 个人化 | ✅ 已初始化 |

## 快速操作手册

> [!tip] 雅典娜常用命令速查

| 操作 | 命令 |
|:---|:---|
| Gateway 重启 | `systemctl --user restart openclaw-gateway` |
| Gateway 状态 | `systemctl --user status openclaw-gateway` |
| Gateway 日志 | `journalctl --user -u openclaw-gateway -f` |
| Gateway UI | `http://localhost:18789` |
| Ollama 重启 | `systemctl --user restart ollama` |
| Ollama 模型列表 | `ollama list` |
| 磁盘检查 | `df -h /mnt/{d,e,f,g}` |
| 内存检查 | `free -h` |
| GPU 检查 | `nvidia-smi` |
| 路由器 SSH | `ssh -i ~/.ssh/router_new root@192.168.8.1` |
| AP SSH | `ssh root@192.168.8.178` |
| 手动备份 | `bash ~/.openclaw/workspace/scripts/athena-backup.sh` |
| 安全审计 | `bash ~/.openclaw/workspace/scripts/athena-security-audit.sh` |

## 知识生命周期管理

```
创建 → 活跃 → 归档 → 清理
  │      │      │      │
  ▼      ▼      ▼      ▼
新信息  当前使用  项目完成  超过90天
写入   频繁访问  迁移至    自动清理
       context.  archive
       project
```

### 规则

- **短期记忆：** 保存 7 天，过期后摘要归档。
- **长期记忆：** 归档至 `memory/context.archive.md`。
- **关联性：** 按项目和主题建立知识关联。
- **隐私性：** 敏感信息加密存储，禁止在对话中回显。
- **一致性：** 保持与 USER.md 中定义的偏好一致。

## 跨会话上下文传递

- OpenClaw 自动加载 MEMORY.md + 最近 2 天的 `memory/YYYY-MM-DD.md` 日志。
- 雅典娜通过 `memory_search` 工具检索历史知识。
- 关键决策和变更始终记录到 `memory/YYYY-MM-DD.md`。

## 子文件创建优先级

1. **`context.base.md`** — 首次部署时由 `athena-init-memory.sh` 自动生成
2. **`context.user.pref.md`** — 首次部署时创建模板，大哥手动填充
3. **`context.project.md`** — 有新项目时创建
4. **`context.kb.md`** — 积累专题知识时创建
5. **`context.archive.md`** — 项目完成后归档
