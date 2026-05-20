# agent-skills 模式研究

> 源：`/mnt/e/知识库种子/agent-skills/` (github.com/addyosmani/agent-skills)
> 日期：2026-05-20
> 星数：44K | 月增：26K

## 架构

```
agent-skills/
├── skills/              # 23 个工程技能
│   ├── interview-me/    # 需求访谈
│   ├── spec-driven-dev/ # 规格驱动开发
│   ├── planning-and-task-breakdown/ # 任务分解
│   ├── incremental-implementation/  # 增量实现
│   ├── test-driven-dev/ # TDD
│   ├── code-review-and-quality/     # 五轴审查
│   ├── debugging-and-error-recovery/# 调试与恢复
│   ├── security-and-hardening/      # 安全加固
│   ├── code-simplification/         # 代码简化
│   └── shipping-and-launch/         # 发版上线
├── agents/              # 3 个专家 persona
├── references/          # 4 个补充清单
└── hooks/               # 会话生命周期钩子
```

## 核心设计模式

### 1. SKILL.md 统一结构
```
Overview → When to Use → Process(步骤) → Common Rationalizations(防借口) → Red Flags(警告信号) → Verification(验证标准)
```

### 2. Anti-rationalization 反借口表
每个技能预埋 AI 常用偷懒理由和反驳：

| 借口 | 现实 |
|:---|:---|
| "代码能跑就行" | 能跑但不可读/不安全/架构错=复利债务 |
| "我写的我知道正确" | 作者对自己假设有盲区 |
| "以后再清理" | 以后永远不会来 |
| "AI 代码应该没问题" | AI 代码需要更多审查，不是更少 |
| "测试过了就对了" | 测试必要但不充分 |

### 3. Five-Axis Review 五轴审查
1. Correctness — 功能正确、边界处理、错误路径
2. Readability — 命名规范、控制流、死代码
3. Architecture — 模块边界、依赖方向、抽象层次
4. Security — 输入验证、密钥管理、注入防护
5. Performance — N+1 查询、无界循环、同步阻塞

### 4. Change Sizing 变更规模
- ~100行 = 好
- ~300行 = 可接受（单逻辑变更）
- ~1000行 = 太大，必须拆

### 5. Vertical Slicing 纵向切片
❌ 横向：全建数据库→全建API→全建UI
✅ 纵向：用户注册(DB+API+UI)→用户登录→创建任务→查看列表

每条切片独立可测可交付。

### 6. Plan Mode 规划模式
规划阶段只读，禁止写代码。输出是计划文档，不是实现。

## 对雅典娜的提升

| 模式 | 当前状态 | 改进 |
|:---|:---|:---|
| 反借口表 | 无 | 每个 archetype 加 Rationalizations 表 |
| 五轴审查 | reviewer 有 P0-P3 分级 | 加 Correctness/Architecture 维度 |
| 变更规模 | 无 | code_executor 加行数限制 |
| 纵向切片 | planner 有步骤分解 | 加垂直切片指导 |
| 规划模式 | 无 | planner 加只读约束 |
