# 2026-05-15 — 7 文件协议审计与重构

---

## 背景

Athena 系统元协议文件（AGENTS/SOUL/IDENTITY/USER/TOOLS/MEMORY/HEARTBEAT）长期未经审计，存在 Windows 盘符与 WSL2 Linux 环境不匹配、跨文件身份定义重复、Lint 违规大量等问题。

---

## 执行操作

### 1. AGENTS.md v3.0 重写
- 旧版: Windows 盘符 C:/D:/E:/F:/G: → 新版: WSL2 `/mnt/c` ~ `/mnt/g`
- 新增 Linux 原生 ext4 `/` 分区 + `/tmp` 映射
- 移除硬件快照（移至 context.base.md）
- 新增 III.4 自主守护授权条款

### 2. SOUL.md 精简
- 身份定义 (§0) 移入 IDENTITY.md
- 保留认知哲学 + 沟通协议
- 加「上线仪式」

### 3. IDENTITY.md 扩展
- 合并原 SOUL §0 身份字段
- 成为唯一身份定义来源

### 4. USER.md 补引用
- 「监控」后加 `（参见 HEARTBEAT.md）`

### 5. TOOLS.md 扩展
- 新增 §3 网络操作安全（来源检查/端口暴露/数据传输）

### 6. HEARTBEAT.md 补全
- 泛化「Clash」→「网络代理」
- 补充备份路径 `/mnt/g`
- 引用 AGENTS.md III.4

---

## 产出

| 版本 | 路径 | 用途 |
|------|------|------|
| 在线版 | `workspace/*.md` (7 文件) | OpenClaw 注入 |
| 离线版 | `workspace/athena-lite/` (3 文件) | 人类查阅 |
| 备份 | `/mnt/g/athena-core-backup/` + `/mnt/g/athena-lite-backup/` | 冷存储 |

---

## 关键决策

- Lint MD013/MD022/MD025/MD030/MD032/MD004 全部解决
- 7 文件交叉引用闭环：AGENTS↔TOOLS, AGENTS↔HEARTBEAT, USER→HEARTBEAT
- 合并 SOUL + IDENTITY 身份定义到 IDENTITY 单一来源
