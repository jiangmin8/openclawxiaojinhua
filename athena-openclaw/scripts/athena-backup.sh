#!/bin/bash
# ============================================================
# 雅典娜 - 快照备份脚本
# 用途：备份所有核心文件至 /mnt/sda1/backups/
# 执行方式：bash ~/.openclaw/workspace/scripts/athena-backup.sh
# 注意：无需任何参数，直接运行即可
# ============================================================

set -euo pipefail

# --- 路径配置 ---
OPENCLAW_ROOT="/home/lz/.openclaw"
WORKSPACE_DIR="$OPENCLAW_ROOT/workspace"
BACKUP_ROOT="/mnt/sda1/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"
LOG_FILE="$WORKSPACE_DIR/memory/logs/operation.log"

echo "=========================================="
echo "  雅典娜 - 快照备份"
echo "  时间：$TIMESTAMP"
echo "=========================================="

# --- 创建备份目录 ---
mkdir -p "$BACKUP_DIR"

# --- 备份核心 MD 文件（从 workspace 目录） ---
echo ""
echo "[1/4] 备份核心文件..."
CORE_FILES=("AGENTS.md" "SOUL.md" "TOOLS.md" "USER.md" "IDENTITY.md" "HEARTBEAT.md" "MEMORY.md" "BOOT.md" "CHANGELOG.md")
for file in "${CORE_FILES[@]}"; do
    if [ -f "$WORKSPACE_DIR/$file" ]; then
        cp "$WORKSPACE_DIR/$file" "$BACKUP_DIR/"
        echo "  ✅ $file"
    else
        echo "  ⚠️ $file — 不存在，跳过"
    fi
done

# --- 备份知识库 ---
echo ""
echo "[2/4] 备份知识库..."
if [ -d "$WORKSPACE_DIR/memory" ]; then
    cp -r "$WORKSPACE_DIR/memory" "$BACKUP_DIR/"
    echo "  ✅ memory/ 目录"
else
    echo "  ⚠️ memory/ 目录不存在"
fi

# --- 备份安全指纹 ---
echo ""
echo "[3/4] 备份安全指纹..."
if [ -f "$WORKSPACE_DIR/.security/checksums.sha256" ]; then
    cp "$WORKSPACE_DIR/.security/checksums.sha256" "$BACKUP_DIR/"
    echo "  ✅ checksums.sha256"
else
    echo "  ⚠️ checksums.sha256 不存在"
fi

# --- 生成备份校验文件 ---
echo ""
echo "[4/4] 生成校验文件..."
(cd "$BACKUP_DIR" && sha256sum AGENTS.md SOUL.md TOOLS.md USER.md IDENTITY.md HEARTBEAT.md MEMORY.md BOOT.md CHANGELOG.md > backup_checksums.sha256 2>/dev/null || true)
echo "  ✅ backup_checksums.sha256"

# --- 记录审计日志 ---
mkdir -p "$WORKSPACE_DIR/memory/logs"
echo "[$TIMESTAMP] backup | target=$BACKUP_DIR | files=${#CORE_FILES[@]} | result=success" >> "$LOG_FILE"

# --- 清理超过 30 天的旧备份 ---
echo ""
echo "清理旧备份（保留 30 天）..."
find "$BACKUP_ROOT" -maxdepth 1 -type d -mtime +30 -exec rm -rf {} + 2>/dev/null || true
echo "  ✅ 清理完成"

echo ""
echo "=========================================="
echo "  ✅ 备份完成！"
echo "  位置：$BACKUP_DIR"
echo "=========================================="
