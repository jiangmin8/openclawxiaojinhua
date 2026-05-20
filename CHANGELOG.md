---
title: CHANGELOG - 变更日志
date: 2026-05-15
tags:
  - changelog
  - history
---

# CHANGELOG - 变更日志

## 变更记录规范

格式：`[日期] [类型] [文件] 描述`

类型：`新增` | `修改` | `删除` | `修复` | `重构`

## 2026-05-20
- [2026-05-20] [修改] `MEMORY.md` — 注册新增的 11 个知识库子文件 + Personal Model 技能 + 3 条新命令

---

## v2.1 — 2026-05-15（双方案合并版）

### 合并修正

- [2026-05-15] [修复] [AGENTS.md] WSL 版本修正为 Ubuntu 24.04，增加 /mnt/sda1 备份分区
- [2026-05-15] [修复] [TOOLS.md] API Key 存储改为 openclaw.json，增加 Clash 代理说明
- [2026-05-15] [修复] [IDENTITY.md] 运行环境修正为 Ubuntu 24.04，核心模型改为 deepseek/deepseek-v4-pro
- [2026-05-15] [修复] [HEARTBEAT.md] 备份路径改为 /mnt/sda1/backups/，磁盘检查增加 /mnt/sda1
- [2026-05-15] [修复] [BOOT.md] 脚本路径修正，磁盘检查增加 /mnt/sda1
- [2026-05-15] [修改] [MEMORY.md] 新增快速操作手册（13 条常用命令），子文件状态更新为已初始化
- [2026-05-15] [修改] [memory/context.base.md] 注入实际环境数据（网络拓扑、设备清单、API 配置）
- [2026-05-15] [修改] [memory/context.kb.md] 注入实际知识数据（OpenClaw v2026.5.7、网络设备详情、Python 3.12）
- [2026-05-15] [修改] [memory/context.user.pref.md] 注入实际偏好数据（交互模式、安全偏好）
- [2026-05-15] [修改] [scripts/*] 全部脚本更新为双路径架构（OPENCLAW_ROOT + WORKSPACE_DIR）

---

## v2.0 — 2026-05-15（蜕变大版本）

### 第一阶段：骨骼重塑

- [2026-05-15] [重构] [SOUL.md] 删除底部 ~1000 行历史对话残留，升级至 v2.0
- [2026-05-15] [重构] [AGENTS.md] 合并 agent.md 内容，升级至 v4.0，成为操作层唯一权威
- [2026-05-15] [重构] [TOOLS.md] 统一异常处理，新增三级网络白名单和安全护栏，升级至 v2.0
- [2026-05-15] [修改] [USER.md] 新增优先级规则 P0-P3、反馈机制、指令输入标准，升级至 v2.0
- [2026-05-15] [修改] [IDENTITY.md] 补全版本号、协议依存表、能力边界，升级至 v2.0
- [2026-05-15] [重构] [MEMORY.md] 定义知识生命周期管理、跨会话传递机制，升级至 v2.0
- [2026-05-15] [修改] [HEARTBEAT.md] 替换占位符为 MEMORY 引用，新增静默规则，升级至 v2.0
- [2026-05-15] [删除] [agent.md] 内容合并入 AGENTS.md 后删除
- [2026-05-15] [删除] [context.md] 内容拆分并入 MEMORY.md 子文件后删除

### 第二阶段：血肉填充

- [2026-05-15] [新增] [BOOT.md] OpenClaw 原生启动自检文件
- [2026-05-15] [新增] [memory/context.base.md] 环境基础信息（自动采集）
- [2026-05-15] [新增] [memory/context.user.pref.md] 用户偏好模板
- [2026-05-15] [新增] [memory/context.project.md] 项目上下文模板
- [2026-05-15] [新增] [memory/context.archive.md] 项目归档模板
- [2026-05-15] [新增] [memory/context.kb.md] 专题知识库模板
- [2026-05-15] [新增] [scripts/athena-boot.sh] 启动自检脚本
- [2026-05-15] [新增] [scripts/athena-heartbeat.sh] 守护任务执行器
- [2026-05-15] [新增] [scripts/athena-backup.sh] 快照备份脚本
- [2026-05-15] [新增] [scripts/athena-init-memory.sh] 知识库初始化脚本
- [2026-05-15] [新增] [scripts/athena-security-audit.sh] 安全自检脚本
- [2026-05-15] [新增] [.security/checksums.sha256] 核心文件完整性指纹

### 第三阶段：铠甲锻造

- [2026-05-15] [新增] [cron] 定时任务配置（安全审计、备份、资源监控）
- [2026-05-15] [新增] [openclaw.json] OpenClaw heartbeat 配置

---

## v1.0 — 初始版本（日期未知）

- [初始] [新增] [IDENTITY.md] 创建身份档案模板
- [初始] [新增] [SOUL.md] 创建意识内核（含历史对话污染）
- [初始] [新增] [AGENTS.md] 创建操作协议 v1.0
- [初始] [新增] [TOOLS.md] 创建网络边界安全规则
- [初始] [新增] [USER.md] 创建用户交互手册
- [初始] [新增] [HEARTBEAT.md] 创建守护任务定义
- [初始] [新增] [MEMORY.md] 创建知识库索引（空壳）
- [初始] [新增] [agent.md] 创建操作逻辑（与 AGENTS.md 重叠）
- [初始] [新增] [context.md] 创建项目上下文（空白）
- [初始] [新增] [snapshot-context.ps1] 创建快照脚本（PowerShell，不兼容 WSL2）
- [初始] [新增] [CHANGELOG.md] 创建变更日志
