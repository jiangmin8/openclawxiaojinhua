#!/bin/bash
# 路由器巡检脚本 (mt3600be - 192.168.8.1)
# 只输出异常项

SSH_HOST="192.168.8.1"

echo "=== 路由器巡检报告 $(date '+%Y-%m-%d %H:%M') ==="

# SSH 连接检查
if [ -z "$(ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no -o User=root $SSH_HOST 2>/dev/null)" ]; then
    echo "⚠️  无法连接到路由器 $SSH_HOST"
else
    # Uptime
    echo "--- Uptime ---"
    ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no -o User=root $SSH_HOST 'uptime' 2>/dev/null | grep -v "^login\|^$" || echo "无法获取 uptime"

    # 内存
    echo "--- 内存 ---"
    ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no -o User=root $SSH_HOST 'free -h' 2>/dev/null | grep -v "^total\|^Mem\|^available" | awk '{print}' | grep -v "^[=]" || echo "内存正常"

    # SSD 挂载
    echo "--- SSD 挂载 ---"
    ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no -o User=root $SSH_HOST 'df -h /dev/sd* 2>/dev/null | grep -v "^Filesystem" || df -h | head -3' 2>/dev/null | head -5 || echo "SSD 检查异常"

    # AGH 状态
    echo "--- AGH 状态 ---"
    ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no -o User=root $SSH_HOST 'ls -lh /lib/agh 2>/dev/null || echo "AGH 正常"' 2>/dev/null | head -2 || echo "AGH 检查异常"

    # Swap
    echo "--- Swap ---"
    ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no -o User=root $SSH_HOST 'free -h | grep -v "^Mem" | awk "{print \$3, \$2}"' 2>/dev/null || echo "Swap 检查异常"

    # 日志异常
    echo "--- 日志异常 ---"
    ssh -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no -o User=root $SSH_HOST 'logread | grep -E "^ERROR|critical|panic" | tail -5 2>/dev/null || echo "无严重错误"' 2>/dev/null | grep -v "^login\|^$" || echo "日志检查异常"
fi

echo "=== 巡检完成 ==="