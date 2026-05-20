# 雅典娜共享词表（Ubiquitous Language）

> 大哥与雅典娜通信的规范术语。同一概念用同一词，消除歧义。
> 规则：精确定义 + 禁词列表 + 关系 + 示例对话。

## 架构层

| 术语 | 定义 | 禁词 |
|:---|:---|:---|
| **Flow** | CrewAI 风格事件驱动编排，@start→@listen→@router 链 | 流水线、编排（太泛） |
| **Swarm** | 蜂群并行模式，Queen 派 N Worker 同时执行 | 集群、并行池 |
| **Subconscious Loop** | 每5分钟自动评估+分级响应(skip/act/escalate) | 心跳、守护 |
| **Tick** | Loop 的一次评估周期 | 巡检、轮询 |
| **Archetype** | 预定义的子 Agent 模板(researcher/code_executor...) | 角色、原型 |
| **Flow Engine** | `tools/flow-engine.py`，读 YAML 自动调度子 Agent | Flow、引擎 |

## 项目管理层

| 术语 | 定义 | 禁词 |
|:---|:---|:---|
| **锚点** | 远程局域网常开设备(Tailscale)，提供持久入口 | 跳板、桥接 |
| **刷机** | RAX3000Me 从原厂→OpenWrt 的完整流程 | 刷入、烧录 |
| **免拆** | 不拆机不开 TTL，纯 Web 接口导入配置刷机 | 软刷、在线刷 |
| **阻塞项** | 项目下一步无法推进的硬条件 | 卡点、依赖 |
| **知识库种子** | `/mnt/e/知识库种子/`，克隆的外部仓库 | 种子、源 |

## 设备层

| 术语 | 定义 | 禁词 |
|:---|:---|:---|
| **MT3600BE** | 主路由 192.168.8.1，GL.iNet，ARMv8，512MB | 主路由、GL |
| **RAX3000Me** | 待刷路由器，MT7981B，目标192.168.10.1 | 3000me、子路由 |
| **荣耀畅玩60M** | 大哥手机，NIC-AN00，Tailscale+ADB 桥接 | 手机、华为 |

## 能力层

| 术语 | 定义 | 禁词 |
|:---|:---|:---|
| **TokenJuice** | 工具输出压缩引擎，去重/截断/过滤 | 压缩、token 节省 |
| **Memory Tree** | L1来源/L2主题/L3全局 三层记忆摘要 | 记忆树、三层 |
| **反借口表** | 每个 archetype 预埋 AI 偷懒理由+反驳 | 防偷懒、反投机 |

## 验证层

| 术语 | 定义 | 禁词 |
|:---|:---|:---|
| **Tick 全绿** | 所有服务正常+资源正常+记忆无异常=skip | 一切正常、OK |
| **P0/P1/P2/P3** | 告警等级：紧急阻断/高优先/标准/建议 | 重要、紧急 |

## 关系

- **Flow** 包含 N 个 **Archetype**，每个 Archetype 执行一个节点
- **Swarm** 是 Flow 的升级——从串行链变成并行 Queen+Worker
- **Subconscious Loop** 每个 **Tick** 扫描 **阻塞项**，有变化则 **escalate**
- **锚点**(RAX3000Me) 通过 **Tailscale** 连接 **雅典娜**

## 常见歧义

| 歧义 | 规范 |
|:---|:---|
| "巡检"曾用于 cron 检查和 Loop tick | 统一：cron 检查="健康巡检"，Loop 评估="tick" |
| "节点"曾指 Flow 节点和网络设备 | Flow 用"节点"，设备用"设备/路由" |
| "蜂群"JiwenSwarm 和 Ruflo Swarm 不同 | Jiwen=名字带 Swarm 实际是管家，Ruflo=真并行蜂群 |

## 示例对话

> **大哥：** "Flow 引擎现在能跑蜂群吗？"
> **雅典娜：** "不能。Flow 是串行链，蜂群是并行 Queen+Worker。现在硬件 12GB 最多 2 Worker 迷你蜂群。"
> **大哥：** "那 RAX3000Me 刷完能当锚点？"
> **雅典娜：** "对。刷完装 Tailscale 就是那边的锚点，512MB 够用。阻塞项只剩手机没到现场。"
