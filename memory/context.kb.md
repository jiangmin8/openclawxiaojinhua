---
title: 专题知识库
version: 2.0
date: 2026-05-15
tags:
  - knowledge-base
  - openclaw
  - ollama
  - networking
---

# 专题知识库

> **更新规则：** 雅典娜在执行过程中获得的新知识自动写入对应章节

## OpenClaw

### 核心概念

- **OpenClaw**：雅典娜的运行时宿主平台，提供 Gateway 服务（端口 18789）、工具调度与文件系统代理能力
- **Gateway**：核心服务，负责 API 调用转发和工具调度
- **coding-agent**：核心执行代理，处理代码生成和文件操作

### 版本信息

| 项目 | 值 |
|:---|:---|
| 版本 | v2026.5.12 |
| Gateway 端口 | 18789 |
| Gateway UI | http://localhost:18789 |
| 配置文件 | `~/.openclaw/openclaw.json` |
| Cron 配置 | `~/.openclaw/cron/jobs.json` |
| Token 查询 | `cat ~/.openclaw/openclaw.json` → models.providers |

### 常用操作

| 操作 | 命令 |
|:---|:---|
| Gateway 重启 | `systemctl --user restart openclaw-gateway` |
| Gateway 状态 | `systemctl --user status openclaw-gateway` |
| Gateway 日志 | `journalctl --user -u openclaw-gateway -f` |
| Gateway UI | http://localhost:18789 |

### 模型切换

| 脚本 | 用途 |
|:---|:---|
| `~/scripts/switch-model.sh flash` | 日常聊天 |
| `~/scripts/switch-model.sh pro` | 重要任务 |
| `~/scripts/switch-model.sh llama` | 自动化 |

---

## 网络设备

### 网络拓扑

```
光猫 → MT3600BE (PPPoE拨号 + 主路由) → RA80 (交换机 + AP) → PC
```

### GL-MT3600BE（主路由）

| 项目 | 值 |
|:---|:---|
| IP | 192.168.8.1 |
| 角色 | PPPoE 拨号 + 主路由 |
| 固件版本 | 4.8.7 |
| 内存 | 492MB |
| SSH | `ssh -i ~/.ssh/router_new root@192.168.8.1` |

### Xiaomi AX3000 RA80（交换机+AP）

| 项目 | 值 |
|:---|:---|
| IP | 192.168.8.178 (DHCP) |
| 角色 | 交换机 + AP |
| 固件版本 | 1.0.46 |
| 内存 | 256MB |
| SSH | `ssh root@192.168.8.178` |

### 已知设备 MAC

| 设备 | MAC |
|:---|:---|
| iPhone 17 | 68:30:36:6C:02:ED |
| 荣耀畅玩60M | C2:54:7E:FE:12:55 |
| iPhone 备用 | 96:79:62:2f:cf:68 |

---

## Ollama

### 配置

| 项目 | 值 |
|:---|:---|
| 安装路径 | `/usr/local/bin/ollama` |
| 模型存储 | `/mnt/d/ollama` |
| 服务端口 | 11434 |
| GPU | CUDA 8.6，RTX 3060 12GB |
| 已安装模型 | 20 个 |

### 常用操作

| 操作 | 命令 |
|:---|:---|
| 启动服务 | `systemctl --user start ollama` |
| 查看已安装模型 | `ollama list` |
| 下载模型 | `ollama pull {model_name}` |
| 删除模型 | `ollama rm {model_name}` |
| 查看模型信息 | `ollama show {model_name}` |

### RTX 3060 12GB 已安装模型（20个）

| 模型 | 大小 | 量化 | 用途 |
|:---|:---|:---|:---|
| qwen2.5:14b | 9.0GB | — | 中文+推理最强 |
| qwen2.5:14b-q3km | 7.3GB | Q3_K_M | 中文+推理（压缩） |
| dage-junshi:latest | 4.7GB | — | 军事大哥（完整） |
| dage-junshi-q4:latest | 4.4GB | Q4 | 军事大哥 |
| dage-junshi-q4_0:latest | 4.4GB | Q4_0 | 军事大哥 |
| dage-zhiku:latest | 4.7GB | — | 智库大哥（完整） |
| dage-zhiku-q4:latest | 4.4GB | Q4 | 智库大哥 |
| dage-zhiku-q4_0:latest | 4.4GB | Q4_0 | 智库大哥 |
| clio-eye:latest | 5.5GB | — | 视觉分析 |
| minicpm-v:8b | 5.5GB | — | 多模态视觉 |
| clio-scout:latest | 4.9GB | — | 信息侦察 |
| clio-coder:latest | 4.7GB | — | 代码生成 |
| deepseek-r1:7b | 4.7GB | — | 深度推理 |
| qwen2.5-coder:7b | 4.7GB | — | 代码专用 |
| qwen2.5:7b | 4.7GB | — | 通用中文 |
| llama3.1:8b | 4.9GB | — | 通用对话 |
| dage-shaobing:latest | 986MB | — | 哨兵大哥（轻量） |
| dage-mingke:latest | 274MB | — | 命理大哥（极轻） |
| qwen2.5:1.5b | 986MB | — | 极速响应 |
| nomic-embed-text:latest | 274MB | — | 文本嵌入 |

---

## WSL2

### 系统信息

| 项目 | 值 |
|:---|:---|
| 发行版 | Ubuntu 24.04 |
| 内核 | Linux 6.6.87.2-microsoft-standard-WSL2 |
| systemd | ✅ 已启用 |

### 资源分配

| 资源 | 分配值 | 总量 |
|:---|:---|:---|
| 内存 | 12GB | 32GB |
| CPU | 8 核 | 12 线程 |
| Swap | 4GB | — |

### 常用操作

| 操作 | 命令 |
|:---|:---|
| 关闭 WSL | `wsl --shutdown`（Windows PowerShell） |
| 检查磁盘 | `df -h /mnt/{d,e,f,g}` |
| 检查内存 | `free -h` |
| 检查 GPU | `nvidia-smi` |

---

## Python

### 环境配置

| 项目 | 值 |
|:---|:---|
| Python | 3.12 |
| PyTorch | 2.1.0+cu118 |
| 虚拟环境 | `/mnt/e/venv` |

### 常用操作

| 操作 | 命令 |
|:---|:---|
| 创建虚拟环境 | `python3.12 -m venv /mnt/e/venv` |
| 激活虚拟环境 | `source /mnt/e/venv/bin/activate` |
| 清理 pip 缓存 | `pip cache purge` |
| 验证 CUDA | `python -c "import torch; print(torch.cuda.is_available())"` |
