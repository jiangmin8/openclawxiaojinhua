# OpenClaw故障

**chat_id**: `19df5ca4-a0e2-85fe-8000-0934bcde750e`  |  **消息數**: 10

---

### 🤖 Kimi
*2026-05-05T01:59:01.563860Z*

这个看起来是 OpenClaw 的内部路由配置，说明 `openclaw-extra` skill 被 disabled 了，`acp-router` 负责把请求路由到不同的 agent runtime。

不过你贴这个是有什么具体问题吗？是想：
1. **启用 `openclaw-extra`**？
2. **继续排查之前 `openclaw-gateway` 服务 inactive 的问题**？
3. **其他配置相关的事**？

先把上下文对齐一下，不然我不知道该往哪边处理。

---

### 🧑 用戶
*2026-05-05T01:59:01.563854Z*

acp-router
Route plain-language requests for Pi, Claude Code, Cursor, Copilot, OpenClaw ACP, OpenCode, Gemini CLI, Qwen, Kiro, Kimi, iFlow, Factory Droid, Kilocode, or explicit ACP harness work into either OpenClaw ACP runtime sessions or direct acpx-driven sessions ("telephone game" flow). For coding-agent thread requests, read this skill first, then use only `sessions_spawn` for thread creation. Codex chat binding defaults to the native Codex app-server plugin unless ACP is explicit or background spawn needs ACP.
openclaw-extra
blocked
disabled
Reason: disabled

---

### 🤖 Kimi
*2026-05-05T01:56:28.927129Z*

这个 `TOOLS.md` 看起来是 OpenClaw 的本地配置说明，用来记录你环境的特有信息（摄像头、SSH 别名、TTS 偏好等）。

不过你刚贴这个，是打算往里面加内容，还是让我帮你基于现有日志继续排查服务问题？

如果是继续排查，先跑一下这两个命令：

```bash
sudo systemctl status openclaw-gateway
dmesg | grep -i "killed\|oom\|out of memory"
```

我需要确认当前服务状态和 OOM 记录，才能决定是修内存限制还是网络时序，或者两个一起修。

---

### 🧑 用戶
*2026-05-05T01:56:28.927125Z*

# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.

## Related

- [Agent workspace](/concepts/agent-workspace)

---

### 🤖 Kimi
*2026-05-05T01:40:32.352488Z*

日志看得很清楚了，两个问题：

**凌晨（02:41、02:43）**：`status=9/KILL`，被 SIGKILL 强制终止。前面 `cpuCoreRatio=0.993`、`eventLoopUtilization=0.92`，CPU 被打满，事件循环阻塞 7-10 秒，大概率是 **OOM 被系统 kill**。WSL2 配了 8GB 内存，OpenClaw 吃满后系统直接杀进程。

**今早开机（09:39）**：服务正常启动了，但卡在 QQ Bot `getaddrinfo EAI_AGAIN bots.qq.com` —— **DNS 解析失败**，说明开机时网络还没就绪。

---

先确认当前状态和 OOM：

```bash
sudo systemctl status openclaw-gateway
dmesg | grep -i "killed\|oom\|out of memory"
```

如果 `dmesg` 里有 OOM 记录，那就是内存问题。两个方向一起修：

**1. 防 OOM（如果内存不够）**

给 systemd 服务加内存限制和 OOM 策略，避免系统直接杀：

```bash
sudo systemctl edit openclaw-gateway
```

加：
```ini
[Service]
MemoryMax=6G
MemorySwapMax=1G
OOMScoreAdjust=-500
```

**2. 修开机网络时序**

同样编辑服务，让等网络就绪再启动：

```bash
sudo systemctl edit openclaw-gateway
```

加：
```ini
[Unit]
After=network-online.target
Wants=network-online.target
```

然后重载并重启：
```bash
sudo systemctl daemon-reload
sudo systemctl restart openclaw-gateway
```

---

你先跑 `dmesg` 和 `systemctl status` 看看现在到底什么情况？

---

