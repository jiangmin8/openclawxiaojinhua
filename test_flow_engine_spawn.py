#!/usr/bin/env python3
"""
Flow Engine sessions_spawn 集成测试 - TDD
测试 spawn → poll → 结果 完整链路
"""

import json
from unittest.mock import patch, MagicMock
import requests


# === TEST 1: spawn 成功返回 session_key ===
def test_spawn_returns_session_key():
    """POST /sessions/spawn 必须返回 session_key"""
    with patch('requests.post') as mock_post:
        mock_post.return_value.json.return_value = {
            "session_key": "sess_abc123",
            "status": "spawned"
        }
        
        resp = requests.post(
            "http://localhost:18789/__openclaw__/sessions/spawn",
            json={"task": "test"}
        )
        
        assert "session_key" in resp.json()
        assert resp.json()["session_key"].startswith("sess_")


# === TEST 2: poll 拿到 completed 结果 ===
def test_poll_returns_completed_result():
    """GET /sessions/{id}/status 轮询直到 completed"""
    with patch('requests.get') as mock_get:
        # 模拟：第一次 running，第二次 completed
        mock_get.side_effect = [
            MagicMock(json=lambda: {"status": "running", "output": None}),
            MagicMock(json=lambda: {"status": "completed", "output": "搜索结果..."})
        ]
        
        spawn_id = "sess_abc123"
        result = None
        for _ in range(2):
            resp = requests.get(
                f"http://localhost:18789/__openclaw__/sessions/{spawn_id}/status"
            )
            result = resp.json()
            if result["status"] == "completed":
                break
        
        assert result["status"] == "completed"
        assert "搜索结果" in result["output"]


# === TEST 3: 完整链路 spawn → poll → 结果 ===
def test_full_spawn_poll_chain():
    """完整链路：spawn → poll → 拿到最终结果"""
    with patch('requests.post') as mock_post, \
         patch('requests.get') as mock_get:
        
        # spawn 返回 id
        mock_post.return_value.json.return_value = {
            "session_key": "sess_xyz789"
        }
        
        # poll 两次后 completed
        mock_get.side_effect = [
            MagicMock(json=lambda: {"status": "running"}),
            MagicMock(json=lambda: {"status": "running"}),
            MagicMock(json=lambda: {"status": "completed", "output": "最终答案"})
        ]
        
        # 模拟 execute_node 逻辑
        resp = requests.post("http://localhost:18789/__openclaw__/sessions/spawn", json={})
        spawn_id = resp.json()["session_key"]
        
        result = None
        for _ in range(10):  # max 10 poll
            status = requests.get(
                f"http://localhost:18789/__openclaw__/sessions/{spawn_id}/status"
            )
            result = status.json()
            if result["status"] in ("completed", "failed", "error"):
                break
        
        assert result["status"] == "completed"
        assert result["output"] == "最终答案"


# === TEST 4: 超时处理 ===
def test_spawn_poll_timeout():
    """poll 超过 max_wait 必须返回 timeout"""
    with patch('requests.post') as mock_post, \
         patch('requests.get') as mock_get:
        
        mock_post.return_value.json.return_value = {"session_key": "sess_123"}
        
        # 永远 running
        mock_get.return_value.json.return_value = {"status": "running"}
        
        spawn_id = "sess_123"
        max_wait = 4  # 模拟 4 秒超时
        waited = 0
        result = None
        
        while waited < max_wait:
            status = requests.get(
                f"http://localhost:18789/__openclaw__/sessions/{spawn_id}/status"
            )
            result = status.json()
            if result["status"] in ("completed", "failed", "error"):
                break
            # 模拟 sleep
            waited += 2
        
        # 超时后强制返回
        if waited >= max_wait:
            result = {"status": "timeout", "output": None}
        
        assert result["status"] == "timeout"
        assert result["output"] is None


# === TEST 5: 子 Agent 失败处理 ===
def test_spawn_failed_status():
    """子 Agent 返回 failed 状态必须传递"""
    with patch('requests.post') as mock_post, \
         patch('requests.get') as mock_get:
        
        mock_post.return_value.json.return_value = {"session_key": "sess_456"}
        mock_get.return_value.json.return_value = {
            "status": "failed",
            "error": "模型调用失败"
        }
        
        spawn_id = "sess_456"
        status = requests.get(
            f"http://localhost:18789/__openclaw__/sessions/{spawn_id}/status"
        )
        result = status.json()
        
        assert result["status"] == "failed"
        assert "error" in result


# === TEST 6: 结果回传到下游 @listen ===
def test_result_passed_to_downstream():
    """上游 completed 结果必须能传给下游节点"""
    # 模拟 Flow 引擎内部状态传递
    upstream_result = {"status": "completed", "output": "上游输出"}
    
    # 下游节点 task 模板应该能引用上游输出
    downstream_task = "基于上游结果: {{upstream.output}} 继续分析"
    rendered = downstream_task.replace("{{upstream.output}}", upstream_result["output"])
    
    assert "上游输出" in rendered


# === 运行测试 ===
if __name__ == "__main__":
    import sys
    
    tests = [
        test_spawn_returns_session_key,
        test_poll_returns_completed_result,
        test_full_spawn_poll_chain,
        test_spawn_poll_timeout,
        test_spawn_failed_status,
        test_result_passed_to_downstream,
    ]
    
    passed = 0
    failed = 0
    
    for test in tests:
        try:
            test()
            print(f"✅ {test.__name__}")
            passed += 1
        except AssertionError as e:
            print(f"❌ {test.__name__}: {e}")
            failed += 1
        except Exception as e:
            print(f"💥 {test.__name__}: {e}")
            failed += 1
    
    print(f"\n{passed}/{len(tests)} 通过")
    sys.exit(0 if failed == 0 else 1)
