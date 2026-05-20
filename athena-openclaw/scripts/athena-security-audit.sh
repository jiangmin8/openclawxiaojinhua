#!/bin/bash
# ============================================================
# 雅典娜 - 安全自检脚本
# 用途：检查文件完整性、openclaw.json 权限、端口暴露、未知文件
# 执行方式：bash ~/.openclaw/workspace/scripts/athena-security-audit.sh
# 注意：通常由 cron 每日 03:00 自动执行
# ============================================================

set -euo pipefail

# --- 路径配置 ---
OPENCLAW_ROOT="/home/lz/.openclaw"
WORKSPACE_DIR="$OPENCLAW_ROOT/workspace"
SECURITY_DIR="$WORKSPACE_DIR/.security"
CHECKSUM_FILE="$SECURITY_DIR/checksums.sha256"
LOG_FILE="$WORKSPACE_DIR/memory/logs/security.log"
CONFIG_FILE="$OPENCLAW_ROOT/openclaw.json"
TIMESTAMP=$(date +%Y-%m-%d_%H:%M:%S)
ISSUES=0

log_security() {
    echo "[$TIMESTAMP] $1" >> "$LOG_FILE"
    echo "  $1"
}

echo "=========================================="
echo "  雅典娜 - 安全自检"
echo "  时间：$TIMESTAMP"
echo "=========================================="

# --- 1. 核心文件完整性 ---
echo ""
echo "[1/4] 检查核心文件完整性..."
if [ -f "$CHECKSUM_FILE" ]; then
    FAILED=$(cd "$WORKSPACE_DIR" && sha256sum -c "$CHECKSUM_FILE" 2>&1 | grep -c "FAILED" || true)
    if [ "$FAILED" -eq 0 ]; then
        log_security "✅ 核心文件完整性验证通过"
    else
        log_security "❌ $FAILED 个文件完整性验证失败！"
        ISSUES=$((ISSUES + FAILED))
    fi
else
    log_security "⚠️ checksums.sha256 不存在"
    ISSUES=$((ISSUES + 1))
fi

# --- 2. openclaw.json 文件权限 ---
echo ""
echo "[2/4] 检查 openclaw.json 文件权限..."
if [ -f "$CONFIG_FILE" ]; then
    PERMS=$(stat -c "%a" "$CONFIG_FILE" 2>/dev/null || echo "unknown")
    if [ "$PERMS" = "600" ]; then
        log_security "✅ openclaw.json 权限正确（600）"
    else
        log_security "❌ openclaw.json 权限为 $PERMS，应为 600"
        log_security "   修复命令：chmod 600 $CONFIG_FILE"
        ISSUES=$((ISSUES + 1))
    fi
else
    log_security "⚠️ openclaw.json 不存在（可能尚未配置）"
fi

# --- 3. 端口暴露检查 ---
echo ""
echo "[3/4] 检查端口暴露..."
EXPOSED=$(ss -tlnp 2>/dev/null | grep "0.0.0.0" || true)
if [ -z "$EXPOSED" ]; then
    log_security "✅ 未检测到 0.0.0.0 监听"
else
    log_security "❌ 检测到 0.0.0.0 监听："
    echo "$EXPOSED" | while read line; do
        log_security "   $line"
    done
    ISSUES=$((ISSUES + 1))
fi

# --- 4. 未知文件扫描 ---
echo ""
echo "[4/4] 扫描未知文件..."
KNOWN_FILES=("AGENTS.md" "SOUL.md" "TOOLS.md" "USER.md" "IDENTITY.md" "HEARTBEAT.md" "MEMORY.md" "BOOT.md" "CHANGELOG.md")
KNOWN_DIRS=("memory" "scripts" ".security" ".backups")

for item in "$WORKSPACE_DIR"/*; do
    [ -e "$item" ] || continue
    BASENAME=$(basename "$item")
    KNOWN=false
    for known in "${KNOWN_FILES[@]}" "${KNOWN_DIRS[@]}"; do
        if [ "$BASENAME" = "$known" ]; then
            KNOWN=true
            break
        fi
    done
    if [ "$KNOWN" = false ] && [ "${BASENAME:0:1}" != "." ]; then
        log_security "⚠️ 未知文件/目录：$BASENAME"
    fi
done

# --- 汇总 ---
echo ""
echo "=========================================="
if [ "$ISSUES" -eq 0 ]; then
    log_security "✅ 安全自检通过，未发现问题"
else
    log_security "❌ 发现 $ISSUES 个安全问题，需要大哥关注"
fi
echo "=========================================="
