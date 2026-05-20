# 技能吸收审计表

> 日期：2026-05-20 | 来源数：15 | 落地：4 | 仅记录：7 | 零落地：4

| # | 来源 | URL | 核心功能 | 提取了什么 | 落地 | 漏了什么 / 要补 |
|:---|:---|:---|:---|:---|:---|:---|
| 1 | OpenHuman | https://github.com/tinyhumansai/openhuman | Memory Tree、TokenJuice、Subconscious Loop、118+集成、模型路由 | Memory Tree + TokenJuice + Loop | ✅ | 无 |
| 2 | CrewAI | https://github.com/crewAIInc/crewAI | Flow/@listen/@router 事件链、Crew编排、Agent适配器 | Flow 引擎 | ✅ | 无 |
| 3 | agent-skills | https://github.com/addyosmani/agent-skills | 反借口表、五轴审查、变更规模控制(~100行)、Plan Mode(读才写)、纵向切片 | 反借口表 | ✅ SKILL.md内 | ❌ 五轴审查 ❌ 变更规模 ❌ Plan Mode ❌ 纵向切片 |
| 4 | CloakBrowser | https://github.com/CloakHQ/CloakBrowser | 隐身Chromium(49处C++补丁)、headless=True、30项检测全过 | 仅记录 | ❌ | ❌ browser替代方案 ❌ headless配置 |
| 5 | Ruflo | https://github.com/ruvnet/ruflo | Queen-led Swarm、Federation跨机、Self-learning路由、MCP-first、Event Sourcing | 仅记录 | ❌ | ❌ Queen+Worker ❌ Federation ❌ Learning Loop |
| 6 | JiuwenSwarm | https://github.com/openJiuwen-ai/jiuwenswarm | 个人管家、反馈驱动自演进、华为生态 | 仅记录 | ❌ | ❌ 反馈驱动自演进 |
| 7 | Mano-P | https://github.com/Mininglamp-AI/Mano-P | GUI-VLA、三阶段自增强(SFT→离线RL→在线RL)、思考-行动-验证 | 仅记录 | ❌ | ❌ 三阶段训练法 |
| 8 | mattpocock/skills | https://github.com/mattpocock/skills | 共享词表(ubiquitous-language)、语言精确化 | 共享词表 | ✅ | 无 |
| 9 | anthropics/skills | https://github.com/anthropics/skills | 官方SKILL.md标准(name+description YAML头) | SKILL.md格式 | ✅ | 无 |
| 10 | Elephant Agent | https://github.com/agentic-in/elephant-agent | 4镜Personal Model、Curiosity引擎、Growth rollout、自动退役、证据系统 | 4镜 + SKILL.md | ⚠️ 骨架 | ❌ Curiosity引擎 ❌ Growth rollout ❌ 证据系统 ❌ 自动退役 |
| 11 | Memori | https://github.com/MemoriLabs/Memori | 执行轨迹(agent做什么)、知识图谱、异步增强、域隔离、OpenClaw原生插件 | 仅记录 | ❌ | ❌ 执行轨迹记录 ❌ 知识图谱交叉引用 ❌ 异步记忆写入 ❌ 域隔离 |
| 12 | PraisonAI | https://github.com/MervinPraison/PraisonAI | AI劳动力、AgentFlow可视化管道、100+LLM、MCP原生 | 仅记录 | ❌ | ❌ AgentFlow可视化(参与感) |
| 13 | codegraph | https://github.com/colbymchenry/codegraph | 语义代码图谱、94%减少工具调用 | 仅记录 | ❌ | ❌ 无(场景不匹配) |
| 14 | iii | https://github.com/iii-hq/iii | Worker-Function-Trigger三原语、零集成共享运行时、agentmemory引擎、实时可观测 | Worker工厂模式理解 | ⚠️ 理解层 | ❌ Worker运行时动态注册 ❌ Console仪表板复用 |
| 15 | agentmemory | https://github.com/rohitg00/agentmemory | 53 MCP工具、4层记忆固化、9 hooks自动捕获、混合搜索BM25+向量+图谱、OpenClaw原生插件 | Memory Skill后端全貌 + OpenClaw插件路径 | ⚠️ 仅用7工具shim | ❌ 升级到51工具proxy模式 ❌ 本地embedding ❌ PostToolUse执行轨迹 ❌ 知识图谱 ❌ 团队记忆 |

---

## 补缺优先级

| 优先级 | 项目 | 要补什么 |
|:---|:---|:---|
| 🔴 P0 | **agentmemory 升级** | 启动 agentmemory server → 51工具proxy模式 → PostToolUse自动记录执行轨迹+决策+结果 |
| 🔴 P0 | **agent-skills** | 五轴审查 + 变更规模 + Plan Mode — 注入 archetypes |
| 🟡 P1 | **Elephant Agent** | Curiosity引擎 + Growth rollout + 自动退役 |
| 🟡 P1 | **PraisonAI** | AgentFlow可视化 — 提升大哥参与感 |
| 🟢 P2 | **CloakBrowser** | 实际部署测试 |
| 🟢 P2 | **Ruflo** | Queen+Worker 并行模式 |
| ⏸️ P3 | **JiuwenSwarm** | 反馈驱动自演进 |
| 🟡 P1 | **agentmemory 深度** | 本地embedding(@xenova/transformers) → 免费离线向量搜索 + 知识图谱 |
| 🟢 P2 | **iii Worker** | Flow 引擎 Worker 动态注册（仿 iii worker add 模式） |
| ⏸️ P3 | **Mano-P** | 三阶段训练法(需Apple Silicon) |
