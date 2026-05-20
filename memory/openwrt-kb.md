# OpenWrt / GL.iNet 知识库

## OpenWrt 版本与兼容性

| 版本 | Luci | 防火墙 | 包管理 |
|------|------|--------|--------|
| 18.06 | 纯 Lua | iptables | opkg |
| 19.07 / 21.02 | Lua→JS 过渡 | iptables | opkg |
| 22.03 / 23.05 / 24.10 | JS | nftables | opkg→apk |
| 25.12 / 26.04 | JS | nftables | apk |

**版本间不兼容，跨版本装包高风险。**

---

## GL.iNet 固件架构

```
芯片厂商 SDK（闭源驱动）
    ↓
OpenWrt 开源（Luci 界面）
    ↓
GL.iNet 内核（kmod）
    ↓
GL.iNet OUI 界面（绕过 Luci 直接操控闭源驱动）
```

- **OUI 与 Luci 存在冲突**，部分 OpenWrt 原生插件永久不可用：mwan3、UPnP、多拨等
- 内核固定 **5.4.2xx**
- 厂商 SDK 提供闭源 WiFi 驱动（MT7993 等），OpenWrt 原生无法直接适配

---

## 各厂 QSDK/SDK 对应版本

### 高通
| 芯片 | QSDK 版本 | 对应 OpenWrt |
|------|-----------|-------------|
| ipq5018 | `AU_LINUX_QSDK_NHSS.QSDK.12.2.R8` | 19.x |
| ipq53xx | `AU_LINUX_QSDK_NHSS.QSDK.12.5_TARGET_ALL.12.5.2783.2994` | 23.x |

QSDK 仓库：
- ipq5018: `repo init -u https://git.codelinaro.org/clo/qsdk/releases/manifest/qstak -b release -m AU_LINUX_QSDK_NHSS.QSDK.12.2.R8_TARGET_ALL.12.02.08.023.087.xml --repo-url=https://git.codelinaro.org/clo/tools/repo --repo-branch=qc-stable`
- ipq53xx: `repo init -u https://git.codelinaro.org/clo/qsdk/releases/manifest/qstak -b release -m AU_LINUX_QSDK_NHSS.QSDK.12.5_TARGET_ALL.12.5.2783.2994.xml --repo-url=https://git.codelinaro.org/clo/tools/repo --repo-branch=qc-stable`

### MTK
| 芯片 | 源码 | 对应 OpenWrt |
|------|------|-------------|
| mt798x（闭源） | `hanwckf/immortalwrt-mt798x` | 21.x |
| mt798x（开源） | `openwrt/openwrt` branch `openwrt-24.10` | 24.x |

### 其他
- ipq60xx: `Telecominfraproject/wlan-ap` v3.2.0 → OpenWrt 23.x

---

## 后装软件兼容规则

1. **优先使用相同源码编译的包**
2. 至少保证 **Luci 版本 + CPU 架构** 一致
3. **kmod 必须严格匹配内核版本 + 修改 hash**（如 kmod-oaf、kmod-inet-diag）
4. OpenWrt 24/25 的包装到 21/23 上大概率炸

---

## 第三方固件生态

| 固件 | 定位 |
|------|------|
| **OpenWrt 官方** | 纯开源，外国开发者主导，闭源驱动难提交 |
| **ImmortalWrt** | 中国特化版，fullcone 更开放，其他同 OP 官方 |
| **X-WRT** | OP 官改 + natflow 流控 |
| **iStoreOS** | 基于 OP 24.10，核心是 istore 独立包管理，Luci 兼容性烂，部分机型用闭源驱动 |
| **LEDE** | Lean 团队，高性能改动，带部分高通 NSS 支持，矿渣优化好 |
| **Kwrt / openwrt.ai** | ImageBuilder 打包，版本新但稳定性一般 |
| **QWRT** | Lean 闭源版，各机型独立魔改，版本不固定（从安卓内核到 18.06 都有） |

---

## 选型原则

| 需求 | 推荐 |
|------|------|
| 性能优先 | 闭源驱动支线固件 |
| 长期软件源 | OP/Imm 官方 Release 或 iStoreOS |
| 复杂网络（VLAN/Mesh） | 纯开源 OP |
| 稳定当路由器用 | **GL.iNet 官方固件** |
| 高通机型 | 少碰第三方，除非只做主路由 |

---

## 闭源驱动局限性
- UCI 操控不符合 OpenWrt 标准
- 第三方无法完整实现 Easymesh
- VLAN 可能不正常
- 部分方向硬件加速缺失

---

## 基础使用方法

```bash
opkg update                  # 更新软件源
opkg install <包名>          # 安装软件
opkg remove <包名>           # 卸载软件（Luci 主题崩溃恢复常用）

# 必备基础库
opkg install luci-lib-ipkg
opkg install luci-compat
```

---

## 常用插件安装

### 代理
```bash
# SSR-Plus
opkg install luci-i18n-ssr-plus-zh-cn

# PassWall
opkg install luci-i18n-passwall-zh-cn
# 加密内核（需自行检查安装，21.02 无原生 sing-box）
opkg install xray-core
opkg install sing-box
opkg install hysteria
opkg install trojan-plus
opkg install haproxy

# OpenClash（安装后需在界面内自更新）
opkg install luci-app-openclash
```

**注意**：nekobox、nikki、homeproxy、fehomo 因依赖限制，仅在 24.10 可能存在，21.02/23.05 不供应。

### iStore（仅 64 位 21.02-24.10）
```bash
# 主题（不推荐，占空间大）
opkg install luci-i18n-quickstart-zh-cn
opkg install luci-theme-argon

# 商店（推荐安装）
opkg install luci-app-store
```

### 测速
```bash
opkg install luci-i18n-homebox-zh-cn
# 注意：路由器自发包测速不准（尤其 WiFi），仅供测网线是否跌百兆
```

### 游戏加速器
```bash
# UU 加速器
opkg install uugamebooster
opkg install luci-i18n-uugamebooster-zh-cn

# 奇游加速器
opkg install qiyougamebooster
opkg install luci-i18n-qiyougamebooster-zh-cn
```

### Docker（仅 64 位）
```bash
opkg install docker dockerd docker-compose
opkg install luci-app-dockerman
opkg install luci-i18n-dockerman-zh-cn
```

---

## 内存/闪存资源速算

| 功能 | 闪存 | 内存 |
|------|------|------|
| 官方远程 | — | ~10 MB |
| 单个代理内核 | 10-30 MB | ~60 MB |
| OpenClash | — | 100-120 MB |
| Openlist | 35 MB | 50 MB 起步 |
| Docker 组件 | 75 MB | ≥100 MB |
| iStore 主题 | 10 MB | ~40 MB |
| AdGuardHome | 8 MB（列表） | ~50 MB |
| Tailscale / ZeroTier | 0（自带） | ~30 MB |
| USB 挂载共享 | — | ~30 MB（复制时更大） |
| 系统预留（流量/日志） | — | 30-60 MB |

### 机型参考
- **512 MB 机型**：剩 160-200 MB，开 1 个代理 + 1 个其他，不超过 3 个功能
- **1 GB 机型**：剩 600-700 MB，可多开
- **闪存不足**：用 USB 扩容，文件类软件缓存/目录指向 U 盘
- **想自由折腾**：先物理扩容内存