### 🧑 用戶
*2026-05-05T01:40:32.352485Z*

lz@PC-20260425YEDW:~$ sudo journalctl -u openclaw-gateway -n 50 --no-pager
May 05 02:35:04 PC-20260425YEDW bash[1568369]: 2026-05-05T02:35:04.801+08:00 [agent/embedded] [trace:embedded-run] prep stages: runId=f0b01a9a-6d1c-4b0a-b9cd-53901341aa44 sessionId=24af2648-826d-4657-9fa4-201dd44c8f89 phase=stream-ready totalMs=21971 stages=workspace-sandbox:4ms@4ms,skills:0ms@4ms,core-plugin-tools:7330ms@7334ms,bootstrap-context:35ms@7369ms,bundle-tools:1505ms@8874ms,system-prompt:4577ms@13451ms,session-resource-loader:1630ms@15081ms,agent-session:4ms@15085ms,stream-setup:6886ms@21971ms
May 05 02:35:17 PC-20260425YEDW bash[1568369]: 2026-05-05T02:35:17.728+08:00 [diagnostic] liveness warning: reasons=event_loop_delay interval=28s eventLoopDelayP99Ms=156.2 eventLoopDelayMaxMs=10368.3 eventLoopUtilization=0.703 cpuCoreRatio=0.752 active=1 waiting=0 queued=1
May 05 02:36:01 PC-20260425YEDW bash[1568369]: 2026-05-05T02:36:01.646+08:00 [memory] chunks_vec not updated — sqlite-vec unavailable. Vector recall degraded. Further duplicate warnings suppressed.
May 05 02:36:40 PC-20260425YEDW bash[1568369]: 2026-05-05T02:36:40.702+08:00 [agent/embedded] [trace:embedded-run] prep stages: runId=e94a5f22-b535-475d-8f74-947d11f12605 sessionId=24af2648-826d-4657-9fa4-201dd44c8f89 phase=stream-ready totalMs=23066 stages=workspace-sandbox:5ms@5ms,skills:0ms@5ms,core-plugin-tools:4625ms@4630ms,bootstrap-context:38ms@4668ms,bundle-tools:1382ms@6050ms,system-prompt:6770ms@12820ms,session-resource-loader:3451ms@16271ms,agent-session:3ms@16274ms,stream-setup:6792ms@23066ms
May 05 02:37:45 PC-20260425YEDW bash[1568369]: 2026-05-05T02:37:45.321+08:00 [diagnostic] liveness warning: reasons=event_loop_delay interval=34s eventLoopDelayP99Ms=126.6 eventLoopDelayMaxMs=8493.5 eventLoopUtilization=0.595 cpuCoreRatio=0.629 active=0 waiting=0 queued=0
May 05 02:38:00 PC-20260425YEDW bash[1568369]: 2026-05-05T02:38:00.010+08:00 [agent/embedded] [trace:embedded-run] prep stages: runId=6bd8918c-86c5-4d46-8770-858d0d9a2f28 sessionId=24af2648-826d-4657-9fa4-201dd44c8f89 phase=stream-ready totalMs=21939 stages=workspace-sandbox:3ms@3ms,skills:0ms@3ms,core-plugin-tools:7237ms@7240ms,bootstrap-context:41ms@7281ms,bundle-tools:1469ms@8750ms,system-prompt:6861ms@15611ms,session-resource-loader:0ms@15048ms,agent-session:1ms@15049ms,stream-setup:6890ms@21939ms
May 05 02:39:33 PC-20260425YEDW bash[1568369]: 2026-05-05T02:39:33.786+08:00 [agent/embedded] [trace:embedded-run] prep stages: runId=74dae445-09b4-4e2f-b801-d88e2953fd02 sessionId=24af2648-826d-4657-9fa4-201dd44c8f89 phase=stream-ready totalMs=21991 stages=workspace-sandbox:11ms@11ms,skills:0ms@11ms,core-plugin-tools:7234ms@7245ms,bootstrap-context:34ms@7279ms,bundle-tools:1922ms@9201ms,system-prompt:4386ms@13587ms,session-resource-loader:1644ms@15231ms,agent-session:1ms@15232ms,stream-setup:6759ms@21991ms
May 05 02:41:03 PC-20260425YEDW bash[1568369]: 2026-05-05T02:41:03.679+08:00 [diagnostic] liveness warning: reasons=event_loop_delay,cpu interval=29s eventLoopDelayP99Ms=7201.6 eventLoopDelayMaxMs=7323.3 eventLoopUtilization=0.92 cpuCoreRatio=0.993 active=1 waiting=0 queued=2
May 05 02:41:12 PC-20260425YEDW bash[1568369]: 2026-05-05T02:41:12.282+08:00 [agent/embedded] [trace:embedded-run] prep stages: runId=ce1b5fbe-8cb4-48e8-a099-15cf505e092f sessionId=24af2648-826d-4657-9fa4-201dd44c8f89 phase=stream-ready totalMs=22260 stages=workspace-sandbox:9ms@9ms,skills:1ms@10ms,core-plugin-tools:4868ms@4878ms,bootstrap-context:408ms@5286ms,bundle-tools:1481ms@6767ms,system-prompt:6889ms@13656ms,session-resource-loader:1655ms@15311ms,agent-session:3ms@15314ms,stream-setup:6946ms@22260ms
May 05 02:41:22 PC-20260425YEDW systemd[1]: openclaw-gateway.service: Main process exited, code=killed, status=9/KILL
May 05 02:41:22 PC-20260425YEDW systemd[1]: openclaw-gateway.service: Failed with result 'signal'.
May 05 02:41:22 PC-20260425YEDW systemd[1]: openclaw-gateway.service: Consumed 12min 10.338s CPU time.
May 05 02:41:25 PC-20260425YEDW systemd[1]: openclaw-gateway.service: Scheduled restart job, restart counter is at 2.
May 05 02:41:25 PC-20260425YEDW systemd[1]: Stopped OpenClaw Gateway.
May 05 02:41:25 PC-20260425YEDW systemd[1]: openclaw-gateway.service: Consumed 12min 10.338s CPU time.
May 05 02:41:25 PC-20260425YEDW systemd[1]: Started OpenClaw Gateway.
May 05 02:41:31 PC-20260425YEDW bash[1569289]: 2026-05-05T02:41:31.874+08:00 [gateway] removed stale session lock: /home/lz/.openclaw/agents/main/sessions/24af2648-826d-4657-9fa4-201dd44c8f89.jsonl.lock (dead-pid)
May 05 02:41:31 PC-20260425YEDW bash[1569289]: 2026-05-05T02:41:31.899+08:00 [main-session-restart-recovery] marked 1 interrupted main session(s) from stale transcript locks
May 05 02:41:32 PC-20260425YEDW bash[1569289]: 2026-05-05T02:41:32.781+08:00 [ws] closed before connect conn=fca1ac16-9fcb-4ffc-9dd6-c5ad72df8ff8 peer=127.0.0.1:45525->127.0.0.1:18789 remote=127.0.0.1 fwd=n/a origin=n/a host=127.0.0.1:18789 ua=n/a code=1013 reason=gateway starting
May 05 02:41:37 PC-20260425YEDW bash[1569289]: 2026-05-05T02:41:37.868+08:00 [main-session-restart-recovery] marked interrupted main session failed: agent:main:main (transcript tail is not resumable)
May 05 02:41:57 PC-20260425YEDW bash[1569289]: 2026-05-05T02:41:57.898+08:00 [diagnostic] liveness warning: reasons=event_loop_delay interval=27s eventLoopDelayP99Ms=376.2 eventLoopDelayMaxMs=8023.7 eventLoopUtilization=0.524 cpuCoreRatio=0.62 active=0 waiting=0 queued=0
May 05 02:43:12 PC-20260425YEDW bash[1569289]: 2026-05-05T02:43:12.683+08:00 [agent/embedded] [trace:embedded-run] prep stages: runId=86f4953a-2a11-4baf-a477-ddd10118f52c sessionId=24af2648-826d-4657-9fa4-201dd44c8f89 phase=stream-ready totalMs=22116 stages=workspace-sandbox:36ms@36ms,skills:1ms@37ms,core-plugin-tools:5043ms@5080ms,bootstrap-context:17ms@5097ms,bundle-tools:1553ms@6650ms,system-prompt:7030ms@13680ms,session-resource-loader:1665ms@15345ms,agent-session:4ms@15349ms,stream-setup:6767ms@22116ms
May 05 02:43:25 PC-20260425YEDW systemd[1]: openclaw-gateway.service: Main process exited, code=killed, status=9/KILL
May 05 02:43:25 PC-20260425YEDW systemd[1]: openclaw-gateway.service: Failed with result 'signal'.
May 05 02:43:25 PC-20260425YEDW systemd[1]: openclaw-gateway.service: Consumed 1min 8.423s CPU time.
May 05 02:43:30 PC-20260425YEDW systemd[1]: openclaw-gateway.service: Scheduled restart job, restart counter is at 3.
May 05 02:43:30 PC-20260425YEDW systemd[1]: Stopped OpenClaw Gateway.
May 05 02:43:30 PC-20260425YEDW systemd[1]: openclaw-gateway.service: Consumed 1min 8.423s CPU time.
May 05 02:43:30 PC-20260425YEDW systemd[1]: Started OpenClaw Gateway.
May 05 02:43:37 PC-20260425YEDW bash[1569689]: 2026-05-05T02:43:37.490+08:00 [gateway] removed stale session lock: /home/lz/.openclaw/agents/main/sessions/24af2648-826d-4657-9fa4-201dd44c8f89.jsonl.lock (dead-pid)
May 05 02:43:37 PC-20260425YEDW bash[1569689]: 2026-05-05T02:43:37.511+08:00 [main-session-restart-recovery] marked 1 interrupted main session(s) from stale transcript locks
May 05 02:43:43 PC-20260425YEDW bash[1569689]: 2026-05-05T02:43:43.517+08:00 [main-session-restart-recovery] marked interrupted main session failed: agent:main:main (transcript tail is not resumable)
May 05 02:44:03 PC-20260425YEDW bash[1569689]: 2026-05-05T02:44:03.591+08:00 [diagnostic] liveness warning: reasons=event_loop_delay interval=28s eventLoopDelayP99Ms=376.7 eventLoopDelayMaxMs=8111.8 eventLoopUtilization=0.525 cpuCoreRatio=0.611 active=0 waiting=0 queued=0
May 05 02:45:06 PC-20260425YEDW bash[1569689]: 2026-05-05T02:45:06.810+08:00 [agent/embedded] [trace:embedded-run] prep stages: runId=0d46a681-90ed-486e-ae84-965d26ea5d1f sessionId=24af2648-826d-4657-9fa4-201dd44c8f89 phase=stream-ready totalMs=22019 stages=workspace-sandbox:25ms@25ms,skills:1ms@26ms,core-plugin-tools:7316ms@7342ms,bootstrap-context:20ms@7362ms,bundle-tools:1537ms@8899ms,system-prompt:4605ms@13504ms,session-resource-loader:1643ms@15147ms,agent-session:5ms@15152ms,stream-setup:6867ms@22019ms
May 05 02:46:26 PC-20260425YEDW bash[1569689]: 2026-05-05T02:46:26.198+08:00 [diagnostic] liveness warning: reasons=event_loop_delay interval=31s eventLoopDelayP99Ms=39.4 eventLoopDelayMaxMs=7264.5 eventLoopUtilization=0.62 cpuCoreRatio=0.685 active=1 waiting=0 queued=1
May 05 02:46:43 PC-20260425YEDW bash[1569689]: 2026-05-05T02:46:43.217+08:00 [agent/embedded] [trace:embedded-run] prep stages: runId=8d46a3fa-1db0-4714-90f2-db16d38bbbf1 sessionId=24af2648-826d-4657-9fa4-201dd44c8f89 phase=stream-ready totalMs=21860 stages=workspace-sandbox:5ms@5ms,skills:0ms@5ms,core-plugin-tools:4835ms@4840ms,bootstrap-context:392ms@5232ms,bundle-tools:1455ms@6687ms,system-prompt:6776ms@13463ms,session-resource-loader:1625ms@15088ms,agent-session:3ms@15091ms,stream-setup:6769ms@21860ms
May 05 02:49:08 PC-20260425YEDW bash[1569689]: 2026-05-05T02:49:08.531+08:00 [agent/embedded] [trace:embedded-run] startup stages: runId=4306b3cc-cacb-46cd-b43f-5794f61218da sessionId=24af2648-826d-4657-9fa4-201dd44c8f89 phase=attempt-dispatch totalMs=10686 stages=workspace:1ms@1ms,runtime-plugins:2ms@3ms,hooks:0ms@3ms,model-resolution:3466ms@3469ms,auth:3029ms@6498ms,context-engine:1ms@6499ms,attempt-dispatch:4187ms@10686ms
May 05 02:49:15 PC-20260425YEDW bash[1569689]: 2026-05-05T02:49:15.651+08:00 [diagnostic] liveness warning: reasons=event_loop_delay interval=29s eventLoopDelayP99Ms=73.7 eventLoopDelayMaxMs=8040.5 eventLoopUtilization=0.67 cpuCoreRatio=0.7 active=1 waiting=0 queued=1
May 05 02:49:16 PC-20260425YEDW systemd[1]: Stopping OpenClaw Gateway...
May 05 02:49:24 PC-20260425YEDW systemd[1]: openclaw-gateway.service: Deactivated successfully.
May 05 02:49:24 PC-20260425YEDW systemd[1]: Stopped OpenClaw Gateway.
May 05 02:49:24 PC-20260425YEDW systemd[1]: openclaw-gateway.service: Consumed 2min 23.658s CPU time.
-- Boot b6bf01553b93413395bf805f77453363 --
May 05 09:39:20 PC-20260425YEDW systemd[1]: Started OpenClaw Gateway.
May 05 09:39:29 PC-20260425YEDW bash[1368]: 2026-05-05T09:39:29.033+08:00 [qqbot] [default] [qqbot:token:1903927819] Network error: fetch failed | getaddrinfo EAI_AGAIN bots.qq.com
May 05 09:39:29 PC-20260425YEDW bash[1368]: 2026-05-05T09:39:29.036+08:00 [qqbot] [default] Connection failed: Network error getting access_token: fetch failed | getaddrinfo EAI_AGAIN bots.qq.com
May 05 09:39:30 PC-20260425YEDW bash[1368]: 2026-05-05T09:39:30.211+08:00 [qqbot] [default] [qqbot:token:1903927819] Network error: fetch failed | getaddrinfo EAI_AGAIN bots.qq.com
May 05 09:39:30 PC-20260425YEDW bash[1368]: 2026-05-05T09:39:30.213+08:00 [qqbot] [default] Connection failed: Network error getting access_token: fetch failed | getaddrinfo EAI_AGAIN bots.qq.com
May 05 09:39:40 PC-20260425YEDW bash[1368]: 2026-05-05T09:39:40.666+08:00 [qqbot] [default] [qqbot:token:1903927819] Network error: fetch failed | getaddrinfo EAI_AGAIN bots.qq.com
May 05 09:39:40 PC-20260425YEDW bash[1368]: 2026-05-05T09:39:40.668+08:00 [qqbot] [default] Connection failed: Network error getting access_token: fetch failed | getaddrinfo EAI_AGAIN bots.qq.com
May 05 09:39:44 PC-20260425YEDW bash[1368]: 2026-05-05T09:39:44.126+08:00 [agent/embedded] [trace:embedded-run] startup stages: runId=c9df2ada-64ab-4805-a1f1-3110205ab3f5 sessionId=24af2648-826d-4657-9fa4-201dd44c8f89 phase=attempt-dispatch totalMs=10586 stages=workspace:1ms@1ms,runtime-plugins:2221ms@2222ms,hooks:1ms@2223ms,model-resolution:2352ms@4575ms,auth:2539ms@7114ms,context-engine:1ms@7115ms,attempt-dispatch:3471ms@10586ms
lz@PC-20260425YEDW:~$

