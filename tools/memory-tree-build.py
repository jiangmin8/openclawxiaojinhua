#!/usr/bin/env python3
"""Memory Tree 摘要树构建器

三层结构：
  L1: source — 每个来源文件的摘要
  L2: topic  — 按概念聚类的主题摘要
  L3: global — 全局知识图谱摘要

输出：
  memory/tree/L1_sources.md   — 来源摘要
  memory/tree/L2_topics.md    — 主题摘要
  memory/tree/L3_global.md    — 全局摘要
  memory/tree/tree_state.json — 构建状态
"""

import os, re, json, hashlib
from pathlib import Path
from datetime import datetime, timezone, timedelta
from collections import defaultdict
from typing import List, Dict, Tuple

WORKSPACE = Path.home() / ".openclaw" / "workspace-athena"
MEMORY_DIR = WORKSPACE / "memory"
TREE_DIR = MEMORY_DIR / "tree"
STATE_FILE = TREE_DIR / "tree_state.json"

CHUNK_MAX_CHARS = 2500  # ~3k tokens approximated as chars

# 概念 → 关键词映射
TOPIC_PATTERNS = {
    "系统运维": [r"ollama", r"gateway", r"openclaw", r"systemctl", r"systemd", r"service", r"守护", r"巡检", r"cron", r"healthcheck", r"备份", r"backup"],
    "网络与设备": [r"路由器", r"router", r"192\.168", r"AP", r"wifi", r"WiFi", r"openwrt", r"SSH", r"内网", r"公网", r"RA\d", r"端口", r"防火墙"],
    "开发环境": [r"python", r"pip", r"venv", r"conda", r"npm", r"pnpm", r"node", r"cargo", r"rust", r"编译", r"WSL", r"ubuntu", r"docker"],
    "AI与模型": [r"ollama", r"model", r"模型", r"deepseek", r"qwen", r"llama", r"embedding", r"inference", r"推理", r"token", r"GPU", r"nvidia", r"cuda"],
    "项目与代码": [r"github", r"repo", r"项目", r"代码", r"脚本", r"script", r"部署", r"发布", r"PR", r"commit"],
    "知识管理": [r"memory", r"记忆", r"知识库", r"索引", r"归档", r"笔记", r"agentmemory"],
    "用户偏好": [r"大哥", r"偏好", r"习惯", r"user", r"交互", r"沟通"],
    "安全": [r"安全", r"security", r"漏洞", r"权限", r"认证", r"密钥", r"token", r"OAuth"],
}

# 文件重要性权重
FILE_WEIGHTS = {
    "context.base.md": 10,
    "context.user.pref.md": 8,
    "context.project.md": 7,
    "context.kb.md": 6,
    "subconscious": 5,
}

TZ = timezone(timedelta(hours=8))


def load_state() -> Dict:
    if STATE_FILE.exists():
        with open(STATE_FILE) as f:
            return json.load(f)
    return {"last_build": None, "file_hashes": {}, "topic_map": {}}


def save_state(state: Dict):
    TREE_DIR.mkdir(parents=True, exist_ok=True)
    with open(STATE_FILE, "w") as f:
        json.dump(state, f, indent=2, default=str)


def hash_file(path: Path) -> str:
    with open(path, "r") as f:
        return hashlib.sha256(f.read().encode()).hexdigest()[:16]


def scan_memory_files() -> List[Path]:
    """扫描所有需要索引的记忆文件"""
    files = []
    exclude = {"tree", "logs", "subconscious"}
    for p in MEMORY_DIR.rglob("*.md"):
        parts = p.relative_to(MEMORY_DIR).parts
        if parts[0] in exclude:
            continue
        files.append(p)
    # also scan 工作区核心文件
    for name in ["HEARTBEAT.md", "AGENTS.md", "TOOLS.md", "MEMORY.md", "SOUL.md", "USER.md", "IDENTITY.md"]:
        f = WORKSPACE / name
        if f.exists():
            files.append(f)
    return sorted(files)


def extract_sections(text: str, max_chars: int = CHUNK_MAX_CHARS) -> List[str]:
    """将文本拆分为 ≤max_chars 的语义块"""
    sections = []
    current = []
    current_len = 0

    for line in text.split("\n"):
        if current_len + len(line) > max_chars and current:
            sections.append("\n".join(current))
            current = []
            current_len = 0
        current.append(line)
        current_len += len(line) + 1

    if current:
        sections.append("\n".join(current))
    return sections


def classify_topics(text: str) -> List[Tuple[str, float]]:
    """按概念分类文本"""
    scores = []
    text_lower = text.lower()
    for topic, patterns in TOPIC_PATTERNS.items():
        score = 0
        for p in patterns:
            matches = len(re.findall(p, text_lower))
            score += matches
        if score > 0:
            scores.append((topic, score / len(patterns)))
    scores.sort(key=lambda x: x[1], reverse=True)
    return scores[:3]  # top 3 topics


