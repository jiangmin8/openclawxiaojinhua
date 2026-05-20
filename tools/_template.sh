#!/bin/bash
# ==========================================
# [工具名替换这里] — [一句话描述]
# 用途: [详细描述这个工具做什么]
# 用法: bash tools/xxx.sh <必需参数> [可选参数]
# 参数:
#   <参数1>  必需 — 说明
#   [参数2]  可选 — 说明（默认值: xxx）
# 输出: [JSON / 纯文本 / Markdown表格]
# 示例:
#   bash tools/xxx.sh value1          # 基本用法
#   bash tools/xxx.sh value1 --debug  # 调试模式
# 雅典娜注册: TOOLKIT.md
# ==========================================
set -euo pipefail

# ── 帮助 ──
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo "工具名: xxx"
    echo "用途: [一句话描述]"
    echo "用法: bash tools/xxx.sh <参数1> [参数2]"
    echo ""
    echo "参数:"
    echo "  <参数1>  必需 — 说明"
    echo "  [参数2]  可选 — 说明"
    echo ""
    echo "示例:"
    echo "  bash tools/xxx.sh value1"
    exit 0
fi

# ── 参数解析 ──
PARAM1="${1:-}"
FLAG_DEBUG=false

if [[ -z "$PARAM1" ]]; then
    echo "[ERROR] 缺少必需参数。运行 --help 查看用法。"
    exit 1
fi

if [[ "${2:-}" == "--debug" ]]; then
    FLAG_DEBUG=true
fi

# ── 你的工具逻辑 ──
# TODO: 在这里写你的工具代码

main() {
    echo "[INFO] 工具执行完成"
}

main "$@"
