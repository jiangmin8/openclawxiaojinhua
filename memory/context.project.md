---
title: 项目上下文与进度
version: 1.0
date: 2026-05-20
---

# 项目列表

> 雅典娜自动识别：状态标记 → 下一步 → 阻塞项。Subconscious Loop 关联扫描。

## 项目 1：RAX3000Me 远程刷机
- **状态：** 🔄 进行中
- **下一步：** 手机到现场，连 RAX3000Me WiFi，确认可达后按手册刷机
- **阻塞项：** 手机尚未到远程现场；DDR3/DDR4 内存版本未确认

## 项目 8：Ruflo 蜂群研究
- **状态：** ✅ 已完成
- **完成时间：** 2026-05-20 07:32

## 项目 9：mattpocock/skills 扫描
- **状态：** ✅ 已完成
- **完成时间：** 2026-05-20 07:32
- **结论：** 参考价值低，不深挖

## 项目 7：CrewAI Flow 引擎实现
- **状态：** ✅ 已完成
- **完成时间：** 2026-05-20 07:23
- **成果：** `tools/flow-engine.py` + `flows/` + 示例 YAML

## 项目 2：雅典娜进化升级
- **状态：** ✅ 已完成
- **完成时间：** 2026-05-20 04:30
- **成果：** Subconscious Loop + TokenJuice + Memory Tree + Archetypes — 15 文件，2 cron，5 原型库

## 项目 3：MCP 协议研究
- **状态：** ✅ 已完成
- **完成时间：** 2026-05-20 06:53

## 项目 4：CrewAI 编排模式研究
- **状态：** ✅ 已完成
- **完成时间：** 2026-05-20 06:53

## 项目 5：agent-skills 技能模式研究
- **状态：** ✅ 已完成
- **完成时间：** 2026-05-20 07:04

## 项目 6：CloakBrowser 隐身浏览器研究
- **状态：** ✅ 已完成
- **完成时间：** 2026-05-20 07:04

---

# RAX3000Me 远程刷机 — 操作手册

## 设备信息

| 属性 | 值 |
|:---|:---|
| 型号 | CMCC RAX3000Me |
| 芯片 | MT7981B |
| 内存 | 512MB (**DDR3/DDR4 待确认** ⚠️ 刷错 uboot = 砖) |
| 闪存 | FM25S01A (FUDANmicro NAND) |
| SN | 5D1121000924641 |
| MAC | C0:2D:2E:C4:6E:C1 |
| 原厂固件 | RAX3000M-MTK.ZD.02 |
| 管理员密码 | `/H3dxznit0` |
| Telnet IP | 192.168.10.1（解锁后，无需账号密码） |

## 远程链路

```
WSL2 → Tailscale(100.66.242.48) → 荣耀畅玩60M ADB → WiFi → RAX3000Me
```

## 文件清单

| 文件 | 用途 | PC位置 | 手机位置 |
|:---|:---|:---|:---|
| `cfg_import_config_file_new.conf` | Telnet解锁配置 | ✅ | ✅ |
| `20250318_RAX3000Me-HY-factory.bin` | 工厂固件(16M) | ✅ | ✅ |
| `20250318_RAX3000Me-HY-sysupgrade.bin` | 升级固件(15M) | ✅ | `/mnt/g/` |
| `20250415_RAX3000me-nand-ddr3_HY_uboot.bin` | DDR3 Uboot(248K) ⚠️ | ✅ | ✅ |
| `mt7981_cmcc_rax3000m-fip-fixed-parts.bin` | 原版FIP(737K) | ✅ | ✅ |
| `http_server.sh` | 手机HTTP服务 | — | ✅ |

## 刷机步骤

### 第零步：前置确认
```bash
adb shell "ip route | grep default"
adb shell "ping -c2 192.168.10.1"
```

### 第一步：解锁 Telnet
1. 手机浏览器访问 `192.168.1.1`，登录密码 `/H3dxznit0`
2. 配置管理 → 导入 `cfg_import_config_file_new.conf`
3. 重启后 IP 变为 192.168.10.1

### 第二步：确认 DDR 版本 ⚠️
```bash
dmesg | grep -i ddr
cat /proc/mtd | grep FIP
```

### 第三步：刷 Uboot
```bash
wget -P /tmp http://<手机IP>:8080/<uboot文件>.bin
mtd write /tmp/<uboot文件>.bin FIP
```

### 第四步：刷 Factory
- 手机设静态 IP 192.168.1.2，RESET 进 uboot recovery
- 浏览器 192.168.1.1 上传 factory.bin

### 第五步：刷 Sysupgrade
- DHCP 自动获取，OpenWrt 界面升级 sysupgrade.bin

### 第六步：装 Tailscale
```bash
opkg update && opkg install tailscale && tailscale up
```

## 翻车预案

| 情况 | 处理 |
|:---|:---|
| 配置导入无效 | ZD.02 在免拆列表，多次重启尝试 |
| DDR4 内存 | 停止刷 uboot，用原版 FIP |
| Uboot 刷坏 | RESET 10s 进 recovery |
| Factory 无限重启 | RESET 进 uboot recovery |
| 远程链路断 | 刷完第一时间装 Tailscale |
