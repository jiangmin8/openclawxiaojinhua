#!/bin/bash
# ============================================================
# 雅典娜 - 守护任务执行器
# 用途：执行定时检查任务（API连通性、资源监控、路由器状态）
# 执行方式：bash ~/.openclaw/workspace/scripts/athena-heartbeat.sh
# 注意：通常由 cron 或 OpenClaw heartbeat 自动调用
# ============================================================

set -euo pipefail

# --- 路径配置 ---
OPENCLAW_ROOT="/home/lz/.openclaw"
WORKSPACE_DIR="$OPENCLAW_ROOT/workspace"
LOG_FILE="$WORKSPACE_DIR/memory/logs/heartbeat.log"
TIMESTAMP=$(date +%Y-%m-%d_%H:%M:%S)
ALERTS=""

log() {
    echo "[$TIMESTAMP] $1" >> "$LOG_FILE"
    echo "  $1"
}

# --- 高频检查 ---
check_api() {
    if curl -s --connect-timeout 5 http://127.0.0.1:11434/api/tags > /dev/null 2>&1; then
        log "✅ Ollama API 正常"
    else
        log "❌ Ollama API 不可达"
        ALERTS="$ALERTS\n[P1] Ollama API 不可达，尝试重启..."
        systemctl --user restart ollama 2>/dev/null || true
        sleep 3
        if curl -s --connect-timeout 5 http://127.0.0.1:11434/api/tags > /dev/null 2>&1; then
            log "✅ Ollama 重启成功"
        else
            ALERTS="$ALERTS\n[P0] Ollama 重启后仍不可达，需要大哥介入"
        fi
    fi
}

check_gateway() {
    if curl -s --connect-timeout 5 http://127.0.0.1:18789 > /dev/null 2>&1; then
        log "✅ Gateway 正常"
    else
        log "⚠️ Gateway 不可达"
        ALERTS="$ALERTS\n[P2] Gateway 不可达，将在下一心跳重试"
    fi
}

check_router() {
    # 从 context.base.md 读取路由器 IP
    ROUTER_IP="192.168.8.1"
    if ping -c 1 -W 3 "$ROUTER_IP" > /dev/null 2>&1; then
        log "✅ 路由器 $ROUTER_IP 可达"
    else
        ALERTS="$ALERTS\n[P1] 路由器 $ROUTER_IP 不可达"
        log "❌ 路由器 $ROUTER_IP 不可达"
    fi
}

# --- 资源检查 ---
check_resources() {
    # 内存检查
    MEM_PERCENT=$(free | awk '/^Mem:/{printf "%.0f", $3/$2*100}')
    if [ "$MEM_PERCENT" -gt 85 ]; then
        ALERTS="$ALERTS\n[P1] 内存使用率 ${MEM_PERCENT}%，超过 85% 阈值"
        log "❌ 内存使用率 ${MEM_PERCENT}%"
    else
        log "✅ 内存使用率 ${MEM_PERCENT}%"
    fi

    # 磁盘检查
    for mount in /mnt/d /mnt/e /mnt/f /mnt/g /mnt/sda1; do
        if mountpoint -q "$mount" 2>/dev/null; then
            USAGE=$(df "$mount" | awk 'NR==2{gsub(/%/,"",$5); print $5}')
            if [ "$USAGE" -gt 80 ]; then
                ALERTS="$ALERTS\n[P1] ${mount} 磁盘使用率 ${USAGE}%"
                log "❌ ${mount} 使用率 ${USAGE}%"
            else
                log "✅ ${mount} 使用率 ${USAGE}%"
            fi
        fi
    done

    # GPU 检查
    if command -v nvidia-smi &>/dev/null; then
        GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader 2>/dev/null || echo "N/A")
        GPU_MEM_USED=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader 2>/dev/null || echo "N/A")
        log "✅ GPU 温度 ${GPU_TEMP}°C，显存使用 ${GPU_MEM_USED}"
    fi
}

# --- 执行 ---
echo "=========================================="
echo "  雅典娜 - 守护检查 $TIMESTAMP"
echo "=========================================="

check_api
check_gateway
check_router
check_resources

# --- 输出告警 ---
if [ -n "$ALERTS" ]; then
    echo ""
    echo "⚠️ 告警："
    echo -e "$ALERTS"
fi

echo "=========================================="
