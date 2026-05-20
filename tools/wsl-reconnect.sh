#!/bin/bash
# ==========================================
# WSL 断线重连 + 服务保活脚本
# 每 5 分钟检查一次
# 由雅典娜管理 — 不要手动删除
# ==========================================

LOG=/tmp/reconnect.log
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 启动保活循环" >> $LOG

while true; do
  # 1. 检查 OpenClaw Gateway
  if ! systemctl --user is-active openclaw-gateway &>/dev/null; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Gateway 掉线，正在重启..." >> $LOG
    systemctl --user restart openclaw-gateway
    sleep 5
    if systemctl --user is-active openclaw-gateway &>/dev/null; then
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] Gateway 恢复成功" >> $LOG
    else
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] Gateway 恢复失败" >> $LOG
    fi
  fi

  # 2. 检查 Tailscale
  if ! tailscale status &>/dev/null; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Tailscale 掉线，重新连接..." >> $LOG
    tailscale up 2>/dev/null
  fi

  # 3. 检查网络连通性（ping 路由器网关）
  if ! ping -c 1 -W 3 192.168.8.1 &>/dev/null; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 网络不通，等待..." >> $LOG
  fi

  sleep 300  # 每 5 分钟检查一次
done
