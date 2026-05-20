#!/usr/bin/env python3
"""
Flow 引擎 — CrewAI 风格事件驱动编排器

将 @start / @listen / @router 模式映射到 sessions_spawn。
读取 YAML 定义 → 自动调度子 Agent → 传递输出 → 验收结果。

用法:
  python3 tools/flow-engine.py flows/research-flow.yaml
"""

import yaml
import json
import subprocess
import sys
import os
import time
from pathlib import Path
from typing import Any, Dict, List, Optional
from datetime import datetime

try:
    import requests
    HAS_REQUESTS = True
except ImportError:
    HAS_REQUESTS = False

WORKSPACE = Path.home() / ".openclaw" / "workspace-athena"
FLOW_DIR = WORKSPACE / "flows"
ARCHETYPE_DIR = WORKSPACE / "archetypes"

class FlowEngine:
    """读取 Flow YAML，按图执行节点，自动传递数据。"""

    def __init__(self, flow_file: Path):
        with open(flow_file) as f:
            self.definition = yaml.safe_load(f)
        self.name = self.definition["name"]
        self.nodes: Dict[str, Dict] = {}
        self.results: Dict[str, Any] = {}
        self._build_graph()

    def _build_graph(self):
        """解析节点和边，构建执行图。"""
        for node in self.definition.get("nodes", []):
            self.nodes[node["id"]] = node

    def get_node(self, node_id: str) -> Dict:
        return self.nodes.get(node_id, {})

    def get_listeners(self, node_id: str) -> List[str]:
        """找到所有监听指定节点的下游节点。"""
        listeners = []
        for nid, node in self.nodes.items():
            listens = node.get("listen", [])
            if isinstance(listens, str):
                listens = [listens]
            if node_id in listens:
                listeners.append(nid)
        return listeners

    def get_router_target(self, node_id: str, result: Any) -> Optional[str]:
        """评估路由条件，返回目标节点 ID。"""
        node = self.get_node(node_id)
        router = node.get("router")
        if not router:
            return None
        for rule in router:
            if rule.get("condition") == "always":
                return rule["target"]
            if rule.get("condition") == "success" and result:
                return rule["target"]
            if rule.get("condition") == "failure" and not result:
                return rule["target"]
        return None

    def resolve_prompt(self, node: Dict, input_data: Any) -> str:
        """拼装子 Agent 的 system prompt + 当前输入。"""
        archetype = node.get("archetype", "code_executor")
        # 加载 archetype prompt
        prompt_file = ARCHETYPE_DIR / archetype / "prompt.md"
        if prompt_file.exists():
            with open(prompt_file) as f:
                system_prompt = f.read()
        else:
            system_prompt = f"You are the {archetype} agent."

        # 拼装任务
        task = node.get("task", "")
        task = task.replace("{{input}}", str(input_data))
        
        full_prompt = f"{system_prompt}\n\n## 当前任务\n{task}\n\n## 输入数据\n{input_data}"
        return full_prompt

    def execute_node(self, node_id: str, input_data: Any = None) -> Any:
        """执行单个节点，通过 OpenClaw sessions_spawn API 调子 Agent。
        
        流程：spawn → poll → 拿结果。超时/失败自动处理。
        """
        node = self.get_node(node_id)
        if not node:
            print(f"[ERROR] 节点 {node_id} 不存在")
            return None

        model = node.get("model", "ollama/qwen2.5:7b")
        max_turns = node.get("max_turns", 3)
        timeout = node.get("timeout_seconds", 120)
        task_prompt = node.get("task", "").replace("{{input}}", str(input_data)) if input_data else node.get("task", "")
        archetype = node.get("archetype", "code_executor")

        # 加载 archetype prompt
        system_prompt = ""
        prompt_file = ARCHETYPE_DIR / archetype / "prompt.md"
        if prompt_file.exists():
            with open(prompt_file) as f:
                system_prompt = f.read()

        spawn_payload = {
            "task": task_prompt,
            "taskName": f"{self.name}_{node_id}",
            "model": model,
            "timeoutSeconds": timeout,
        }
        if system_prompt:
            spawn_payload["attachments"] = [{
                "name": "archetype_prompt.md",
                "content": system_prompt,
                "encoding": "utf8",
                "mimeType": "text/markdown"
            }]

        print(f"\n{'='*60}")
        print(f"[{self.name}] ▶ {node_id} ({archetype})")
        print(f"  模型: {model} | 超时: {timeout}s")
        print(f"  任务: {task_prompt[:100]}...")
        print(f"{'='*60}")

        if not HAS_REQUESTS:
            print(f"⚠️  requests 未安装，输出 JSON 指令")
            print(f"⚡ SPAWN_CMD: {json.dumps(spawn_payload, ensure_ascii=False)}")
            return {"status": "spawn_manual", "node": node_id, "cmd": spawn_payload}

        try:
            # 1. spawn
            resp = requests.post(
                "http://localhost:18789/__openclaw__/sessions/spawn",
                json=spawn_payload,
                timeout=10
            )
            if resp.status_code != 200:
                print(f"  ❌ spawn 失败: HTTP {resp.status_code}")
                return {"status": "error", "node": node_id, "error": f"HTTP {resp.status_code}"}

            spawn_data = resp.json()
            spawn_id = spawn_data.get("sessionKey") or spawn_data.get("session_key")
            if not spawn_id:
                print(f"  ❌ 无 session_key: {spawn_data}")
                return {"status": "error", "node": node_id, "error": "no session_key"}

            print(f"  ✓ spawned: {spawn_id}")

            # 2. poll
            max_wait = timeout
            waited = 0
            while waited < max_wait:
                time.sleep(2)
                waited += 2
                try:
                    status_resp = requests.get(
                        f"http://localhost:18789/__openclaw__/sessions/{spawn_id}",
                        timeout=5
                    )
                    if status_resp.status_code != 200:
                        continue
                    result = status_resp.json()
                    status = result.get("status", result.get("state", "unknown"))
                    if status in ("completed", "failed", "error"):
                        print(f"  ✓ {status} ({waited}s)")
                        return {
                            "status": status,
                            "node": node_id,
                            "session_key": spawn_id,
                            "output": result.get("output", result.get("reply", "")),
                        }
                except requests.RequestException:
                    pass

            # timeout
            print(f"  ⏰ timeout ({waited}s)")
            return {"status": "timeout", "node": node_id, "session_key": spawn_id, "output": None}

        except requests.RequestException as e:
            print(f"  ❌ 网络错误: {e}")
            return {"status": "error", "node": node_id, "error": str(e)}

    def run(self):
        """执行完整 Flow。"""
        start_node = None
        for nid, node in self.nodes.items():
            if node.get("start"):
                start_node = nid
                break

        if not start_node:
            print("[ERROR] Flow 缺少 @start 节点")
            return

        # 简单的 BFS 执行
        queue = [(start_node, None)]
        while queue:
            node_id, input_data = queue.pop(0)
            result = self.execute_node(node_id, input_data)
            self.results[node_id] = result

            # 找下游
            listeners = self.get_listeners(node_id)
            route_target = self.get_router_target(node_id, result)

            for listener in listeners:
                if route_target and listener != route_target:
                    continue
                # 将上游结果作为下游输入
                queue.append((listener, result))

        print(f"\n[Flow: {self.name}] 执行完成，{len(self.results)} 个节点已调度")


def main():
    if len(sys.argv) < 2:
        # 列出所有可用 Flow
        flows = sorted(FLOW_DIR.glob("*.yaml")) if FLOW_DIR.exists() else []
        if flows:
            print("可用 Flow:")
            for f in flows:
                print(f"  {f.stem}")
        else:
            print("无 Flow 定义。在 flows/ 目录创建 .yaml 文件。")
        return

    flow_file = Path(sys.argv[1])
    if not flow_file.exists():
        flow_file = FLOW_DIR / f"{sys.argv[1]}.yaml"

    if not flow_file.exists():
        print(f"[ERROR] Flow 文件不存在: {flow_file}")
        sys.exit(1)

    engine = FlowEngine(flow_file)
    engine.run()


if __name__ == "__main__":
    main()
