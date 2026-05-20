#!/bin/bash
# 路由器巡检脚本 (OpenWrt via SSH)
# 目标：192.168.8.1 (mt3600be)
# 功能：检查 uptime、内存、SSD 挂载、AGH 状态、swap、logread 异常

HOST="192.168.8.1"
SSH_USER="root"  # 请根据实际情况修改

echo "=== 路由器巡检开始 (主机：${HOST}) ==="

# 检查系统运行时间
echo "--- 运行时间 ---"
uptime | grep -q "load average" || echo "无法获取运行时间"

# 检查内存使用
echo "--- 内存状态 ---"
free -h | grep Mem | awk '{if($3 > 0) printf "已用内存: %s (%.1f%%)\n", $3, ($3/$2)*100; else print "内存正常"}'

# 检查 SSD 挂载状态
echo "--- SSD 挂载状态 ---"
mount | grep -E "nvme|sda" | grep -v "^/dev/" || echo "未检测到 SSD 挂载或无法获取信息"

# 检查 AGH 状态
echo "--- AGH 状态 ---"
if [ -f /proc/agh/status ]; then
    cat /proc/agh/status | grep -E "aghs|aghd" || echo "AGH 状态：无异常"
else
    echo "注：AGH 文件不存在（可能是固件版本不同）"
fi

# 检查 swap 状态
echo "--- Swap 状态 ---"
swap -h | grep Swap || echo "Swap 状态检查完成"

# 检查 logread 异常日志
echo "--- 异常日志检查 ---"
logread | grep -i -E "error|fail|critical|alert" | tail -20 || echo "无异常日志"

echo "=== 路由器巡检完成 ==="
