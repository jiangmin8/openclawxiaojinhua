#!/usr/bin/env python3
"""
tools/activity_log.py — Memori 执行轨迹记录器

用法:
    from tools.activity_log import ActivityLog
    
    log = ActivityLog("memory/subconscious/activity.log.md")
    log.start_tick("会话结束", "sess_abc")
    log.record_tool_call("memory_get", "PERSONAL_MODEL.md", "现有模型", "继续")
    log.record_output(open_question="大哥?", belief_updates=["信念1"], mode="轻量")
    log.finalize("成功", 0)
    log.save()
"""

import os
from datetime import datetime
from typing import List, Dict, Optional


class ActivityLog:
    def __init__(self, file_path: str):
        self.file_path = file_path
        self.current_tick: Optional[Dict] = None

    def start_tick(self, trigger_type: str, session_id: str) -> str:
        tick_id = f"tick_{datetime.now().strftime('%Y%m%d_%H%M%S')}_{session_id[-6:]}"
        self.current_tick = {
            "id": tick_id,
            "trigger": {"type": trigger_type, "session_id": session_id, "started_at": datetime.now()},
            "trajectory": [],
            "output": {},
            "status": {},
        }
        return tick_id

    def record_tool_call(self, tool_name: str, tool_input: str, tool_output: str, decision: str):
        if self.current_tick is None:
            raise RuntimeError("必须先调用 start_tick")
        self.current_tick["trajectory"].append({
            "timestamp": datetime.now(),
            "tool": tool_name,
            "input": tool_input,
            "output": tool_output,
            "decision": decision,
        })

    def record_output(self, open_question: Optional[str] = None,
                      belief_updates: Optional[List[str]] = None, mode: str = "轻量"):
        if self.current_tick is None:
            raise RuntimeError("必须先调用 start_tick")
        self.current_tick["output"] = {
            "open_question": open_question,
            "belief_updates": belief_updates or [],
            "mode": mode,
        }

    def finalize(self, status: str, retry_count: int = 0):
        if self.current_tick is None:
            raise RuntimeError("必须先调用 start_tick")
        self.current_tick["status"] = {
            "result": status,
            "retry_count": retry_count,
            "completed_at": datetime.now(),
        }

    def to_markdown(self) -> str:
        if self.current_tick is None:
            return ""
        t = self.current_tick
        lines = [
            f"## Tick {t['trigger']['started_at'].strftime('%Y-%m-%d %H:%M:%S')}",
            "",
            "### 触发",
            f"- 类型：{t['trigger']['type']}",
            f"- 会话ID：{t['trigger']['session_id']}",
            "",
            "### 执行轨迹",
            "| 时间 | 工具 | 输入 | 输出 | 决策 |",
            "|:---|:---|:---|:---|:---|",
        ]
        for call in t["trajectory"]:
            ts = call["timestamp"].strftime("%H:%M:%S")
            lines.append(f"| {ts} | {call['tool']} | {call['input']} | {call['output']} | {call['decision']} |")
        if not t["trajectory"]:
            lines.append("| - | - | - | - | ⚠️ 无工具调用 |")
        lines.append("")
        out = t["output"]
        lines.extend([
            "### 产出",
            f"- OpenQuestion：\"{out.get('open_question', '无')}\"" if out.get("open_question") else "- OpenQuestion：无",
            f"- 更新信念：{out.get('belief_updates', [])}",
            f"- 模式：{out.get('mode', '轻量')}",
            "",
            "### 状态",
            f"- 结果：{t['status'].get('result', '未知')}",
            f"- 重试次数：{t['status'].get('retry_count', 0)}",
        ])
        return "\n".join(lines)

    def save(self):
        markdown = self.to_markdown()
        existing = ""
        if os.path.exists(self.file_path):
            with open(self.file_path, "r", encoding="utf-8") as f:
                existing = f.read()
        with open(self.file_path, "w", encoding="utf-8") as f:
            if existing:
                f.write(existing)
                if not existing.endswith("\n"):
                    f.write("\n")
                f.write("\n")
            f.write(markdown)
            f.write("\n")
