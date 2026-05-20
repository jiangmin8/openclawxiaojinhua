#!/bin/bash
# ==========================================
# 反向 SSH 隧道：路由器 :2222 → WSL :22
# 用途：大哥通过 GoodCloud 登路由器后，ssh -p 2222 lz@localhost 进 WSL
# ==========================================
LOG=/tmp/wsl-tunnel.log
ROUTER="192.168.8.1"
KEY="/home/lz/.ssh/id_wsl_tunnel"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 启动反向隧道" >> $LOG

while true; do
  ssh -i "$KEY" \
      -o StrictHostKeyChecking=no \
      -o ServerAliveInterval=30 \
      -o ServerAliveCountMax=3 \
      -o ExitOnForwardFailure=yes \
      -N -R 2222:localhost:22 \
      root@$ROUTER 2>> $LOG
    
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] 隧道断开，5秒后重连..." >> $LOG
  sleep 5
done
