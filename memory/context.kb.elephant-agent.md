# Elephant Agent 研究

> 源：`/mnt/e/知识库种子/elephant-agent/` (github.com/agentic-in/elephant-agent)
> 日期：2026-05-20 | ⭐346

## 核心架构

30+ 模块，三层自进化体系：

```
curiosity (好奇引擎) → 从会话中生成 OpenQuestion → 驱动探索
        ↓
understanding (理解引擎) → Personal Model 4镜治理 → 事实/信念管理
        ↓
growth (成长引擎) → ProgressionRollout → 门控升级
```

## 三个关键引擎

### 1. Curiosity — 好奇引擎
- 后台学习 Agent 从每个 Episode 自动提取 "应该问的问题"
- 不是预设题库，是从上下文缺口发现的
- `open_question_generator.py` + `proactive_ask_policy.py`

### 2. Understanding — 理解引擎
- TopicPath: domain.entity.aspect 层级话题
- TopicRelation: same_topic / same_entity / same_domain / unrelated
- Personal Model Governance: 事实冲突检测，自动退役过时信念
- `personal_model_governance.py` + `auto_retire.py`

### 3. Growth — 成长引擎
- 回放评分卡 + 升级门控
- 控制系统：只在"有意义的工作超过重复琐事"时才推进
- 门控条件：分数方差限制、动机增量下限、progression 占比上限

## 4镜 Personal Model

| Lens | 记什么 | 对雅典娜 |
|:---|:---|:---|
| Identity | 大哥是谁、怎么决策、边界 | `context.user.pref.md` 已覆盖 |
| World | 项目、人、工具、地盘 | `context.project.md` + `context.base.md` |
| Pulse | 当下焦点、压力、节奏 | **完全缺失** |
| Journey | 过去经验、失败、恢复 | 部分在 `memory/YYYY-MM-DD.md` |

## 可借鉴的 3 件事

1. **Curiosity 引擎** — 加在 Subconscious Loop 上：每个 tick 不只评估，还生成一个 "应该问大哥的问题"
2. **4镜 Pulse** — 当前状态感知（焦点/压力/节奏），我们完全缺
3. **自动退役** — `auto_retire.py`：过时的信念自动标记废弃，避免陈旧记忆污染决策
