# HEARTBEAT.md — 守护依赖清单

---

## 服务保活

- OpenClaw Gateway: `systemctl --user restart openclaw-gateway`
- 端口: `localhost:18789`

---

## 网络连通

- 代理服务健康检查
- 路由器 Ping 网关
- API 连通性测试

---

## 备份验证

- 目标路径: `/mnt/g`
- 频率: 每日
