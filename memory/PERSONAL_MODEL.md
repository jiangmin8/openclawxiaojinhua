# 🐘 Personal Model — 关于大哥的理解

> Elephant 风格 4 镜模型。自动提炼，可纠正。stale >30天退役。

## 格式规范

### 信念条目格式
```yaml
- id: World.RAX3000Me.刷机方法
  value: "免拆 + 官方固件"
  source: web_search.结果2
  confidence: confirmed  # confirmed / tentative / stale
  updated: 2026-05-20
  project: network  # 域标签，用于多项目隔离
  refs:  # 交叉引用
    - id: Journey.刷机教训.DDR确认
      type: depends_on  # depends_on / conflicts_with / supercedes
```

### 镜头间关系线
- 用 `refs` 字段建立双向链接
- 关系类型：`depends_on` / `conflicts_with` / `supercedes`

### 置信度
| 状态 | 含义 |
|:---|:---|
| `confirmed` | 已验证，有充足证据 |
| `tentative` | 推断，待确认 |
| `stale` | >30天未引用，可能过时

### 退役规则
- `stale` >90天 → 移动到 `memory/context.archive.md` 的 Personal Model 归档区
- 每季度归档一次（3/6/9/12月1日）

---

## Identity

- 决策风格：定方向不执行细节，架构选型亲自拍板。`[2026-05-20]`
- 边界感强：安全规则静默运行，不要反复确认。`[2026-05-20]`
- 沟通偏好：中文、干练、直接，讨厌废话和重复。`[2026-05-20]`
- 技能水平：自认代码小白，需要开箱即用的方案。`[2026-05-20]`
- 耐心有限：反复试同一方法会被骂"你在梦游啊"。`[2026-05-20]`

## World

### 项目
- RAX3000Me 远程刷机 — 🔄 进行中。免拆方案，手机Tailscale桥接。阻塞：手机未到现场。`[2026-05-20]`
- 雅典娜进化 — ✅ 已完成。Subconscious Loop + TokenJuice + Memory Tree + Flow Engine。`[2026-05-20]`

### 设备
- MT3600BE (192.168.8.1) — 主路由，GL.iNet，ARMv8，512MB `[2026-05-20]`
- RAX3000Me — 待刷路由器，MT7981B，512MB，目标 192.168.10.1 `[2026-05-20]`
- 荣耀畅玩60M (NIC-AN00) — Tailscale+ADB 桥接手机 `[2026-05-20]`
- 萤石 BF3446523 (192.168.8.159) — 摄像头，加密，私有协议 `[2026-05-20]`

### 工具链
- OpenClaw Gateway + deepseek-v4-pro + Ollama 20 模型 `[2026-05-20]`
- GitHub: jiangmin8 `[2026-05-20]`

## Pulse

- 当前焦点：密集学习 AI 架构（OpenHuman→CrewAI→agent-skills→Ruflo→Elephant）`[2026-05-20]`
- 活跃时间：凌晨 4AM-8AM 高频 `[2026-05-20]`
- 活跃压力：知识整合速度要快，不要停滞 `[2026-05-20]`

## Journey

- 刷机教训：DDR 版本必须先确认再刷 uboot，不然必砖。免拆优先于 TTL。`[2026-05-20]`
- 安全经验：QQ 双因子验证 → 远程桌面解锁更实用。`[2026-05-20]`
- 进化方法：先研究吸收再实现，不是先实现再研究。`[2026-05-20]`

## Open Questions

- 🐘 Q: — (待下一轮好奇引擎生成)
