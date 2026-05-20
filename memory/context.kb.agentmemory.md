# agentmemory — 持久化智能体记忆系统

> 源：`/mnt/e/知识库种子/agentmemory/` (github.com/rohitg00/agentmemory)
> 日期：2026-05-20
> 引擎：iii (github.com/iii-hq/iii)
> 标签：memory, mcp, hooks, openclaw-plugin

## 一句话

95.2% 检索准确率的持久化记忆运行时。53 个 MCP 工具 + 12 个自动 hooks + 4 层记忆固化。雅典娜正在使用。

## 核心理念

**"你的编程 agent 记住一切，不再需要重复解释。"**

Session 1 你配置了 JWT 认证。Session 2 你要求做限流。Agent 已经知道认证用的是 `src/middleware/auth.ts` 的 jose 中间件、测试覆盖了 token 验证、你选了 jose 而不是 jsonwebtoken 是为了 Edge 兼容性。无需重新解释。

## 安装

```bash
npm install -g @agentmemory/agentmemory
agentmemory              # 启动记忆服务器 :3111
agentmemory demo         # 种子演示数据
agentmemory connect claude-code
```

## 四层记忆固化（仿人脑）

| 层 | 内容 | 类比 |
|:---|:---|:---|
| **Working** | 工具使用原始观察 | 短期记忆 |
| **Episodic** | 压缩的会话摘要 | "发生了什么" |
| **Semantic** | 提取的事实和模式 | "我知道什么" |
| **Procedural** | 工作流和决策模式 | "怎么做" |

记忆随时间衰减（艾宾浩斯曲线）。高频访问的记忆增强。过时记忆自动驱逐。矛盾检测与解决。

## 记忆管道

```
PostToolUse hook 触发
  → SHA-256 去重 (5分钟窗口)
  → 隐私过滤器 (剥离 secrets、API keys)
  → 存储原始观察
  → LLM 压缩 → 结构化事实 + 概念 + 叙事
  → 向量嵌入 (6个provider + 本地)
  → BM25 + 向量索引

Stop / SessionEnd hook 触发
  → 会话摘要
  → 知识图谱提取 (GRAPH_EXTRACTION_ENABLED=true)
  → Slot 反思 (SLOT_REFLECT_ENABLED=true)

SessionStart hook 触发
  → 加载项目画像 (top概念、文件、模式)
  → 混合搜索 (BM25 + 向量 + 图谱)
  → Token 预算 (默认 2000 tokens)
  → 注入对话
```

## 捕获内容（9 个 hooks）

| Hook | 捕获 |
|:---|:---|
| `SessionStart` | 项目路径、session ID |
| `UserPromptSubmit` | 用户提示（隐私过滤后） |
| `PreToolUse` | 文件访问模式 + 增强上下文 |
| `PostToolUse` | 工具名、输入、输出 |
| `PostToolUseFailure` | 错误上下文 |
| `PreCompact` | 压缩前重新注入记忆 |
| `SubagentStart/Stop` | 子 agent 生命周期 |
| `Stop` | 会话结束摘要 |
| `SessionEnd` | 会话完成标记 |

## MCP 工具体系（53 个）

### 核心工具（始终可用）
`memory_recall` | `memory_save` | `memory_smart_search` | `memory_sessions` | `memory_export` | `memory_audit` | `memory_governance_delete` | `memory_compress_file` | `memory_patterns` | `memory_timeline` | `memory_profile` | `memory_relations` | `memory_file_history`

### 扩展工具（AGENTMEMORY_TOOLS=all）
`memory_graph_query` | `memory_consolidate` | `memory_claude_bridge_sync` | `memory_team_share` | `memory_team_feed` | `memory_snapshot_create` | `memory_action_create/update` | `memory_frontier` | `memory_next` | `memory_lease` | `memory_routine_run` | `memory_signal_send/read` | `memory_checkpoint` | `memory_mesh_sync` | `memory_sentinel_create/trigger` | `memory_sketch_create/promote` | `memory_crystallize` | `memory_diagnose` | `memory_heal` | `memory_facet_tag/query` | `memory_verify`

### MCP 双模式

| 模式 | 触达条件 | 工具数 |
|:---|:---|:---|
| **Shim (回退)** | 无运行中服务器 | 7 工具 |
| **Proxy (完整)** | AGENTMEMORY_URL 可达 | 51+ 工具 |

雅典娜当前使用 7 工具 shim 模式（通过 Memory skill）。

## 关键能力矩阵

