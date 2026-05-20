# 🧰 TOOLKIT — 雅典娜工具目录

> 每次会话启动时加载。所有工具须在此注册。
> 新增工具：在下方表格加一行 + 脚本放 tools/ 目录。

## 工具索引

### 系统运维

| 工具 | 路径 | 用途 | 用法 |
|------|------|------|------|
| health-check | /mnt/e/scripts/health-check.sh | 系统健康报告 | bash /mnt/e/scripts/health-check.sh |
| wsl-reconnect | tools/wsl-reconnect.sh | WSL断线重连+服务保活 | bash tools/wsl-reconnect.sh & |
| wsl-tunnel | tools/wsl-tunnel.sh | 反向SSH隧道 | bash tools/wsl-tunnel.sh & |
| athena-backup | scripts/athena-backup.sh | 备份workspace | bash scripts/athena-backup.sh |
| athena-boot | scripts/athena-boot.sh | 启动自检 | bash scripts/athena-boot.sh |
| verify-constraints | scripts/verify-constraints.sh | 约束体系自检 | bash scripts/verify-constraints.sh |

### 网络

| 工具 | 路径 | 用途 | 用法 |
|------|------|------|------|
| network-scout | tools/network_scout.py | 局域网扫描+Web发现 | python3 tools/network_scout.py 192.168.1 |
| router-ctl | tools/router_ctl.py | 路由器管理 | python3 tools/router_ctl.py IP info |
| openwrt-setup | tools/openwrt_first_setup.sh | OpenWrt一键配置 | bash tools/openwrt_first_setup.sh |

### 安全

| 工具 | 路径 | 用途 | 用法 |
|------|------|------|------|
| security-audit | scripts/athena-security-audit.sh | 安全审计 | bash scripts/athena-security-audit.sh |
| guard-exec | scripts/guard-exec.sh | 命令拦截器 | 自动调用 |
| athena-init-memory | scripts/athena-init-memory.sh | 初始化知识库 | bash scripts/athena-init-memory.sh |

## 工具规范

每个工具脚本头部必须包含自描述注释（参考 _template.sh）。
每个工具必须支持 --help 输出用法。

## 添加新工具

1. 在 tools/ 下创建脚本（参考 _template.sh）
2. 在本文件对应分类表格加一行
3. 完成。下次会话自动发现。
