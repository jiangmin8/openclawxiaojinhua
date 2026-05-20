# Ruflo 蜂群编排研究

> 源：`/mnt/e/知识库种子/ruflo/` (github.com/ruvnet/ruflo)
> 日期：2026-05-20 | 星数：53K | 月增：21K

## 核心架构

**15-Agent Hierarchical Mesh** — Queen 领导专用 Worker：
```
User → Ruflo(MCP) → Router → Swarm → Agents → Memory → LLM
                        ↑                         |
                        +--- Learning Loop <------+
```

## 关键差异 vs CrewAI Flow

| | CrewAI Flow | Ruflo Swarm |
|:---|:---|:---|
| 拓扑 | 线性 @listen 链 | 层级 Mesh（Queen+Workers） |
| 领导者 | 无（平等链路） | Queen Agent 协调 |
| 记忆 | MemoryScope | AgentDB (SQLite+向量) |
| 扩展 | 单机 | Federation 跨机器 |
| 审计 | 无 | Event Sourcing 全审计 |
| API | Python 原生 | MCP-first |
| 架构 | 装饰器 | 微内核+插件 |

## 关键模式

### 1. Queen-led Swarm
Queen 下达任务 → Workers 并行执行 → 结果汇聚回 Queen → Queen 验收

### 2. Federation 跨机器
代理可部署在不同机器，通过安全通道通信，不泄漏数据

### 3. Self-learning Loop
每次任务 → 记录成功模式 → 下次自动路由到最优 Agent

### 4. MCP-first
所有 API 通过 MCP 暴露：`memory_store`、`swarm_init`、`agent_spawn`

## 对雅典娜的价值

| 模式 | 可借鉴度 |
|:---|:---|
| Queen-led Swarm（我们缺） | ⭐⭐⭐ |
| Self-learning routing（升级 Subconscious Loop） | ⭐⭐⭐ |
| Federation（以后多台机器） | ⭐⭐ |
| Event Sourcing（审计 trail） | ⭐⭐ |
