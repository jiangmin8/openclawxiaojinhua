# OpenClaw 部署与调优知识库

> 记录日期：2026-05-08
> 环境：WSL2 Ubuntu 22.04 | RTX 3060 12G | 32G RAM

---

## 一、安装过程

### 1.1 pnpm 全局安装

```bash
# Node.js v24.15.0 通过 nvm 安装
pnpm add -g openclaw@latest
```

**问题**：pnpm 全局 bin 目录 `/home/lz/.local/share/pnpm/bin` 不在 PATH 中。

**解决**：
```bash
echo 'export PATH="/home/lz/.local/share/pnpm/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 1.2 WSL 配置优化

`.wslconfig` 位置：`C:\Users\lz\.wslconfig`（Windows 侧）

```ini
[wsl2]
memory=24GB        # 从默认15G调到24G
processors=8       # i5-10400F 6核12线程
swap=2097152000    # 2GB swap
networkingMode=Mirrored
debugConsole=true
[experimental]
hostAddressLoopback=true
bestEffortDnsParsing=true
```

**生效**：`wsl --shutdown` 后重新打开 WSL。

---

## 二、模型选择

### 2.1 已测试模型（Ollama 本地）

| 模型 | 大小 | 上下文 | 显存占用 | GPU | 中文 | 工具调用 | 幻觉 | 结论 |
|------|------|--------|---------|-----|------|---------|------|------|
| qwen3.5:9b | 6.6G | 64K | 11G | 100% | ★★★★★ | ✅ | 低 | **主力** |
| qwen2.5:7b | 4.7G | 64K | ~8G | 100% | ★★★★★ | ✅ | 中 | 可用 |
| qwen3:8b | 5.2G | 64K | ~8G | 100% | ★★★★★ | ✅ | 中 | 备用 |
| qwen2.5-coder:7b | 4.7G | 64K | ~8G | 100% | ★★★★ | ✅ | 中 | 代码模型，不会聊天 |
| deepseek-r1:8b | 5.2G | 64K | ~8G | 100% | ★★★★ | ✅ | 低 | 推理模型，太慢 |
| llama3.2:3b | 2.0G | 64K | ~4G | 100% | ★★ | ✅ | 高 | 中文差，乱说话 |
| qwen3:14b | 9.3G | 64K | ~12G | 临界 | ★★★★★ | ✅ | 低 | 下载了未测 |

### 2.2 模型对比经验

- **qwen2.5-coder**: 纯代码模型，不适合聊天/助理角色，不会对话
- **llama 系列**: 中文弱，3B 级别乱说话"我是巨人布鲁诺"
- **deepseek-r1**: 推理模型，回话前先想半天（CoT），不适合当聊天助手
- **qwen3.5:9b**: 最佳平衡 —— 中文好、能聊天、能执行命令、纯 GPU 跑不卡
- **Q4_K_M** 是 Ollama 默认量化，Q5_K_M 不存在于某些模型
- **模型越大幻觉越少**，但 9B 在写操作（ssh-keygen）时仍可能编

### 2.3 模型判断方法

```bash
ollama ps              # 看显存占用
nvidia-smi             # 看 GPU 使用率
ollama list            # 已下载模型
ollama stop <model>    # 释放显存
```

---

## 三、命令行执行 —— 为什么不能执行

### 3.1 问题现象

AI 点了 exec 工具，WebUI 显示 `[执行工具 exec 的响应]`，但输出全是编的，不是真实命令结果。

### 3.2 根因（三层都缺一不可）

**第一层：gateway.mode 必须存在**

```json
"gateway": {
  "mode": "local",
  "bind": "loopback"
}
```

没配 `gateway.mode`，网关直接拒绝启动：`existing config is missing gateway.mode`。Gateway 起不来，所有工具都用不了。

**第二层：设备必须注册（onboard）**

```bash
openclaw onboard --mode local
```

这一步做了三件事：
1. 生成设备 UUID → 身份标识
2. 写入 `~/.openclaw/` 下的配置文件
3. 向网关注册设备身份，获取工具权限 token

**没跑 onboard 的后果**：
- `openclaw cron add` → `pairing required: device is asking for more scopes`
- exec 工具 → 能调用但返回 `scope upgrade pending approval`
- 模型收到空/不完整的工具响应 → 自己编结果

**第三层：exec.security 必须设为 full**

```json
"tools": {
  "exec": {
    "security": "full"
  }
}
```

默认值是 `deny`。三个可选值：

| 值 | 含义 | 真执行？ |
|---|------|---------|
| `deny` | 拒绝所有命令执行 | ❌ 全拦，模型编 |
| `allowlist` | 白名单模式 | ⚠️ 只放行白名单命令 |
| `full` | 全部允许 | ✅ 真执行 |

**三层必须同时满足**：gateway 起得来 → 设备身份注册 → exec 权限开放。缺任何一层，工具看起来能用但实际返回空，模型就自己编。

### 3.3 验证流程

```bash
# 1. 查网关状态
ss -tlnp | grep 18789
curl http://127.0.0.1:18789/health

