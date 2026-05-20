# context.md — 项目上下文与知识库

## 1. 项目概览
- 项目名称: （请填写）
- 核心目标: （请填写项目的主要目标）
- 当前阶段: 需求/开发/测试/部署

## 2. 技术栈
- 编程语言: Python 3.10+, TypeScript
- 框架: FastAPI, React
- 基础设施: Docker, Kubernetes
- 数据库/缓存: PostgreSQL, Redis

## 3. 关键业务规则与假设
- 所有 API 请求必须经 JWT 验证。
- 数据同步要求：24 小时内完成；失败需重试策略。
- 任何架构或数据删除类改动须经用户确认（HITL）。

## 4. 项目进度（示例）
- 已完成：初始化项目结构、数据库 schema 设计
- 进行中：用户认证模块、集成测试
- 待办：生产部署、性能优化

## 5. 重要路径（示例）
- workspace: C:\Users\lz\Desktop\12\workspace
- logs: C:\Users\lz\Desktop\12\logs
- audit: C:\Users\lz\Desktop\12\audit

## 6. 使用说明
- agent 启动时应加载本文件快照作为运行上下文（只读）。
- 修改本文件时请同时更新 CHANGELOG.md 并保留备份。

## 7. 维护者
- Owner: Master（首席架构师）

## 更新记录
- 2026-05-15: 创建初始版本
