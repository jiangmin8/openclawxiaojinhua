#!/bin/bash
# PC 巡检脚本
# 只输出异常项

echo "=== PC 巡检报告 $(date '+%Y-%m-%d %H:%M') ==="

# 磁盘空间检查
echo "--- 磁盘空间 ---"
df -h | awk 'NR==2 || $5 > 70 {print}' | grep -v "^Filesystem"

# 内存检查
echo "--- 内存 ---"
free -h | awk 'NR==2 || $2 < 2G {print}' | grep -v "^Mem"

# Ollama 模型检查
echo "--- Ollama 模型 ---"
ollama list 2>/dev/null | grep -v "^OLLAMA" || echo "Ollama 未运行"

# NVIDIA GPU 状态
echo "--- GPU 状态 ---"
nvidia-smi 2>/dev/null | grep -E "GPU|Memory|Utilization" | head -6 || echo "无 GPU 或驱动异常"

# /tmp 临时文件
echo "--- /tmp 大文件 ---"
ls -lhS /tmp 2>/dev/null | head -5 | awk '{print}' | grep -v "^total" || echo "/tmp 无大文件"

echo "=== 巡检完成 ==="