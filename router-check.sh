#!/bin/bash
# 路由器巡检脚本 — 每60分钟执行
# 只输出异常项

echo "=== 路由器巡检 === $(date '+%Y-%m-%d %H:%M')"

# 通过 SSH 连接 192.168.8.1 执行检查
ssh -o StrictHostKeyChecking=no mt3600be@192.168.8.1 '
# Uptime 超过 1 天
if [[ $(uptime | grep -o "up [0-9]* day" | awk "{print $2}") -gt 1 ]]; then
  echo "--- 运行时间异常 ---"
  uptime
fi

# 内存使用异常（可用<1G）
if [[ $(free -h | grep -o "Mem: [^G]* [^G]* [^G]*" | awk "{print $3}") < "1G" ]]; then
  echo "--- 内存不足 ---"
  free -h
fi

# 根分区空间异常（>85%）
if df / | awk "{print \047$$5" > 85}" ; then
  echo "--- 根分区空间紧张 ---"
  df -h
fi

# AGH 状态检查（如果存在）
if [ -f /proc/mtd | grep -q "agh" ]; then
  echo "--- AGH 状态 ---"
  cat /proc/mtd | grep -i agh || echo "未检测到 AGH"
fi

# Swap 使用异常（已使用>80%）
if [[ $(free -h | grep -o "Swap: [^G]*" | awk "{print $2}") > "0.2G" ]]; then
  echo "--- Swap 使用异常 ---"
  free -h
fi

# Logread 异常条目（ERROR/CRITICAL）
echo "--- Logread 异常 ---"
logread | grep -E "ERROR|CRITICAL|FATAL" || echo "无异常日志"
'
