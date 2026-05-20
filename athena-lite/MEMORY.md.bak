# MEMORY.md — 雅典娜知识库

---

## 索引

| 文件 | 内容 | 优先级 |
| :--- | :--- | :--- |
| `memory/context.base.md` | 固定环境信息 — 设备、IP、端口、命令、硬件快照 | 基础 |
| `memory/context.project.md` | 当前项目上下文与进度 | 项目级 |
| `memory/context.archive.md` | 已完成项目归档（含关键决策） | 参考 |
| `memory/context.kb.md` | 专题知识库（OpenWrt、Ollama 等） | 知识 |
| `memory/context.user.pref.md` | 大哥偏好设置与习惯 | 个人化 |

---

## 快速操作

| 操作 | 命令 |
| :--- | :--- |
| Gateway 重启 | `systemctl --user restart openclaw-gateway` |
| Gateway UI | `http://localhost:18789` |
| Gateway 状态 | `systemctl --user status openclaw-gateway` |
| 日志查看 | `journalctl --user -u openclaw-gateway -f` |

---

## 记忆管理原则

- **时效性**：短期记忆保存7天，长期记忆归档至 `/mnt/g`
- **关联性**：按项目和主题建立知识关联
- **隐私性**：敏感信息加密存储
- **一致性**：保持与 `USER.md` 中定义的偏好一致

---

## 上下文维护

- **会话上下文**：单次会话内的完整对话历史
- **项目上下文**：跨会话的项目相关信息
- **知识上下文**：通用知识和参考资料

> 旧版记忆已备份至 `memory/archive/`