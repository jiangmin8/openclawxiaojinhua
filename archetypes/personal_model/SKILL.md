---
name: personal-model
description: Elephant 风格 4 镜 Personal Model（Identity/World/Pulse/Journey）。从会话中提炼关于大哥的理解，自动记忆、可纠正、自动退役。会话结束后或 Loop 触发时自动运行。
---

# Personal Model 技能

> 🐘 Elephants never forget — but they remember with meaning, not verbatim.
> 不存一切，只存对未来帮助有价值的理解。

## 何时触发

- 每次会话结束后自动运行
- Subconscious Loop 检测到新记忆时触发
- 大哥明确说"更新个人模型"

## 4 镜模型

### Identity — 大哥是谁
记：价值观、决策风格、边界、长期偏好。禁：临时情绪。

### World — 大哥的世界
记：活跃项目、关键设备、工具链、术语。禁：一次性的工具试用。

### Pulse — 当下的脉动
记：当前焦点、活跃压力、节奏模式。禁：单次事件。

### Journey — 走过的路
记：重要经验、失败模式、恢复策略。禁：成功学总结。

## 更新流程（双模式）

### 触发条件
- 会话结束
- Subconscious Loop tick
- 大哥明确指令"更新 Personal Model"

### 步骤 1：初始化执行轨迹
```python
from tools.activity_log import ActivityLog
log = ActivityLog("memory/subconscious/activity.log.md")
log.start_tick(trigger_type="tick", session_id="当前会话ID")
```

### 步骤 2：读取现有模型
Plan Mode：必须先执行 `memory_get PERSONAL_MODEL.md`，禁止盲写。

### 步骤 2：判断模式

| 条件 | 模式 |
|:---|:---|
| ≤2条信念更新 AND 单镜头 | 轻量模式 |
| >2条信念 OR 跨镜头 | 重量模式 |

### 步骤 3a：轻量模式（3轴审查）

| 轴 | 检查项 | 通过标准 |
|:---|:---|:---|
| 正确性 | 有证据支撑 | ≥1个来源 |
| 安全 | 无敏感信息 | 密码/IP/密钥已脱敏 |
| 可执行性 | 雅典娜能执行 | 工具/权限/路径可用 |

### 步骤 3b：重量模式（全量）
1. **六轴审查**（正确性/可读性/架构一致/安全/性能/可执行性）
2. **变更规模控制**：≤3条/轮，>10条拆轮次
3. **纵向切片**：大更新拆多轮，每轮独立输出

### 步骤 4：原子写入
```bash
# 伪代码
write_to PERSONAL_MODEL.md.tmp
verify_checksum PERSONAL_MODEL.md.tmp
atomic_rename PERSONAL_MODEL.md.tmp → PERSONAL_MODEL.md
```

### 步骤 5：记录执行轨迹
每一步工具调用后执行：
```python
log.record_tool_call(tool_name="...", tool_input="...", tool_output="...", decision="...")
```
完成后：
```python
log.record_output(open_question="...", belief_updates=["..."], mode="轻量/重量")
log.finalize(status="成功/失败/escalate", retry_count=0-3)
log.save()
```

### 步骤 6：失败处理
| 次数 | 动作 |
|:---|:---|
| 1-2 | 记录失败原因，下轮 tick 重试 |
| 3 | escalate 通知大哥 |

### 步骤 7：完成
memory-tree 可视化由独立 30min cron 处理，与此流程无关。

## 工作流程

1. 扫描最近会话记录 + 当前 `memory/PERSONAL_MODEL.md`
2. 提炼新信念到对应镜头
3. 冲突检测：新旧信念矛盾时标注 `[待确认]`
4. 退役检查：>30天未引用的信念标 `[stale]`，>90天移除
5. 生成 1 个 OpenQuestion（信息缺口）

## 输出格式

```markdown
## [时间] Personal Model 更新

### Identity
- [新/更新] 信念 `[证据: 来源]`

### World  
- [新/更新] 项目/设备/人

### Pulse
- 当前焦点: xxx
- 活跃压力: xxx

### Journey
- 经验教训: xxx

### Open Questions
- 🐘 Q: [问题] (优先级: 高/中/低)
```

## 反借口表

| AI 会说 | 反驳 |
|:---|:---|
| "这个信息不重要，不记了" | 对未来帮助=重要，不止当下有用才记 |
| "上次已经记过了" | 检查是否变旧。同信息不同时间=不同含义 |
| "大哥没明确说" | 从行为和决策模式推断，标注置信度 |
| "太忙了跳过这轮" | 累积=丢失。每轮至少处理一个镜头 |

## 存储

`memory/PERSONAL_MODEL.md` — 持久化存储。`memory_search` 可检索。
