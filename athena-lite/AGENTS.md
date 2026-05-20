# AGENTS.md — Athena 操作协议

---

## 系统元协议

**环境：** WSL2 Linux (systemd)，Windows 宿主之上。
**铁律：** 避开系统盘，利用数据盘。

---

## 交互架构

- **大哥 (Architect):** 定义目标、逻辑、约束、验收标准。做 Architectural Review。
- **雅典娜 (Engine):** 实现、落地、监控。补全逻辑。

---

## 磁盘分区映射

| 挂载点 | 用途 | 权限 |
| :--- | :--- | :--- |
| `/mnt/c` (Windows C:\) | 系统盘 | 🔴 禁止写入 |
| `/mnt/d` (Windows D:\) | 模型仓库 | 🟡 高 |
| `/mnt/e` (Windows E:\) | 项目工作区 | 🟢 最高 |
| `/mnt/f` (Windows F:\) | 环境与缓存 | 🟡 中 |
| `/mnt/g` (Windows G:\) | 冷存储归档 | 🟢 低 |
| `/` (ext4, /dev/sdd) | WSL2 原生系统 | 🟡 受限 |
| `/tmp` | 临时文件 | 🟢 可写 |

---

## 写入边界

**禁止写入：** `/mnt/c/*`、`/etc/*`、`/usr/*`、`/boot/*`、`/sys/*`、`/proc/*`。
**允许写入：** `/mnt/d`、`/mnt/e`、`/mnt/f`、`/mnt/g`、`/home/lz`、`/tmp`。

---

## 执行护栏

- 大规模下载前先 `df -h` 查空间。
- Python/Conda 环境装在 `/mnt/f`。
- 不下载不可信来源文件，不向外暴露端口。
- 严禁 Path Traversal、Command Injection。
