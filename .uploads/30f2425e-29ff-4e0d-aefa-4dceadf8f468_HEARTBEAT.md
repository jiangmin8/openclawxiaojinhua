# HEARTBEAT.md — 雅典娜自主守护循环

> **调度机制：** 以下任务通过 OpenClaw 内置定时器触发。雅典娜在每次会话启动和空闲时检查是否有到期任务需要执行。

---

## 1. 高频守护（每小时）

### 1.1 API 连通性检查

- **检查：** `curl -s --max-time 5 {API_ENDPOINT}/health`
- **自愈：** 若无响应，检查代理状态 (`curl -x {proxy} -s http://httpbin.org/ip`)；尝试切换备用节点。
- **报警：** `[Alert] API 连接异常，请检查 Key 余额或网络代理。`
- **配置：** API 地址和代理地址配置在 `/home/lz/.openclaw/.env` 中。

### 1.2 Gateway 服务保活

- **检查：** `systemctl --user is-active openclaw-gateway` 或 `curl -s http://localhost:18789/health`
- **自愈：** 若掉线，执行 `systemctl --user restart openclaw-gateway`。
- **授权：** 参见 AGENTS.md III.4。

### 1.3 路由器连通性

- **检查：** `ping -c 2 -W 3 {GATEWAY_IP}`（网关 IP 配置于 MEMORY.md 子文件）
- **报警：** `[Alert] 网络断开，无法 Ping 通网关。`

---

## 2. 每日守护（每日 22:00）

### 2.1 备份完整性校验

- **检查：** 遍历 `/mnt/g/backup/` 目录，验证最近一次备份的 sha256 校验值是否匹配。
- **报警：** 若备份缺失或校验失败，输出 `[Alert] 备份完整性检查失败：{具体问题}`。

### 2.2 日志清理

- **范围：** `/tmp/*.log`、`/home/lz/.openclaw/logs/*.log`
- **规则：** `find {path} -name "*.log" -mtime +7 -delete`
- **报告：** 输出清理文件数量和释放空间大小。

---

## 3. 系统健康检查（每6小时）

### 3.1 资源监控

| 指标 | 阈值 | 命令 |
|:---|:---|:---|
| CPU 使用率 | > 90% 持续 5 分钟 | `top -bn1 \| head -5` |
| 内存使用率 | > 85% | `free -h` |
| 磁盘使用率 | > 90% (任意分区) | `df -h` |
| 磁盘 `/mnt/e` | > 80% | `df -h /mnt/e` |

- **报警：** 任一指标超阈值，输出 `[Alert] 资源告警：{指标} 当前 {数值}，超过阈值 {阈值}`。

### 3.2 性能报告

向大哥汇总当前运行状态：

```
[守护报告] {时间戳}
  CPU: {使用率}% | 内存: {使用率}% | 磁盘 /mnt/e: {使用率}%
  Gateway: {运行中/已停止}
  API: {正常/异常}
  备份: {正常/异常}
```
