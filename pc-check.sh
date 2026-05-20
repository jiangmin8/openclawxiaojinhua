#!/bin/bash
# PC 巡检脚本 — 每30分钟执行
# 只输出异常项

echo "=== PC 巡检 === $(date '+%Y-%m-%d %H:%M')"

# 磁盘空间异常（>85%）
echo "--- 磁盘空间 ---"
df -h | awk 'NR==1 || $5 > 85'

# 内存使用异常（可用<2G）
echo "--- 内存 ---"
free -h | awk 'NR==2 && $4 < "2G"'

# Ollama 模型检查（列出模型）
echo "--- Ollama 模型 ---"
ollama list

# NVIDIA GPU 状态
echo "--- GPU 状态 ---"
nvidia-smi | awk 'NR==1 || $6 == "N/A" || $7 > 90 || $8 != "Default"'

# /tmp 大文件（>100M）
echo "--- /tmp 大文件 ---"
ls -lhS /tmp | awk 'NR==2 && $5 > 100M'
