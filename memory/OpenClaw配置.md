# OpenClaw 配置 — Gateway + 模型 + Cron

## 系统架构
```
用户 (WebChat / QQ)
    ↓
OpenClaw Gateway (:18789)
    ↓
模型调度 → DeepSeek-V4-Pro (API, 主力对话)
          → qwen2.5:7b (本地, Cron 巡检)
          → deepseek-v4-flash (API, 备用轻量)
          → qwen2.5-coder:7b (本地, 代码)
          → deepseek-coder-v2:16b (本地, 代码)
          → deepseek-r1:8b (本地, 推理)
```

## 配置文件
| 文件 | 作用 |
|------|------|
| `~/.openclaw/openclaw.json` | 主配置 (mode=merge) |
| `~/.openclaw/agents/main/agent/models.json` | 模型定义 |
| `~/.openclaw/workspace/MEMORY.md` | 核心记忆 |
| `~/.openclaw/workspace/memory/` | 专题记忆 |

## 模型清单
| 模型 ID | 来源 | 用途 |
|---------|------|------|
| deepseek-v4-pro | API | 主力对话 |
| deepseek-v4-flash | API | 轻量任务 |
| qwen2.5:7b | 本地 | Cron 巡检 |
| qwen2.5-coder:7b | 本地 | 代码生成 |
| deepseek-coder-v2:16b | 本地 | 复杂代码 |
| deepseek-r1:8b | 本地 | 深度推理 |
| nomic-embed-text | 本地 | 知识库嵌入 |

## 6 个 Cron 任务
| 名称 | 频率 | 模型 | 静默 |
|------|------|------|------|
| 🫀 健康巡检 | 60min | qwen2.5:7b | 异常报 |
| 🖥️ PC巡检 | 30min | qwen2.5:7b | ✅ |
| 📡 路由器巡检 | 60min | qwen2.5:7b | ✅ |
| 🔴 RA80 保底检查 | 30min | qwen2.5:7b | ✅ |
| 🤖 Ollama 保活 | 15min | qwen2.5:7b | ✅ |
| 💾 备份检查 | 22:00 | qwen2.5:7b | 异常报 |

## 通道
- WebChat (当前, direct)
- QQ Bot (1903976111, 已配)

## 历史踩坑
- NVIDIA Key 在 models.json 无效 → 已删除该 provider
- Cron 全局用了已删除的 nvidia model → 已改成本地 qwen2.5
- Gateway 旧端口 3333 不存在 → 全部统一到 18789