---

### 🤖 Kimi
*2026-05-05T01:39:53.790940Z*

日志显示两个关键问题：

**1. 凌晨那次崩溃（02:43）**
- `code=killed, status=9/KILL` → 被 SIGKILL 强制终止
- 之前有大量 `eventLoopDelayMaxMs=8111.8` 之类的诊断警告，事件循环严重阻塞
- 推测是 **OOM（内存不足）被系统 kill**，或者有人手动 `kill -9`

**2. 当前这次（09:39 开机启动）**
- 服务其实是 **Started** 成功的，状态不是 dead
- 但卡在 QQ Bot 网络连接：`getaddrinfo EAI_AGAIN bots.qq.com`
- 这是 **DNS 解析失败**，大概率是网络还没就绪就启动了

---

先确认下当前真实状态：

```bash
sudo systemctl status openclaw-gateway
```

如果还是 `inactive`，那可能是启动后因为 QQ Bot 连不上又退出了。如果是 `active`，那就是网络问题导致功能不可用但进程还在。

**两个修复方向：**

**A. 如果是 DNS/网络时序问题**，给服务加网络依赖，让开机时等网络就绪再启动：

```bash
sudo systemctl edit openclaw-gateway
```

加这两行：
```ini
[Unit]
After=network-online.target
Wants=network-online.target
```