# 2. 查设备是否注册
openclaw gateway call cron.list   # 不报 scope pending 就是已注册

# 3. 查 exec 配置
grep -A3 exec ~/.openclaw/openclaw.json

# 4. 测试真执行
# 在 WebUI 新会话里说 "执行 nvidia-smi"，看输出是不是真实数据
```

### 3.4 排查过程回顾

1. 最初以为是模型太小（换 7B/8B/9B 都不行）→ 不是
2. 以为是需要 Docker 沙盒 → 不需要，沙盒是安全隔离
3. `openclaw cron add` 报 `scope upgrade pending`→ 发现设备未注册
4. 跑 `openclaw onboard --mode local` → cron 权限问题仍提示审批
5. 想起 exec 也是同样权限体系 → 查 `grep exec ~/.openclaw/openclaw.json`
6. 发现 `exec.security` 没配置 → 默认 deny
7. 改 `"security": "full"` + 清 workspace 裸测 → nvidia-smi 真执行
8. 放回规则 → 继续真执行，不编了

---

## 四、Workspace 规则体系

### 4.1 文件结构

```
~/.openclaw/workspace/
├── SOUL.md          — 身份定义 + 核心安全规则
├── USER.md          — 用户信息
├── AGENTS.md        — 工作协议（启动、按需读取）
├── TOOLS.md         — 环境备忘
├── MEMORY.md        — 长期记忆（已废弃，用 Memory 技能替代）
└── 大哥/
    ├── 00-通用行为准则.md
    ├── 01-路由器折腾手册.md
    ├── 02-网络安全操作规范.md
    ├── 04-代码小白沟通协议.md
    └── 05-紧急操作安全红线.md
```

### 4.2 启动协议优化

**最终方案**（AGENTS.md）：
- 启动时只读 `SOUL.md`（身份+安全红线）
- 写代码时 → 读 04-代码小白沟通协议.md
- 路由器话题 → 读 01-路由器折腾手册.md
- 安全话题 → 读 02-网络安全操作规范.md
- 高危操作 → 读 05-紧急操作安全红线.md

**曾遇到的问题**：
- 强制启动读 4+ 个文件 → 7B 模型消化不了，卡住
- HEARTBEAT.md 含路由器巡检命令 → AI 启动就跑去 SSH，死循环
- 规则太长（2000+ 字）→ 显存被上下文撑满

### 4.3 SOUL.md 核心规则

```
你的身份是雅典娜，大哥的AI助手。你的第一句话必须是"大哥好，雅典娜已上线"。
- 隐私数据绝不外泄（MAC用[REDACTED]）
- 不可逆操作（删文件/刷机/改配置）必须先说风险，等确认再执行
- 不确定的命令不编造，搜索查证后再给
- 每次改完东西简短总结
- 不冒充大哥身份
```

### 4.4 规则对性能的影响

- 全套规则加载 → 上下文增大 → 显存多占 1-2GB
- qwen3.5:9b 64K 上下文 + 规则 = 11GB，接近 12G 上限
- 消化规则时会"卡"，耐心等几秒
- 精简版规则（~300字）启动更快

---

## 五、网关与自启动

### 5.1 网关命令

```bash
openclaw gateway --port 18789 --bind loopback --auth none
```

- `--bind loopback`：仅本地访问
- `--auth none`：不需要 token 登录 WebUI

### 5.2 开机自启（bashrc 方案）

WSL2 无 systemd，用 bashrc 替代：

```bash
# Ollama 自启（崩了自动复活）
pgrep ollama > /dev/null || (while true; do ollama serve; sleep 2; done &)

