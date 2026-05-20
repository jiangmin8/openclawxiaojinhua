# OpenClaw 脚本清单

**chat_id**: `19df6504-2fa2-87ab-8000-09345fc3b141`  |  **消息數**: 2

---

### 🤖 Kimi
*2026-05-05T04:05:48.410335Z*

> 💭 用户希望我把这份"脚本清单"简化，去掉臃肿的描述，只保留核心要点。这是一个内容精简/编辑任务，不需要工具，直接给出精简版即可。

让我分析原文的核心信息：

1. 脚本位置：`~/.openclaw/scripts/`
2. 5个脚本及其功能：
   - openclaw-session.sh (主脚本，整合save/resume/shutdown)
   - openclaw-save.sh
   - openclaw-shutdown.sh  
   - openclaw-startup.sh
   - clean-old-backups.sh
3. 推荐使用 `openclaw-session.sh`，其他是单功能版
4. 还有一个 `start-offline.sh` 在备份目录里，建议搬到 scripts
5. workspace 里有个关机记忆逻辑文档待更新

精简策略：
- 去掉表格格式，改用更紧凑的列表
- 去掉"关系说明"的 ASCII 图，用一句话表达
- 合并重复信息
- 保留路径、核心功能、推荐用法

精简版：

---

## `~/.openclaw/scripts/`

| 脚本 | 功能 | 用法 |
|------|------|------|
| `openclaw-session.sh` | **主脚本**：保存 / 恢复 / 关机 | `save` \| `resume` \| `shutdown` |
| `openclaw-save.sh` | 单功能：保存进度 | 独立版，功能已并入主脚本 |
| `openclaw-shutdown.sh` | 单功能：关机备份 + 停 Gateway | 同上 |
| `openclaw-startup.sh` | 单功能：开机读取备份，清理工作台 | 同上 |
| `clean-old-backups.sh` | 清理 6 小时前的旧备份 | 定时调用 |

> **推荐只用 `openclaw-session.sh`**，其余四个是拆出的单功能备用版。

**待迁移**：`~/.openclaw/backups/20260501_2349/start-offline.sh`（本地 Ollama / DeepSeek 切换）→ 建议搬到 `scripts/` 统一管理。

**待更新**：`workspace/📋_关机记忆逻辑.md` — 等方案定稿后同步。

---

这样从原来 50 多行压到 15 行左右，保留路径、功能、用法、推荐方式和待办事项，去掉重复的 ASCII 关系图和冗余状态列。

---

### 🧑 用戶
*2026-05-05T04:05:48.410332Z*

# 脚本清单

> 所有 OpenClaw 配套脚本，按位置和功能列出。
> 更新日期：2026-05-05

---

## 位置：`~/.openclaw/scripts/`

| 脚本 | 功能 | 调用方式 | 状态 |
|------|------|----------|------|
| `openclaw-session.sh` | 会话备份/恢复/关机管理（主脚本） | `bash openclaw-session.sh save\|resume\|shutdown` | ✅ |
| `openclaw-save.sh` | 中途保存进度 | `bash openclaw-save.sh` | ✅ |
| `openclaw-shutdown.sh` | 关机备份 + 停 Gateway | `bash openclaw-shutdown.sh` | ✅ |
| `openclaw-startup.sh` | 开机读取旧备份，清理工作台 | `bash openclaw-startup.sh` | ✅ |
| `clean-old-backups.sh` | 删除 6 小时前的旧备份 | `bash clean-old-backups.sh` | ✅ |

### 关系说明
```
openclaw-session.sh  ← 整合版（推荐使用）
    ├── save      → 同 openclaw-save.sh
    ├── resume    → 同 openclaw-startup.sh（只读部分）
    └── shutdown  → 同 openclaw-shutdown.sh
```
推荐只用 `openclaw-session.sh`，其他是拆出来的单功能版。

---

## 位置：`~/.openclaw/backups/20260501_2349/`

| 脚本 | 功能 | 调用方式 | 状态 |
|------|------|----------|------|
| `start-offline.sh` | 一键切换本地 Ollama / DeepSeek API | `bash start-offline.sh offline\|online` | ✅ |

**建议：** 搬到 `~/.openclaw/scripts/` 统一管理。

---

## 位置：`~/.openclaw/workspace/`

| 文件 | 说明 | 状态 |
|------|------|------|
| `📋_关机记忆逻辑.md` | 关机流程逻辑文档 | ⏳ 等待最终方案定稿后更新 |

---

## 与「关机记忆逻辑」相关的脚本

| 脚本 | 在本逻辑中的角色 |
|------|-----------------|
| `openclaw-session.sh` | **核心脚本** — 整合 save（备份） + resume（开机读取） + shutdown（关机触发） |
| `openclaw-startup.sh` | 开机清理+归档残余会话（兜底保险） |
| `clean-old-backups.sh` | 定期清理过期备份 |帮我把这个臃肿的记录减一下重，把核心要点精准的表达出来。。

---

