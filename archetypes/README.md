# 子 Agent 原型库

> 预定义的子 Agent 模板。发起子任务时匹配最近的 archetype，注入专属 prompt + 工具范围。

## 原型目录

| 原型 | 触发词 | 说明 |
|:---|:---|:---|
| researcher | 查、搜索、调研、找 | Web/doc 检索 + 信息提取 |
| code_executor | 写代码、调试、运行 | 代码编写 + 执行 + 验证 |
| planner | 规划、拆解、方案 | 多步骤任务分解 |
| reviewer | 审查、审计、检查 | 代码审查 + 安全审计 |
| system_guard | 巡检、监控、磁盘 | 系统健康检查 |
