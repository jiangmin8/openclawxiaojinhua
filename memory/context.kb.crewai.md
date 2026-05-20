# CrewAI 编排模式研究

> 源：`/mnt/e/知识库种子/crewAI/` (github.com/crewAIInc/crewAI)
> 日期：2026-05-20

## 架构核心

```
lib/crewai/src/crewai/
├── flow/          # 🔥 事件驱动工作流（核心编排）
├── crew.py        # Crew 编排器
├── agent/         # Agent 核心
├── agents/        # Agent 适配器（LangGraph 等）
├── task.py        # 任务定义
├── memory/        # 统一记忆系统
├── mcp/           # MCP 协议支持
├── a2a/           # Agent-to-Agent 协议
├── knowledge/     # 知识管理 + RAG
├── skills/        # 技能系统
└── tools/         # 工具系统
```

## 关键模式

### 1. Flow 装饰器模式（最高价值）
```python
class MyFlow(Flow[State]):
    @start()           # 入口
    def begin(self): ...

    @listen(begin)     # 监听 begin 的输出 → 自动触发
    def step_two(self, result): ...

    @router(step_two)  # 条件路由
    def branch(self): ...
```

### 2. Crew 编排
- `Process.sequential` → 顺序执行
- `Process.hierarchical` → 层级委托
- 支持 Task 依赖、条件跳过、async

### 3. Agent 适配器
- LangGraph 集成
- Agent Card 签名（A2A）
- 可插拔 LLM

### 4. 记忆系统
- `MemoryScope` + `MemorySlice`
- 编码流 / 召回流
- 统一记忆接口

### 5. 人机反馈
- `HumanFeedbackResult`
- Flow 级暂停/恢复
- 异步反馈 provider

## 对照雅典娜可借鉴

| CrewAI | 雅典娜对标 | 差异 |
|:---|:---|:---|
| Flow/@listen | 尚无（线性 sessions_spawn） | **最大差距** |
| Crew 编排 | archetypes/ 目录 | 缺少事件驱动链接 |
| Agent 适配器 | 无 | 只支持单一 deepseek 模型 |
| 统一记忆 | agentmemory 后端 | 缺编码/召回流 |
| 人机反馈 | 大哥手动审批 | 缺 Flow 级暂停恢复 |
| MCP/A2A | OpenClaw 已支持 MCP | 可注册工具 |
