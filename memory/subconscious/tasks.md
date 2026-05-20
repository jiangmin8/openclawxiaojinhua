# Subconscious Loop — 任务注册表

> 后台持续评估循环。每 5 分钟一个 tick，本地模型评估 → skip/act/escalate。

## 系统任务（不可删除，可禁用）

| ID | 任务 | 意图 | 间隔 | 状态 |
|:---|:---|:---|:---|:---|
| sys-001 | 巡检关键服务（Ollama/Gateway/SSH） | read | 每tick | ✅ |
| sys-002 | 磁盘/内存/GPU 资源监控 | read | 每3tick | ✅ |
| sys-003 | 路由器+AP 连通性 | read | 每6tick | ✅ |
| sys-004 | 扫描最近记忆中的待办/告警 | read | 每tick | ✅ |
| sys-005 | 检查 cron job 健康状态 | read | 每6tick | ✅ |

## 用户任务

| ID | 任务 | 意图 | 间隔 | 状态 |
|:---|:---|:---|:---|:---|
| user-001 | 发现记忆中的新未完成事项 | read | 每3tick | ✅ |
| user-002 | 检查知识库索引时效 | read | 每12tick | ✅ |

## 评估协议

每个 tick：
1. 构建态势报告（服务状态 + 资源 + 最近记忆摘要）
2. 本地模型对每个到期任务返回：`skip` | `act` | `escalate`
3. skip → 记录"无新事"到活动日志
4. act → 用本地模型执行轻量动作
5. escalate → 触发云端 Agent 深度推理

## 状态：活跃
