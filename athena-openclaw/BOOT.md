---
title: BOOT - 启动自检
version: 1.0
date: 2026-05-15
tags:
  - boot
  - startup
---

# BOOT - 启动自检

> [!note] OpenClaw 原生机制
> BOOT.md 在 OpenClaw Gateway 重启时自动执行。无需手动运行。

## 启动自检清单

### 1. 核心文件检查

检查以下文件是否存在：

- [ ] AGENTS.md
- [ ] SOUL.md
- [ ] TOOLS.md
- [ ] USER.md
- [ ] IDENTITY.md
- [ ] HEARTBEAT.md
- [ ] MEMORY.md
- [ ] CHANGELOG.md

### 2. 文件完整性验证

对比 `.security/checksums.sha256` 中的 SHA256 指纹。如有不匹配：
- 触发 `[CRITICAL SECURITY ALERT]`
- 暂停所有 Tier 2/3 操作
- 通知大哥

### 3. 服务状态检查

- [ ] Ollama 服务：`curl -s http://127.0.0.1:11434/api/tags`
- [ ] Gateway 服务：`curl -s http://127.0.0.1:18789`

### 4. 磁盘空间检查

各分区剩余空间 > 20%：
- [ ] `/mnt/d`（模型仓库）
- [ ] `/mnt/e`（工作区）
- [ ] `/mnt/f`（缓存）
- [ ] `/mnt/g`（冷存储）
- [ ] `/mnt/sda1`（备份）

### 5. 知识库状态

加载 MEMORY.md 索引，报告知识库子文件状态。

## 首次启动特殊处理

如果是首次部署（检测到 `memory/context.base.md` 不存在）：
1. 提示大哥运行 `bash ~/.openclaw/workspace/scripts/athena-init-memory.sh`
2. 等待大哥确认知识库初始化完成
