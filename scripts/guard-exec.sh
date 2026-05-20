#!/bin/bash
# ============================================================
# guard-exec.sh — 雅典娜命令拦截器 v1.1
# 用途：在实际执行 shell 命令前检查是否违反约束
# 用法：guard-exec.sh "<要执行的命令>"
# 返回值：0 = 放行，1 = 拦截
# ============================================================

set -euo pipefail

COMMAND="${1:-}"
WORKSPACE="/home/lz/.openclaw/workspace-athena"
LOG_DIR="$WORKSPACE/memory/logs"
LOG_FILE="$LOG_DIR/guard.log"

mkdir -p "$LOG_DIR" 2>/dev/null || true

log_guard() {
    echo "[$(date -Iseconds)] $1" >> "$LOG_FILE"
}

# ============================================
# 硬编码禁止模式（bash 兼容正则）
# ============================================
FORBIDDEN_PATTERNS=(
    "sudo[[:space:]]+rm[[:space:]]+-rf[[:space:]]+/"
    "sudo[[:space:]]+rm[[:space:]]+-rf[[:space:]]+--no-preserve-root"
    "rm[[:space:]]+-rf[[:space:]]+/"
    "chmod[[:space:]]+777"
    "dd[[:space:]]+if="
    "mkfs[.]"
    "curl.*[|][[:space:]]*(ba)?sh"
    "wget.*[|][[:space:]]*(ba)?sh"
    ">[[:space:]]*/dev/sd"
)

FORBIDDEN_PATHS=(
    "/mnt/c/"
    "/etc/"
    "/usr/"
    "/boot/"
    "/sys/"
    "/proc/"
    "/root/"
)

# ============================================
# 检查1：命令黑名单
# ============================================
check_forbidden_commands() {
    for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
        if [[ "$COMMAND" =~ $pattern ]]; then
            echo "=============================================="
            echo "  ⛔ [BLOCKED] 命令被 guard-exec.sh 拦截"
            echo "  匹配模式：$pattern"
            echo "  命令：$COMMAND"
            echo "  操作已中止。如需执行请联系大哥授权。"
            echo "=============================================="
            log_guard "BLOCKED | pattern=$pattern | cmd=$COMMAND"
            exit 1
        fi
    done
}

# ============================================
# 检查2：禁止路径写入
# ============================================
check_path_violation() {
    for forbidden in "${FORBIDDEN_PATHS[@]}"; do
        # 检测重定向写入：> /etc/... 或 >> /etc/...
        if echo "$COMMAND" | grep -qE ">[[:space:]]*${forbidden}"; then
            echo "=============================================="
            echo "  ⛔ [BLOCKED] 写入禁止路径被拦截"
            echo "  禁止路径：$forbidden"
            echo "  命令：$COMMAND"
            echo "=============================================="
            log_guard "BLOCKED_PATH | forbidden=$forbidden | cmd=$COMMAND"
            exit 1
        fi
        # 检测 cp/mv/mkdir/touch 到禁止路径
        if echo "$COMMAND" | grep -qE "(cp|mv|mkdir|touch|install)[[:space:]].*${forbidden}"; then
            echo "=============================================="
            echo "  ⛔ [BLOCKED] 操作禁止路径被拦截"
            echo "  禁止路径：$forbidden"
            echo "  命令：$COMMAND"
            echo "=============================================="
            log_guard "BLOCKED_PATH_OP | forbidden=$forbidden | cmd=$COMMAND"
            exit 1
        fi
    done
}

# ============================================
# 检查3：禁止监听 0.0.0.0
# ============================================
check_port_listen() {
    if echo "$COMMAND" | grep -qE "(listen|bind|--host)[[:space:]]+0\.0\.0\.0"; then
        echo "=============================================="
        echo "  ⛔ [BLOCKED] 禁止监听 0.0.0.0"
        echo "  命令：$COMMAND"
        echo "=============================================="
        log_guard "BLOCKED_PORT | cmd=$COMMAND"
        exit 1
    fi
}

# ============================================
# 主流程
# ============================================
if [ -z "$COMMAND" ]; then
    echo "用法: guard-exec.sh <命令>"
    exit 2
fi

check_forbidden_commands
check_path_violation
check_port_listen

# 全部通过
log_guard "ALLOWED | cmd=$COMMAND"
exit 0
