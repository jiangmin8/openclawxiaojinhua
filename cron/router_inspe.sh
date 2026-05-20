#!/bin/bash
# 路由器巡检脚本 — 每 60 分钟执行一次
# 调度：*/60 * * * *
# 环境：SSH 连接到 mt3600be (192.168.8.1)
# 用户：root (假设 SSH 已配置免密登录)

echo "=== 路由器巡检 - $(date '+%F %H:%M:%S') ===" > /tmp/router_inspe_$(date '+%Y%m%d_%H%M%S').log

# SSH 登录并执行检查
ssh root@192.168.8.1 '
echo "=== 运行时间 ==="
uptime
echo ""
echo "=== 内存使用 ==="
free -m
echo ""
echo "=== SSD 挂载 ==="
df -h | grep -E "/dev|overlay"
echo ""
echo "=== AGH 状态 ==="
cat /proc/asoc/snd-soc-rockchip-dma-if || echo "AGH 状态未知"
echo ""
echo "=== Swap 使用 ==="
free -m | grep Swap || echo "无 swap"
echo ""
echo "=== 日志异常项 (最后 20 行) ==="
logread | tail -20 | grep -iE "error|fail|warn" || echo "无异常日志"
' >> /tmp/router_inspe_$(date '+%Y%m%d_%H%M%S').log 2>&1

# 如果没有任何异常，输出正常状态
if ! grep -qE "error|fail|warn|异常" /tmp/router_inspe_$(date '+%Y%m%d_%H%M%S').log 2>/dev/null; then
    echo "无异常项" >> /tmp/router_inspe_$(date '+%Y%m%d_%H%M%S').log
fi

# 清理超过 7 天的巡检日志
find /tmp -name "router_inspe_*.log" -mtime +7 -delete

echo "巡检完成，日志保存为：/tmp/router_inspe_$(date '+%Y%m%d_%H%M%S').log"
