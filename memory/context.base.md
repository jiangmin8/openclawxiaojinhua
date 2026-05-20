---
title: 环境基础信息
version: 2.0
date: 2026-05-15
tags:
  - environment
  - base-context
auto_generated: true
---

# 环境基础信息

> 由 `athena-init-memory.sh` 自动采集 + 大哥手动补充
> **更新规则：** 硬件/网络变更时更新本文档

## 设备信息

| 项目 | 配置 |
|:---|:---|
| **操作系统** | WSL2 Ubuntu 24.04 (Linux 6.6.87.2-microsoft-standard-WSL2, systemd) |
| **CPU** | Intel i5-10400F（6核12线程，基础频率 2.9GHz） |
| **内存** | 32GB DDR4（WSL2 分配 ~23GB，max 12GB cgroup 限制） |
| **GPU** | NVIDIA RTX 3060 12GB（CUDA 8.6） |
| **存储** | 1TB M.2 NVMe SSD |

## 网络拓扑

```
光猫 → MT3600BE (PPPoE拨号 + 主路由) → RA80 (交换机 + AP) → PC
```

### 设备清单

| 设备 | IP | 角色 | SSH | 固件 | 内存 |
|:---|:---|:---|:---|:---|:---|
| **GL-MT3600BE** | 192.168.8.1 | 主路由 | `ssh -i ~/.ssh/router_new root@192.168.8.1` | 4.8.7 | 492MB |
| **Xiaomi AX3000 RA80** | 192.168.8.178 (DHCP) | 交换机+AP | `ssh root@192.168.8.178` | 1.0.46 | 256MB |

### 已知设备 MAC

| 设备 | MAC |
|:---|:---|
| iPhone 17 | 68:30:36:6C:02:ED |
| 荣耀畅玩60M | C2:54:7E:FE:12:55 |
| iPhone 备用 | 96:79:62:2f:cf:68 |

## 网络配置

| 项目 | 值 |
|:---|:---|
| **网关 IP** | 192.168.8.1 (MT3600BE) |
| **代理** | Clash (Windows 侧，国内直连，国外走代理) |
| **DNS** | 由路由器 DHCP 分配 |

## 磁盘分区

| 挂载点 | 盘符 | 大小 | 用途 |
|:---|:---|:---|:---|
| `/mnt/d` | D: | 400GB | AI 模型（Ollama、HuggingFace） |
| `/mnt/e` | E: | 300GB | 核心工作区（代码、项目、venv） |
| `/mnt/f` | F: | 200GB | 环境与缓存（pip、conda、torch） |
| `/mnt/g` | G: | 54GB | 冷存储（日志、备份、临时文件） |

## API 配置

| 项目 | 值 |
|:---|:---|
| **Gateway** | OpenClaw v2026.5.12 |
| **Gateway 端口** | 18789 |
| **Gateway UI** | http://localhost:18789 |
| **默认模型** | deepseek/deepseek-v4-pro |
| **本地 AI** | Ollama (RTX 3060 12GB, 20 个模型) |
| **API Key 存储** | `~/.openclaw/openclaw.json` → models.providers |

## 服务配置

| 服务 | 端口 | 管理命令 |
|:---|:---|:---|
| **OpenClaw Gateway** | 18789 | `systemctl --user restart openclaw-gateway` |
| **Ollama** | 11434 | 直接运行 `ollama serve`（非 systemd 服务） |

## 模型切换脚本

| 脚本 | 用途 |
|:---|:---|
| `~/scripts/switch-model.sh flash` | 日常聊天 |
| `~/scripts/switch-model.sh pro` | 重要任务 |
| `~/scripts/switch-model.sh llama` | 自动化 |

## 关键路径

```
OpenClaw 根目录: ~/.openclaw/
├── 工作区: ~/.openclaw/workspace/
│   ├── 核心协议: ~/.openclaw/workspace/*.md
│   ├── 知识库: ~/.openclaw/workspace/memory/
│   ├── 脚本: ~/.openclaw/workspace/scripts/
│   ├── 安全: ~/.openclaw/workspace/.security/
│   └── 备份缓存: ~/.openclaw/workspace/.backups/
├── 配置: ~/.openclaw/openclaw.json
└── Cron: ~/.openclaw/cron/jobs.json

备份路径: /mnt/g/backups/  + /mnt/g/athena-core-backup/
模型脚本: ~/scripts/
Ollama 模型: /mnt/d/ollama/
```
