# iii 引擎 — 零集成共享运行时

> 源：`/mnt/e/知识库种子/iii/` (github.com/iii-hq/iii)
> 日期：2026-05-20
> 标签：engine, runtime, agentmemory-backend, worker-fabric

## 一句话

iii 是 agentmemory 的底层引擎。把队列、cron、HTTP、状态、可观测性、agent、沙盒折叠进一个活系统表面，不再需要点对点集成。

## 核心三原语

```
Worker → Function → Trigger
```

| 原语 | 说明 |
|:---|:---|
| **Worker** | 注册到引擎的进程（TS/Python/Rust 都行），运行时也可动态创建新 Worker |
| **Function** | 有稳定标识的工作单元，如 `content::classify`、`orders::validate` |
| **Trigger** | 触发函数执行的事件源：直接调用、HTTP端点、cron、队列、状态变更、流 |

## 技术栈

| 层 | 技术 | License |
|:---|:---|:---|
| Engine (核心运行时) | Rust | Elastic License 2.0 |
| SDK | Node.js / Python / Rust | Apache 2.0 |
| Console | React + Rust | Apache 2.0 |
| Skills | Markdown 技能文档 | Apache 2.0 |

## 仓库结构

```
iii/
├── engine/      # Rust 核心引擎（运行时、模块、协议）
├── sdk/         # Node.js / Python / Rust SDK
├── console/     # 开发者控制台（React + Rust）
├── skills/      # Agent 可读参考文档
├── website/     # iii.dev 站点
├── docs/        # Mintlify/MDX 文档
├── crates/      # Rust 子 crate：
│   ├── iii-filesystem   # 文件系统模块
│   ├── iii-init         # 初始化
│   ├── iii-network      # 网络模块
│   ├── iii-shell-client # Shell 客户端
│   ├── iii-shell-proto  # Shell 协议
│   ├── iii-supervisor   # 监督进程
│   ├── iii-worker       # Worker 管理
│   ├── motia-tools      # 工具集
│   └── scaffolder-core  # 项目脚手架
└── infra/       # 基础设施配置
```

## 核心能力

| 能力 | 说明 |
|:---|:---|
| **零集成** | `iii worker add queue/cron/agent/sandbox` 一行即用 |
| **实时发现** | Worker 加入后立即被其他 Worker 发现并调用 |
| **跨语言** | TS/Python/Rust Worker 互操作 |
| **Agent 原生** | Agent 可动态添加 Worker → 发现函数 → 调用 → 追踪 |
| **运行时扩展** | Worker 可在运行时创建新 Worker |
| **全栈可观测** | OpenTelemetry: traces/metrics/logs 内置 |

## 安装与端口

```bash
curl -fsSL https://install.iii.dev/iii/main/install.sh | sh
iii --use-default-config     # 启动引擎
# WebSocket: ws://localhost:49134
# HTTP API:  http://localhost:3111
```

## 对我们（雅典娜）的意义

| 维度 | 价值 |
|:---|:---|
| **理解现有系统** | agentmemory Memory skill 的引擎层，理解它才能调优记忆系统 |
| **Worker 工厂模式** | iii 的 Worker 动态注册 = Flow 引擎的 Archetype 动态加载 |
| **运行时扩展** | 雅典娜可在运行时添加新工具 Worker，不被静态规则限制 |
| **三原语映射** | Worker=Archetype, Function=节点, Trigger=监听器 → Flow 引擎自然映射 |
| **Console 灵感** | iii Console 的实时系统仪表板 → 雅典娜 Dashboard v2 |

## 关键洞察

1. **iii 是 agentmemory 的地基** — agentmemory 的 hooks/MCP/四层固化全部跑在 iii engine 上
2. **Worker 即能力单元** — 与我们 Flow 引擎的 Archetype 同构：可安装、可发现、可组合
3. **三原语极简** — Worker·Function·Trigger 三个概念覆盖所有后端模式，雅典娜工具系统可对齐
4. **实时可观测** — 每个 Function 调用都记录 trace，不需要事后拼凑日志
5. **当前未引入** — 雅典娜未直接使用 iii，但 agentmemory 已经依赖它运行