然后：
```bash
sudo systemctl daemon-reload
sudo systemctl restart openclaw-gateway
```

**B. 如果是内存不足被 OOM kill**，需要看 `dmesg | grep -i kill` 确认。你 WSL2 只配了 8GB 内存，如果 OpenClaw + 其他东西吃满了，系统会直接杀进程。

---

你先跑一下 `sudo systemctl status openclaw-gateway` 和 `dmesg | grep -i "killed\|oom"`，看看现在到底是哪种情况？

---

### 🧑 用戶
*2026-05-05T01:39:53.790937Z*

tages: runId=86f4953a-2a11-4baf-a477-ddd10118f52c sessionId=24af2648-826d-4657-9fa4-201dd44c8f89 phase=stream-ready totalMs=22116 stages=workspace-sandbox:36ms@36ms,skills:1ms@37ms,core-plugin-tools:5043ms@5080ms,bootstrap-context:17ms@5097ms,bundle-tools:1553ms@6650ms,system-prompt:7030ms@13680ms,session-resource-loader:1665ms@15345ms,agent-session:4ms@15349ms,stream-setup:6767ms@22116ms
May 05 02:43:25 PC-20260425YEDW systemd[1]: openclaw-gateway.service: Main process exited, code=killed, status=9/KILL
May 05 02:43:25 PC-20260425YEDW systemd[1]: openclaw-gateway.service: Failed with result 'signal'.
May 05 02:43:25 PC-20260425YEDW systemd[1]: openclaw-gateway.service: Consumed 1min 8.423s CPU time.
May 05 02:43:30 PC-20260425YEDW systemd[1]: openclaw-gateway.service: Scheduled restart job, restart counter is at 3.
May 05 02:43:30 PC-20260425YEDW systemd[1]: Stopped OpenClaw Gateway.
May 05 02:43:30 PC-20260425YEDW systemd[1]: openclaw-gateway.service: Consumed 1min 8.423s CPU time.
May 05 02:43:30 PC-20260425YEDW systemd[1]: Started OpenClaw Gateway.
May 05 02:43:37 PC-20260425YEDW bash[1569689]: 2026-05-05T02:43:37.490+08:00 [gateway] removed stale session lock: /home/lz/.openclaw/agents/main/sessions/24af2648-826d-4657-9fa4-201dd44c8f89.jsonl.lock (dead-pid)
May 05 02:43:37 PC-20260425YEDW bash[1569689]: 2026-05-05T02:43:37.511+08:00 [main-session-restart-recovery] marked 1 interrupted main session(s) from stale transcript locks
May 05 02:43:43 PC-20260425YEDW bash[1569689]: 2026-05-05T02:43:43.517+08:00 [main-session-restart-recovery] marked interrupted main session failed: agent:main:main (transcript tail is not resumable)
May 05 02:44:03 PC-20260425YEDW bash[1569689]: 2026-05-05T02:44:03.591+08:00 [diagnostic] liveness warning: reasons=event_loop_delay interval=28s eventLoopDelayP99Ms=376.7 eventLoopDelayMaxMs=8111.8 eventLoopUtilization=0.525 cpuCoreRatio=0.611 active=0 waiting=0 queued=0
May 05 02:45:06 PC-20260425YEDW bash[1569689]: 2026-05-05T02:45:06.810+08:00 [agent/embedded] [trace:embedded-run] prep stages: runId=0d46a681-90ed-486e-ae84-965d26ea5d1f sessionId=24af2648-826d-4657-9fa4-201dd44c8f89 phase=stream-ready totalMs=22019 stages=workspace-sandbox:25ms@25ms,skills:1ms@26ms,core-plugin-tools:7316ms@7342ms,bootstrap-context:20ms@7362ms,bundle-tools:1537ms@8899ms,system-prompt:4605ms@13504ms,session-resource-loader:1643ms@15147ms,agent-session:5ms@15152ms,stream-setup:6867ms@22019ms
May 05 02:46:26 PC-20260425YEDW bash[1569689]: 2026-05-05T02:46:26.198+08:00 [diagnostic] liveness warning: reasons=event_loop_delay interval=31s eventLoopDelayP99Ms=39.4 eventLoopDelayMaxMs=7264.5 eventLoopUtilization=0.62 cpuCoreRatio=0.685 active=1 waiting=0 queued=1
May 05 02:46:43 PC-20260425YEDW bash[1569689]: 2026-05-05T02:46:43.217+08:00 [agent/embedded] [trace:embedded-run] prep stages: runId=8d46a3fa-1db0-4714-90f2-db16d38bbbf1 sessionId=24af2648-826d-4657-9fa4-201dd44c8f89 phase=stream-ready totalMs=21860 stages=workspace-sandbox:5ms@5ms,skills:0ms@5ms,core-plugin-tools:4835ms@4840ms,bootstrap-context:392ms@5232ms,bundle-tools:1455ms@6687ms,system-prompt:6776ms@13463ms,session-resource-loader:1625ms@15088ms,agent-session:3ms@15091ms,stream-setup:6769ms@21860ms
May 05 02:49:08 PC-20260425YEDW bash[1569689]: 2026-05-05T02:49:08.531+08:00 [agent/embedded] [trace:embedded-run] startup stages: runId=4306b3cc-cacb-46cd-b43f-5794f61218da sessionId=24af2648-826d-4657-9fa4-201dd44c8f89 phase=attempt-dispatch totalMs=10686 stages=workspace:1ms@1ms,runtime-plugins:2ms@3ms,hooks:0ms@3ms,model-resolution:3466ms@3469ms,auth:3029ms@6498ms,context-engine:1ms@6499ms,attempt-dispatch:4187ms@10686ms
May 05 02:49:15 PC-20260425YEDW bash[1569689]: 2026-05-05T02:49:15.651+08:00 [diagnostic] liveness warning: reasons=event_loop_delay interval=29s eventLoopDelayP99Ms=73.7 eventLoopDelayMaxMs=8040.5 eventLoopUtilization=0.67 cpuCoreRatio=0.7 active=1 waiting=0 queued=1
May 05 02:49:16 PC-20260425YEDW systemd[1]: Stopping OpenClaw Gateway...
May 05 02:49:24 PC-20260425YEDW systemd[1]: openclaw-gateway.service: Deactivated successfully.
May 05 02:49:24 PC-20260425YEDW systemd[1]: Stopped OpenClaw Gateway.
May 05 02:49:24 PC-20260425YEDW systemd[1]: openclaw-gateway.service: Consumed 2min 23.658s CPU time.
-- Boot b6bf01553b93413395bf805f77453363 --
May 05 09:39:20 PC-20260425YEDW systemd[1]: Started OpenClaw Gateway.
May 05 09:39:29 PC-20260425YEDW bash[1368]: 2026-05-05T09:39:29.033+08:00 [qqbot] [default] [qqbot:token:1903927819] Network error: fetch failed | getaddrinfo EAI_AGAIN bots.qq.com
May 05 09:39:29 PC-20260425YEDW bash[1368]: 2026-05-05T09:39:29.036+08:00 [qqbot] [default] Connection failed: Network error getting access_token: fetch failed | getaddrinfo EAI_AGAIN bots.qq.com
May 05 09:39:30 PC-20260425YEDW bash[1368]: 2026-05-05T09:39:30.211+08:00 [qqbot] [default] [qqbot:token:1903927819] Network error: fetch failed | getaddrinfo EAI_AGAIN bots.qq.com
May 05 09:39:30 PC-20260425YEDW bash[1368]: 2026-05-05T09:39:30.213+08:00 [qqbot] [default] Connection failed: Network error getting access_token: fetch failed | getaddrinfo EAI_AGAIN bots.qq.com
May 05 09:39:40 PC-20260425YEDW bash[1368]: 2026-05-05T09:39:40.666+08:00 [qqbot] [default] [qqbot:token:1903927819] Network error: fetch failed | getaddrinfo EAI_AGAIN bots.qq.com
May 05 09:39:40 PC-20260425YEDW bash[1368]: 2026-05-05T09:39:40.668+08:00 [qqbot] [default] Connection failed: Network error getting access_token: fetch failed | getaddrinfo EAI_AGAIN bots.qq.com
May 05 09:39:44 PC-20260425YEDW bash[1368]: 2026-05-05T09:39:44.126+08:00 [agent/embedded] [trace:embedded-run] startup stages: runId=c9df2ada-64ab-4805-a1f1-3110205ab3f5 sessionId=24af2648-826d-4657-9fa4-201dd44c8f89 phase=attempt-dispatch totalMs=10586 stages=workspace:1ms@1ms,runtime-plugins:2221ms@2222ms,hooks:1ms@2223ms,model-resolution:2352ms@4575ms,auth:2539ms@7114ms,context-engine:1ms@7115ms,attempt-dispatch:3471ms@10586ms
lz@PC-20260425YEDW:~$

---

### 🤖 Kimi
*2026-05-05T01:39:28.398435Z*

服务处于 **inactive (dead)** 状态，虽然已启用（enabled），但当前没在运行。

几个排查方向，先确认一下：

1. **看日志找原因**：
   ```bash
   sudo journalctl -u openclaw-gateway -n 50 --no-pager
   ```

2. **手动启动试试，看报什么错**：
   ```bash
   sudo systemctl start openclaw-gateway
   sudo systemctl status openclaw-gateway
   ```

3. **检查服务文件本身**：
   ```bash
   cat /etc/systemd/system/openclaw-gateway.service
   ```

4. **如果是刚部署的，可能需要 reload**：
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl start openclaw-gateway
   ```

你先跑下 `journalctl` 和 `start` 看看输出？

---

### 🧑 用戶
*2026-05-05T01:39:28.398433Z*

lz@PC-20260425YEDW:~$ sudo systemctl status openclaw-gateway  # 看状态
○ openclaw-gateway.service - OpenClaw Gateway
     Loaded: loaded (/etc/systemd/system/openclaw-gateway.service; enabled; vendor preset: enabled)
     Active: inactive (dead)

---