def build_L1_sources(files: List[Path], state: Dict) -> str:
    """L1: 来源级摘要"""
    now = datetime.now(TZ)
    changed = []
    unchanged = []

    for f in files:
        h = hash_file(f)
        old_h = state["file_hashes"].get(str(f), "")
        state["file_hashes"][str(f)] = h
        rel = f.relative_to(WORKSPACE) if WORKSPACE in f.parents else f.name

        with open(f, "r") as fh:
            content = fh.read()

        size = len(content)
        topics = classify_topics(content)
        topic_str = ", ".join([t for t, s in topics]) if topics else "未分类"
        weight = FILE_WEIGHTS.get(f.name, FILE_WEIGHTS.get(rel.parts[0] if rel.parts else "", 3))

        entry = f"| `{rel}` | {size}B | {topic_str} | {'🆕 changed' if h != old_h else '✓'} | ⭐{weight} |"
        if h != old_h:
            changed.append(entry)
        else:
            unchanged.append(entry)

    lines = [
        f"# L1 来源摘要树",
        f"> 构建时间: {now.strftime('%Y-%m-%d %H:%M')} CST",
        f"> 文件数: {len(files)}, 变更: {len(changed)}, 未变: {len(unchanged)}",
        "",
        "| 文件 | 大小 | 主题 | 状态 | 权重 |",
        "|:---|:---|:---|:---|:---|",
    ]
    lines.extend(changed)
    if unchanged:
        lines.append(f"| ... | | | {len(unchanged)} 文件未变 | |")
    return "\n".join(lines)


def build_L2_topics(files: List[Path]) -> str:
    """L2: 主题级摘要"""
    now = datetime.now(TZ)
    topic_chunks = defaultdict(list)

    for f in files:
        with open(f, "r") as fh:
            content = fh.read()
        rel = f.relative_to(WORKSPACE) if WORKSPACE in f.parents else f.name
        topics = classify_topics(content)
        for topic, score in topics:
            if score > 0.05:
                # take first section as representative
                sections = extract_sections(content, 800)
                snippet = sections[0][:500] + ("..." if len(sections[0]) > 500 else "")
                topic_chunks[topic].append((rel, score, snippet))

    lines = [
        f"# L2 主题摘要树",
        f"> 构建时间: {now.strftime('%Y-%m-%d %H:%M')} CST",
        f"> 主题数: {len(topic_chunks)}",
        "",
    ]

    for topic in sorted(topic_chunks.keys(), key=lambda t: sum(s for _, s, _ in topic_chunks[t]), reverse=True):
        chunks = topic_chunks[topic]
        lines.append(f"## {topic} (强度: {len(chunks)} 个来源)")
        for rel, score, snippet in chunks[:5]:  # top 5 per topic
            lines.append(f"- **`{rel}`** (score: {score:.2f}): {snippet[:200]}")
        lines.append("")

    return "\n".join(lines)


def build_L3_global(files: List[Path]) -> str:
    """L3: 全局知识图谱摘要"""
    now = datetime.now(TZ)
    all_topics = defaultdict(float)
    total_size = 0

    for f in files:
        with open(f, "r") as fh:
            content = fh.read()
        total_size += len(content)
        for topic, score in classify_topics(content):
            all_topics[topic] += score

    ranked = sorted(all_topics.items(), key=lambda x: x[1], reverse=True)
    top_half = [t for t, s in ranked if s >= ranked[len(ranked)//2][1]] if ranked else []

    lines = [
        f"# L3 全局知识图谱",
        f"> 构建时间: {now.strftime('%Y-%m-%d %H:%M')} CST",
        f"> 索引文件: {len(files)}, 总大小: {total_size:,}B",
        "",
        "## 知识域分布",
        "",
        "| 域 | 强度 |",
        "|:---|:---|",
    ]
    for topic, strength in ranked:
        bar = "█" * min(int(strength * 2), 40)
        lines.append(f"| {topic} | {bar} {strength:.1f} |")

    lines.extend([
        "",
        "## 活跃域",
        ", ".join(top_half) if top_half else "无显著活跃域",
        "",
        f"## 统计",
        f"- 文件总数: {len(files)}",
        f"- 主题覆盖: {len(ranked)}/{len(TOPIC_PATTERNS)}",
        f"- 索引规模: {total_size:,} 字符",
    ])
    return "\n".join(lines)


def main():
    state = load_state()
    files = scan_memory_files()

    if not files:
        print("无记忆文件")
        return

    # L1
    l1 = build_L1_sources(files, state)
    (TREE_DIR / "L1_sources.md").write_text(l1)

    # L2
    l2 = build_L2_topics(files)
    (TREE_DIR / "L2_topics.md").write_text(l2)

    # L3
    l3 = build_L3_global(files)
    (TREE_DIR / "L3_global.md").write_text(l3)

    # state
    state["last_build"] = datetime.now(TZ).isoformat()
    save_state(state)

    print(f"Memory Tree 构建完成: {len(files)} 文件 → L1/L2/L3 已生成")


if __name__ == "__main__":
    main()
