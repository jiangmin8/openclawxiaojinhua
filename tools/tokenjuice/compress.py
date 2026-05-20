#!/usr/bin/env python3
"""TokenJuice 压缩器 — 对工具输出做规则过滤后再输出

用法:
  cat huge_output.txt | python3 tools/tokenjuice/compress.py --tool git --match "git diff"
  some_command 2>&1 | python3 tools/tokenjuice/compress.py --tool cargo

规则叠加: builtin.yaml < ~/.config/tokenjuice/rules/*.yaml < .tokenjuice/rules/*.yaml
"""

import sys, re, os, yaml, argparse
from pathlib import Path
from typing import List, Dict, Any

SCRIPT_DIR = Path(__file__).resolve().parent
BUILTIN_RULES = SCRIPT_DIR / "rules" / "builtin.yaml"
USER_RULES_DIR = Path.home() / ".config" / "tokenjuice" / "rules"
PROJECT_RULES_DIR = Path.cwd() / ".tokenjuice" / "rules"


def load_rules() -> List[Dict]:
    rules = []
    for path in [BUILTIN_RULES] + sorted(USER_RULES_DIR.glob("*.yaml")) + sorted(PROJECT_RULES_DIR.glob("*.yaml")):
        if path.exists():
            with open(path) as f:
                data = yaml.safe_load(f)
                if data and "rules" in data:
                    rules.extend(data["rules"])
    return rules


def match_rule(rule: Dict, tool: str, command: str) -> bool:
    rt = rule.get("tool", "*")
    rm = rule.get("match", ".*")
    tool_match = rt == "*" or re.search(rt, tool, re.IGNORECASE)
    cmd_match = re.search(rm, command, re.IGNORECASE) if command else True
    return tool_match and cmd_match


def apply_rules(lines: List[str], rules: List[Dict], tool: str, command: str) -> List[str]:
    matched = [r for r in rules if match_rule(r, tool, command)]
    if not matched:
        return lines

    result = lines[:]
    had_error = False

    for rule in matched:
        for strat in rule.get("strategies", []):
            if isinstance(strat, str):
                name, cfg = strat, {}
            else:
                name, cfg = list(strat.items())[0] if strat else ("", {})

            if name == "truncate":
                if "max_lines" in cfg and len(result) > cfg["max_lines"]:
                    result = result[:cfg["max_lines"]] + [f"[截断: {len(result) - cfg['max_lines']} 行省略]"]
                if "max_chars" in cfg:
                    total = sum(len(l) for l in result)
                    if total > cfg["max_chars"]:
                        while result and sum(len(l) for l in result) > cfg["max_chars"]:
                            result.pop()

            elif name == "dedup_lines":
                seen = set()
                deduped = []
                for line in result:
                    stripped = line.rstrip()
                    if stripped not in seen:
                        seen.add(stripped)
                        deduped.append(line)
                    elif len(deduped) < len(result) - 1:
                        pass  # skip duplicate
                    else:
                        deduped.append(line)
                if len(deduped) < len(result):
                    deduped.append(f"[去重: {len(result) - len(deduped)} 行重复省略]")
                result = deduped

            elif name == "drop_lines":
                regex = cfg.get("regex", "")
                before = len(result)
                result = [l for l in result if not re.search(regex, l, re.IGNORECASE)]
                if len(result) < before:
                    result.append(f"[过滤: {before - len(result)} 行已省略]")

            elif name == "keep_lines":
                regex = cfg.get("regex", "")
                kept = [l for l in result if re.search(regex, l, re.IGNORECASE)]
                if kept:
                    result = [f"[关键行 ({len(kept)}):]"] + kept
                else:
                    result = ["[无匹配关键行]"]

            elif name == "fold_whitespace":
                max_blank = cfg.get("max_blank_lines", 2)
                folded = []
                blank_count = 0
                for line in result:
                    if line.strip() == "":
                        blank_count += 1
                        if blank_count <= max_blank:
                            folded.append(line)
                    else:
                        blank_count = 0
                        folded.append(line)
                result = folded

            elif name == "summarize":
                style = cfg.get("style", "")
                if style == "head_tail":
                    head_n = cfg.get("head", 30)
                    tail_n = cfg.get("tail", 10)
                    if len(result) > head_n + tail_n:
                        result = result[:head_n] + [f"[... {len(result) - head_n - tail_n} 行省略 ...]"] + result[-tail_n:]

            elif name == "strip_context":
                pass  # complex, skip for now

            elif name == "strip_headers":
                pass

            elif name == "boost_errors":
                error_lines = [l for l in result if re.search(r'(error|fail|panic|FATAL)', l, re.IGNORECASE)]
                if error_lines:
                    prefix = [f"[⚠️ 检测到 {len(error_lines)} 处错误/异常]"]
                    result = prefix + result

    # check for error signals
    text = "\n".join(result)
    if re.search(r'(error|fail|panic|FATAL|Permission denied)', text, re.IGNORECASE):
        err_count = len(re.findall(r'(error|fail|panic|FATAL)', text, re.IGNORECASE))
        result = [f"[⚠️ 输出含 {err_count} 处错误信号]"] + result

    return result


def main():
    parser = argparse.ArgumentParser(description="TokenJuice 压缩器")
    parser.add_argument("--tool", default="", help="工具名 (git, cargo, npm, etc.)")
    parser.add_argument("--match", default="", help="命令匹配模式")
    parser.add_argument("--dry", action="store_true", help="显示匹配的规则")
    parser.add_argument("--max-lines", type=int, default=200, help="最大输出行数")
    args = parser.parse_args()

    rules = load_rules()
    matched = [r for r in rules if match_rule(r, args.tool, args.match)]

    if args.dry:
        print(f"# 加载 {len(rules)} 条规则，匹配 {len(matched)} 条:")
        for r in matched:
            print(f"  - {r['name']}: {r.get('note', '')}")
        return

    lines = sys.stdin.read().splitlines()
    original_lines = len(lines)
    original_chars = sum(len(l) for l in lines)

    compressed = apply_rules(lines, rules, args.tool, args.match)

    if len(compressed) > args.max_lines:
        compressed = compressed[:args.max_lines] + [f"[全局截断: 超 {args.max_lines} 行]"]

    output = "\n".join(compressed)
    new_chars = len(output)

    # stats to stderr
    reduction = (1 - new_chars / original_chars) * 100 if original_chars > 0 else 0
    print(f"[TokenJuice: {original_lines}行/{original_chars}字 → {len(compressed)}行/{new_chars}字 ({reduction:.0f}% 压缩)]", file=sys.stderr)

    print(output)


if __name__ == "__main__":
    main()