| 能力 | 说明 |
|:---|:---|
| **自动捕获** | 每个工具调用通过 hooks 自动记录 |
| **混合搜索** | BM25 + 向量 + 知识图谱 RRF 融合 |
| **记忆演化** | 版本控制、继承、关系图 |
| **自动遗忘** | TTL 过期、矛盾检测、重要性驱逐 |
| **隐私优先** | API keys、secrets、`<private>` 标签存储前剥离 |
| **自愈** | 熔断器、provider 回退链、健康监控 |
| **Claude 桥接** | 双向同步 MEMORY.md |
| **知识图谱** | 实体提取 + BFS 遍历 |
| **团队记忆** | 命名空间的共享+私有记忆 |
| **引用溯源** | 任何记忆可追溯到源观察 |
| **Git 快照** | 版本、回滚、diff 记忆状态 |
| **CJK 支持** | 可选 jieba/tiny-segmenter 分词 |

## 搜索架构（三流融合）

| 流 | 机制 | 触发条件 |
|:---|:---|:---|
| **BM25** | 词干关键词 + 同义词扩展 | 始终开启 |
| **向量** | 稠密向量余弦相似度 | 配置了 embedding provider |
| **图谱** | 知识图谱实体匹配遍历 | 查询中检测到实体 |

RRF (Reciprocal Rank Fusion, k=60) 融合，会话多样化（每会话最多 3 结果）。

## Embedding Provider

| Provider | 模型 | 费用 | 备注 |
|:---|:---|:---|:---|
| **本地 (推荐)** | all-MiniLM-L6-v2 | 免费 | 离线，+8pp 召回 vs 纯 BM25 |
| Gemini | gemini-embedding-001 | 免费层 | 100+ 语言 |
| OpenAI | text-embedding-3-small | $0.02/1M | 最高质量 |
| Voyage AI | voyage-code-3 | 付费 | 代码优化 |
| Cohere | embed-english-v3.0 | 免费试用 | 通用 |
| OpenRouter | 任意模型 | 可变 | 多模型代理 |

## OpenClaw 集成

```
~/.openclaw/extensions/agentmemory/
├── plugin.yaml         # memory slot + hooks 配置
├── plugin.mjs          # 插件逻辑
├── package.json
└── openclaw.plugin.json

hooks: on_session_start / on_pre_llm_call / on_post_tool_use / on_session_end
config: base_url:3111, token_budget:2000, min_confidence:0.5
```

通过 MCP 暴露 43 个工具给 OpenClaw 会话。

## 路线图

| 季度 | 主题 | 关键项 |
|:---|:---|:---|
| Q2 2026 | Depth | 多模态记忆、GitHub连接器、会话回放UI、CI基准测试 |
| Q3 2026 | Breadth | Hook扩展、社区建设、OpenSSF Scorecard |
| Q4 2026 | Trust | SSO、审计导出、RBAC、长期部署 |
| Q1 2027 | v1.0 | 稳定性、LTS、semver 冻结 |

## 治理

- 模式：Linux Foundation MVG (Minimum Viable Governance)
- 许可：Apache 2.0
- 维护者：[MAINTAINERS.md](https://github.com/rohitg00/agentmemory/blob/main/MAINTAINERS.md)
- 数据主权：默认存储在用户机器上

## 对雅典娜的意义

| 维度 | 状态 | 价值 |
|:---|:---|:---|
| **Memory Skill** | ✅ 已安装 | 当前 7 工具 shim 模式运行 |
| **升级到 Proxy** | 📋 待实施 | 启动 server → 51 工具全开 → 知识图谱/团队记忆/哨兵 |
| **执行轨迹 (P0)** | 📋 审计表 P0 | agentmemory 的 PostToolUse hook 天然支持执行轨迹记录 |
| **本地 Embedding** | 📋 可选 | 安装 @xenova/transformers → 免费离线向量搜索 |
| **多 Agent 共享** | 🔮 未来 | memory_team_share → 雅典娜子 agent 共享记忆 |
| **OpenClaw 深度集成** | 📋 待部署 | 复制 plugin 到 extensions → hooks 自动捕获 OpenClaw 工具调用 |

## 关键洞察

1. **agentmemory ≠ Memori** — 两个独立项目。agentmemory 基于 iii 引擎，Memori 基于自研 Rust core
2. **当前仅用到 shim 模式** — 启动 agentmemory server 即可解锁全部 51+ 工具
3. **执行轨迹=记忆管道** — PostToolUse hook 天然记录每个工具的输入/输出/决策，正是 P0 执行轨迹需求
4. **iii 引擎是关键基础设施** — 理解 iii 才能调优 agentmemory 性能
5. **本地 embedding 零成本** — 安装 @xenova/transformers 即可离线向量搜索，不用 API
