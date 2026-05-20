#!/bin/bash
# PC 巡检脚本
# 功能：检查磁盘、内存、ollama、显卡、临时文件，只输出异常项

echo "=== PC 巡检开始 ==="

# 检查磁盘空间（只列出使用率>80%的分区）
echo "--- 磁盘空间检查 ---"
df -h | awk 'NR==1 || $5 > 80 {print $0}'

# 检查内存（只列出使用率>80%）
echo "--- 内存检查 ---"
free -h | awk 'NR==1 || $2 > 0 && ($3/$2)*100 > 80 {print $0}'

# 检查 ollama 模型列表（显示所有正在运行的模型）
echo "--- Ollama 模型 ---"
ollama list 2>/dev/null || echo "Ollama 未运行或命令不可用"

# 检查 NVIDIA 显卡状态
echo "--- GPU 状态 ---"
nvidia-smi 2>/dev/null | tail -n 5 || echo "未检测到 NVIDIA 显卡或命令不可用"

# 检查/tmp目录下最大的5个文件
echo "--- /tmp 大文件 ---"
ls -lhS /tmp 2>/dev/null | head -5 | tail -5 || echo "无法访问 /tmp 目录"

echo "=== PC 巡检完成 ==="
