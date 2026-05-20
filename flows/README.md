# Flow 引擎使用手册

> CrewAI 风格事件驱动编排。用 YAML 定义链路 → 引擎自动调度子 Agent。

## 核心概念

```
定义 YAML → FlowEngine 解析 → 按图调度 sessions_spawn → 自动传递输出
```

三个装饰器：
- `start: true` → 入口节点
- `listen: <上游节点>` → 监听上游，自动接收输出
- `router:` → 条件分支

## YAML 语法

```yaml
name: my-flow
nodes:
  - id: step1
    start: true              # 入口
    archetype: researcher    # 匹配 archetypes/ 目录
    model: ollama/qwen2.5:7b
    task: "搜索 {{input}}"   # {{input}} = 上游输出
    max_turns: 3
    timeout_seconds: 60

  - id: step2
    listen: step1            # 自动接收 step1 的输出
    archetype: code_executor
    task: "处理: {{input}}"

  - id: branch_a
    listen: step2
    router:
      - condition: success
        target: good_path
      - condition: failure
        target: fallback
```

## Token 节省原理

**之前（无 Flow）：**
```
每个复杂任务 → 雅典娜(ds-v4-pro) 规划+执行+验证
→ 每次 ~3000-8000 cloud tokens × N 轮
```

**现在（有 Flow）：**
```
第1轮：雅典娜用 ~500 tokens 读 YAML 定义
第2-N轮：子 Agent 用本地 Ollama（0 cloud tokens）
最后1轮：雅典娜验证结果 ~500 tokens
总计：~1000 cloud tokens vs 原来 3000-8000
```

节省 70-85% 云端 Token。

## 子 Agent 模型分配策略

| 任务类型 | archetype | 推荐模型 | Token 成本 |
|:---|:---|:---|:---|
| Web 搜索/抓取 | researcher | qwen2.5:7b | 0 (本地) |
| 代码执行 | code_executor | qwen2.5-coder:7b | 0 (本地) |
| 内容分析 | researcher | deepseek-r1:8b | 0 (本地) |
| 重推理/评估 | planner | deepseek-v4-pro | 云端 |
| 审查/审计 | reviewer | qwen2.5:7b | 0 (本地) |
