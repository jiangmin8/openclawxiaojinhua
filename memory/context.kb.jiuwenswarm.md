# JiuwenSwarm 研究

> 源：`/mnt/e/知识库种子/jiuwenswarm/` (github.com/openJiuwen-ai/jiuwenswarm)
> 日期：2026-05-20 | 协议：Apache 2.0

## 定位

个人 AI 管家。Python + 华为云 MaaS + 小艺集成。`pip install jiuwenswarm` → `jiuwenswarm-start` → localhost:5173。

## 和 Ruflo 蜂群的本质差异

| | Ruflo | JiuwenSwarm |
|:---|:---|:---|
| 蜂群含义 | 多 Agent 并行协作 | 多任务智能调度 |
| 架构 | Queen-led Mesh | 单 Agent + 技能系统 |
| 自我进化 | Learning Loop 记录路由 | **用户反馈自动调技能** |
| 生态 | Claude Code/Codex | 华为云/小艺手机 |
| 语言 | TypeScript + Rust | 纯 Python |

## 关键亮点

**自主演进：** 用户表达不满或出错 → 自动调整相应技能。这个反馈闭环和 Mano-P 的离线 RL 思路一致——模型从失败中学习。

## 对雅典娜

| 值得借鉴 | 不值 |
|:---|:---|
| 反馈驱动技能自动调整 | 蜂群只是概念名，无并行 Agent |
| pip install 部署极简 | 华为生态绑定 |
| | 和现有 OpenClaw 架构重复 |

**结论：** 蜂群是名字不是架构。实质是个人管家加自演进，不是多 Agent 编排。对雅典娜参考价值低于 Ruflo。
