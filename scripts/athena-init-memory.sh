#!/bin/bash
# ============================================================
# 雅典娜 - 知识库初始化脚本
# 用途：自动采集环境信息，生成知识库初版
# 执行方式：bash ~/.openclaw/workspace/scripts/athena-init-memory.sh
# 注意：无需任何参数，直接运行即可
# ============================================================

set -euo pipefail

# --- 路径配置 ---
OPENCLAW_ROOT="/home/lz/.openclaw"
WORKSPACE_DIR="$OPENCLAW_ROOT/workspace"
MEMORY_DIR="$WORKSPACE_DIR/memory"
LOGS_DIR="$MEMORY_DIR/logs"
TIMESTAMP=$(date +%Y-%m-%d_%H:%M:%S)

echo "=========================================="
echo "  雅典娜 - 知识库初始化"
echo "  时间：$TIMESTAMP"
echo "=========================================="

# --- Step 1: 创建目录结构 ---
echo ""
echo "[1/4] 创建目录结构..."
mkdir -p "$MEMORY_DIR/logs"
mkdir -p "$WORKSPACE_DIR/scripts"
mkdir -p "$WORKSPACE_DIR/.security"
mkdir -p "$WORKSPACE_DIR/.backups"
echo "  ✅ 目录结构创建完成"

# --- Step 2: 自动采集环境信息 ---
echo ""
echo "[2/4] 自动采集环境信息..."

HOSTNAME_VAL=$(hostname)
CPU_INFO=$(lscpu | grep "Model name" | sed 's/Model name:[[:space:]]*//')
CPU_CORES=$(nproc)
MEM_TOTAL=$(free -h | awk '/^Mem:/{print $2}')
MEM_AVAIL=$(free -h | awk '/^Mem:/{print $7}')
GPU_INFO=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null || echo "未检测到 NVIDIA GPU")
GPU_MEM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader 2>/dev/null || echo "N/A")
WSL_VERSION=$(cat /proc/version 2>/dev/null | grep -oP 'Microsoft|WSL2' || echo "非 WSL 环境")

echo "  ✅ 环境信息采集完成"

# --- Step 3: 生成 context.base.md ---
echo ""
echo "[3/4] 生成环境信息文件..."

# 磁盘信息
DISK_INFO=""
for mount in /mnt/d /mnt/e /mnt/f /mnt/g; do
    if mountpoint -q "$mount" 2>/dev/null; then
        SIZE=$(df -h "$mount" | awk 'NR==2{print $2}')
        AVAIL=$(df -h "$mount" | awk 'NR==2{print $4}')
        DISK_INFO="${DISK_INFO}| \`$mount\` | ${SIZE} | ${AVAIL} 可用 |\n"
    fi
done
if mountpoint -q /mnt/sda1 2>/dev/null; then
    DISK_INFO="${DISK_INFO}| \`/mnt/sda1\` | 备份专用 | \`/mnt/sda1/backups/\` |\n"
fi

cat > "$MEMORY_DIR/context.base.md" << EOF
---
title: 环境基础信息
version: 2.0
date: $TIMESTAMP
tags:
  - environment
  - base-context
auto_generated: true
---

# 环境基础信息

> 由 \`athena-init-memory.sh\` 自动采集于 $TIMESTAMP
> **更新规则：** 硬件/网络变更时更新本文档

## 设备信息

| 项目 | 配置 |
|:---|:---|
| **操作系统** | $WSL_VERSION Ubuntu 24.04 |
| **CPU** | $CPU_INFO（$CPU_CORES 核） |
| **内存** | 总计 $MEM_TOTAL，可用 $MEM_AVAIL |
| **GPU** | $GPU_INFO（显存 $GPU_MEM） |
| **存储** | 1TB M.2 NVMe SSD |

## 网络配置

| 项目 | 值 |
|:---|:---|
| **网关 IP** | 192.168.8.1 (MT3600BE) |
| **代理** | Clash (Windows 侧) |
| **DNS** | 由路由器 DHCP 分配 |

## 磁盘分区

$DISK_INFO

## API 配置

| 项目 | 值 |
|:---|:---|
| **Gateway** | OpenClaw v2026.5.7 |
| **Gateway 端口** | 18789 |
| **Gateway UI** | http://localhost:18789 |
| **默认模型** | deepseek/deepseek-v4-pro |
| **API Key 存储** | \`~/.openclaw/openclaw.json\` |

## 快速操作

| 操作 | 命令 |
|:---|:---|
| Gateway 重启 | \`systemctl --user restart openclaw-gateway\` |
| Gateway UI | \`http://localhost:18789\` |
| Ollama 重启 | \`systemctl --user restart ollama\` |
| 磁盘检查 | \`df -h /mnt/{d,e,f,g}\` |
| 内存检查 | \`free -h\` |
| GPU 检查 | \`nvidia-smi\` |
EOF

echo "  ✅ context.base.md 生成完成"

# --- Step 4: 输出待填充清单 ---
echo ""
echo "[4/4] 初始化完成！"
echo ""
echo "  📝 以下文件已包含预填数据，大哥可审核补充："
echo "     - memory/context.base.md（环境基础信息）"
echo "     - memory/context.kb.md（专题知识库）"
echo "     - memory/context.user.pref.md（偏好设置）"
echo ""
echo "=========================================="
echo "  ✅ 知识库初始化完成！"
echo "=========================================="