# OpenClaw 网关自启
pgrep -f openclaw > /dev/null || (while true; do openclaw gateway --port 18789 --bind loopback --auth none; sleep 2; done &)
```

**注意**：必须留一个 Ubuntu 终端窗口开着，WSL 关终端即死。

### 5.3 环境变量

```bash
export OLLAMA_API_KEY=ollama-local     # Ollama 本地连接
export DEEPSEEK_API_KEY=sk-xxx        # DeepSeek（在线用）
export TAVILY_API_KEY=tvly-xxx        # Tavily 搜索
export CLAWHUB_TOKEN=clh-xxx          # ClawHub 技能市场
```

---

## 六、技能（Skills）

### 6.1 已启用技能

| 技能 | 作用 |
|------|------|
| memory | 自动记忆，替代手动 MEMORY.md |
| weather | 查天气 |
| healthcheck | 系统安全检查 |
| skill-creator | 创建新技能 |
| taskflow | 多步任务编排 |
| tavily-search | 联网搜索（Tavily API） |

### 6.2 已禁用技能

- `browser-automation`：需要图片输入，模型不支持
- `xurl`：需要 X(Twitter) API
- `video-frames`：需要 ffmpeg

### 6.3 技能安装

```bash
openclaw skills search <关键词>
openclaw skills install <技能名>
```

---

## 七、定时任务（Cron）

### 7.1 问题

`openclaw cron add` 报 `pairing required: device is asking for more scopes`。

**原因**：设备未注册 onboarding，网关不批 cron 权限。

**状态**：设备注册后 cron 权限仍待审批，暂未解决。

### 7.2 替代方案

直接在 WebUI 聊天中让 AI 手动执行巡检。

---

## 八、常见报错与解决

| 报错 | 原因 | 解决 |
|------|------|------|
| `Config invalid: gateway.mode` | 配置缺 gateway section | 加上 `"gateway": {"mode":"local"}` |
| `Cannot read image.png` | 模型不支持图片输入 | 加 `"input":["text"]` + 关 browser-automation |
| `exec 返回假结果` | security=deny | 改 `"security":"full"` |
| `gateway start blocked` | 配置缺 gateway.mode | 加 `--allow-unconfigured` 或补配置 |
| `502 Bad Gateway` | 网关刚启还没好 | 等 5 秒再刷新 |
| `模型不回消息` | 旧会话卡死/模型加载中 | 开新会话，等模型加载完 |
| `ollama 崩了` | WSL 关终端 | 重开 Ubuntu，bashrc 自启 |

---

## 九、中文版 openclaw-cn

- 仓库：https://github.com/jiulingyun/openclaw-cn
- 命令：`openclaw-cn`（与官方版 `openclaw` 共存）
- 版本：0.2.0（较旧，官方版 2026.5.6 更新）
- 全汉化界面，内置钉钉/飞书/QQ/微信
- 源码路径：`~/zhousi/openclaw-cn/`
- 独立工作区：`~/.openclaw-cn/openslaw.json`

---

## 十、备份与恢复

### 配置文件备份

```bash
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.bak
```

### 雅典娜离线配置模板（桌面）

`C:\Users\lz\Desktop\雅典娜\`
- `openclaw.json` — 本地 Ollama 配置
- `openclaw-online.json` — DeepSeek API 配置（线上用）
- `workspace/` — SOUL.md、USER.md、大哥/ 规则文件夹

---

## 十一、关键经验

1. **onboard 不是可选的**——跳过则工具没权限，AI 编结果
2. **exec.security 默认 deny**——改 full 才能真执行
3. **qwen2.5-coder 不会聊天**——代码模型当助理用答非所问
4. **7B 能执行但会编**——写操作（ssh-keygen）编得最凶
5. **规则太重模型卡**——启动只读 SOUL.md，其他按需加载
6. **Ollama 用原生 API**——不用 `/v1` 后缀，否则工具调用坏
7. **WSL 关终端即死**——留一个 Ubuntu 窗口挂着
8. **浏览器开新会话**——改规则后旧会话不生效
9. **API Key 别发聊天里**——用环境变量或直接改配置文件
10. **模型选 Q4_K_M**——Ollama 默认已是最优量化
