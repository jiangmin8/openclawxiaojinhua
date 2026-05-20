#!/bin/bash
# ============================================================
# 雅典娜 - 启动自检脚本
# 用途：检查系统健康状态，验证核心文件完整性
# 执行方式：bash ~/.openclaw/workspace-athena/scripts/athena-boot.sh
# 注意：无需任何参数，直接运行即可
# ============================================================

set -euo pipefail

# --- 路径配置 ---
OPENCLAW_ROOT="/home/lz/.openclaw"
WORKSPACE_DIR="$OPENCLAW_ROOT/workspace-athena"
SECURITY_DIR="$WORKSPACE_DIR/.security"
CHECKSUM_FILE="$SECURITY_DIR/checksums.sha256"
TIMESTAMP=$(date +%Y-%m-%d_%H:%M:%S)
ERRORS=0
WARNINGS=0

echo "=========================================="
echo "  雅典娜 - 启动自检"
echo "  时间：$TIMESTAMP"
echo "=========================================="

# --- 1. 核心文件存在性检查 ---
echo ""
echo "[1/6] 检查核心文件..."
CORE_FILES=("AGENTS.md" "SOUL.md" "TOOLS.md" "USER.md" "IDENTITY.md" "HEARTBEAT.md" "MEMORY.md" "BOOT.md" "CHANGELOG.md")

for file in "${CORE_FILES[@]}"; do
    if [ -f "$WORKSPACE_DIR/$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file — 文件不存在！"
        ((ERRORS++))
    fi
done

# --- 2. SHA256 完整性验证 ---
echo ""
echo "[2/6] 验证文件完整性..."
if [ -f "$CHECKSUM_FILE" ]; then
    CHECK_RESULT=$(cd "$WORKSPACE_DIR" && sha256sum -c "$CHECKSUM_FILE" 2>&1 || true)
    FAILED=$(echo "$CHECK_RESULT" | grep -c "FAILED" || true)
    if [ "$FAILED" -eq 0 ]; then
        echo "  ✅ 所有核心文件完整性验证通过"
    else
        echo "  ❌ $FAILED 个文件完整性验证失败！"
        echo "$CHECK_RESULT" | grep "FAILED"
        ((ERRORS++))
    fi
else
    echo "  ⚠️ checksums.sha256 不存在，跳过完整性验证"
    ((WARNINGS++))
fi

# --- 3. Ollama 服务检查 ---
echo ""
echo "[3/6] 检查 Ollama 服务..."
if curl -s --connect-timeout 5 http://127.0.0.1:11434/api/tags > /dev/null 2>&1; then
    MODEL_COUNT=$(curl -s http://127.0.0.1:11434/api/tags | python3 -c "import sys,json; print(len(json.load(sys.stdin).get('models',[])))" 2>/dev/null || echo "未知")
    echo "  ✅ Ollama 运行中（已加载 $MODEL_COUNT 个模型）"
else
    echo "  ❌ Ollama 服务不可达"
    ((ERRORS++))
fi

# --- 4. Gateway 服务检查 ---
echo ""
echo "[4/6] 检查 OpenClaw Gateway..."
if curl -s --connect-timeout 5 http://127.0.0.1:18789 > /dev/null 2>&1; then
    echo "  ✅ Gateway 运行中（端口 18789）"
else
    echo "  ⚠️ Gateway 不可达（可能尚未启动）"
    ((WARNINGS++))
fi

# --- 5. 磁盘空间检查 ---
echo ""
echo "[5/6] 检查磁盘空间..."
THRESHOLD=20
for mount in /mnt/d /mnt/e /mnt/f /mnt/g /mnt/sda1; do
    if mountpoint -q "$mount" 2>/dev/null; then
        USAGE=$(df "$mount" | awk 'NR==2{gsub(/%/,"",$5); print $5}')
        AVAIL=$(df -h "$mount" | awk 'NR==2{print $4}')
        if [ "$USAGE" -gt $((100 - THRESHOLD)) ]; then
            echo "  ❌ $mount — 已使用 ${USAGE}%，剩余 ${AVAIL}（低于 ${THRESHOLD}% 阈值）"
            ((ERRORS++))
        else
            echo "  ✅ $mount — 已使用 ${USAGE}%，剩余 ${AVAIL}"
        fi
    else
        echo "  ⚠️ $mount — 未挂载"
        ((WARNINGS++))
    fi
done

# --- 6. 知识库状态 ---
echo ""
echo "[6/6] 检查知识库状态..."
MEMORY_FILES=("context.base.md" "context.project.md" "context.user.pref.md" "context.archive.md" "context.kb.md")
for file in "${MEMORY_FILES[@]}"; do
    if [ -f "$WORKSPACE_DIR/memory/$file" ]; then
        SIZE=$(wc -c < "$WORKSPACE_DIR/memory/$file")
        echo "  ✅ memory/$file（${SIZE} 字节）"
    else
        echo "  ⚠️ memory/$file — 不存在"
        ((WARNINGS++))
    fi
done

# --- 汇总报告 ---
echo ""
echo "=========================================="
echo "  自检报告"
echo "=========================================="
echo "  错误：$ERRORS"
echo "  警告：$WARNINGS"
if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    echo "  状态：✅ 一切正常，雅典娜已准备就绪"
elif [ "$ERRORS" -eq 0 ]; then
    echo "  状态：⚠️ 存在 $WARNINGS 个警告，建议检查"
else
    echo "  状态：❌ 存在 $ERRORS 个错误，需要大哥关注"
fi
echo "=========================================="

# 写入日志
mkdir -p "$WORKSPACE_DIR/memory/logs"
echo "[$TIMESTAMP] boot_check | errors=$ERRORS | warnings=$WARNINGS" >> "$WORKSPACE_DIR/memory/logs/operation.log"
