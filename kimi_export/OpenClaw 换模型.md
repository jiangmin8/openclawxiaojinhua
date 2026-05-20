# OpenClaw 换模型

**chat_id**: `19dde313-dc92-8d64-8000-0934c96204f7`  |  **消息數**: 6

---

### 🤖 Kimi
*2026-04-30T11:42:49.878765Z*

先帮你定位具体文件：

你的源码不在当前目录，先找到它：

源码安装的模型配置在 **`src/config/types.models.ts`** 和 **`src/config/`** 目录下，改这几个地方：

---

### 1. 改默认模型 ID（所有新会话生效）

**文件：** `src/config/agents.defaults.ts`（或 `src/config/defaults.ts`）

找到：

```typescript
model: {
  provider: "openai",
  id: "gpt-4o"
}
```

改成：

```typescript
model: {
  provider: "deepseek",
  id: "deepseek-v4-pro"
}
```

---

### 2. 添加 DeepSeek 模型定义（如果类型里没定义）

**文件：** `src/config/types.models.ts`

在 `SUPPORTED_MODELS` 或模型列表里加：

```typescript
{
  id: "deepseek-v4-pro",
  name: "DeepSeek V4 Pro",
  provider: "deepseek",
  reasoning: true,
  input: ["text", "image"],
  cost: {
    input: 0.5,      // $/1M tokens
    output: 2.0,
    cacheRead: 0.1,
    cacheWrite: 0.5
  },
  contextWindow: 128000,
  maxTokens: 8192
}
```

---

### 3. 配置 DeepSeek API Key

**文件：** `src/config/providers.ts`（或 `src/providers/deepseek.ts`）

确保有 DeepSeek 的 provider 配置：

```typescript
deepseek: {
  baseURL: "https://api.deepseek.com/v1",
  apiKeyEnv: "DEEPSEEK_API_KEY",
  models: ["deepseek-v4-pro", "deepseek-v4-flash"]
}
```

---

### 4. 设置环境变量

```bash
export DEEPSEEK_API_KEY="sk-你的APIKey"
```

或者写到 `.env` 文件里。

---

### 5. 重新编译运行

```bash
pnpm build
pnpm gateway:watch
```

---

如果你找不到具体文件，在源码根目录执行：

```bash
find . -name "*.ts" | xargs grep -l "gpt-4o\|DEFAULT_MODEL\|agents.defaults"
```

把输出贴给我，我直接告诉你改哪一行。

---

### 🧑 用戶
*2026-04-30T11:42:49.878762Z*

在哪里改？

---

### 🤖 Kimi
*2026-04-30T11:42:15.241072Z*

源码安装的话，模型配置在代码里，改这两个地方：

---

### 1. 改默认模型（所有新会话生效）

**文件：** `src/Config.ts`（或 `src/config.ts`，看你版本）

找到类似这样的：

```typescript
const DEFAULT_MODEL = "openai/gpt-4o";
```

改成：

```typescript
const DEFAULT_MODEL = "deepseek/deepseek-v4-pro";
```

---

### 2. 改模型列表/可选模型（如果有限制）

**文件：** `src/Models.ts` 或 `src/constants.ts`

确保列表里有 deepseek，没有就加：

```typescript
export const SUPPORTED_MODELS = [
  "deepseek/deepseek-v4-pro",
  "deepseek/deepseek-v4-flash",
  // 其他你用的
];
```

---

### 3. 改 API 路由（如果 deepseek 是单独 endpoint）

**文件：** `src/Providers.ts` 或 `src/api/providers.ts`

检查 deepseek 的 baseURL 和 key 环境变量名，确认是：

```typescript
deepseek: {
  baseURL: "https://api.deepseek.com/v1",
  apiKeyEnv: "DEEPSEEK_API_KEY",
}
```

---

### 4. 重新编译运行

```bash
# 看你用的什么
npm run build
# 或
pnpm build
# 或
yarn build

# 然后启动
npm start
```

---

如果你告诉我具体路径（`find . -name "*.ts" | grep -i config`），我可以给你更精确的命令直接定位文件。

---

### 🧑 用戶
*2026-04-30T11:42:15.241068Z*

我是仓库源码安装

---

### 🤖 Kimi
*2026-04-30T11:41:02.281081Z*

DeepSeek 最新的是 **V4 Pro**（`deepseek-v4-pro`），以下是 OpenClaw 切换命令：

---

### 方法一：命令行永久切换（推荐）

```bash
# 1. 启动配置向导，更新模型配置
openclaw onboard --install-daemon
```

按提示操作：
- `I understand this is personal-by-default...` → 选 **Yes**
- `Setup mode` → 选 **QuickStart**
- `Model/auth provider` → 选 **DeepSeek**
- `Enter DeepSeek API key` → 粘贴你的 API Key
- `Default model` → 选 **Enter model**，手动输入 `deepseek-v4-pro`
- 其余配置（频道、Skill 等）新手可以 **Skip for now**
- 最后选 **Restart** 重启 Gateway

---

### 方法二：直接改配置文件

编辑 `~/.openclaw/openclaw.json`（或 `~/.config/openclaw/openclaw.json5`），修改 `primary` 字段：

```json
{
  "agent": {
    "model": {
      "primary": "deepseek/deepseek-v4-pro"
    }
  }
}
```

然后重启生效：

```bash
openclaw gateway restart
```

---

### 方法三：聊天中临时切换（仅当前会话）

在 OpenClaw 聊天窗口输入：

```bash
/model deepseek/deepseek-v4-pro
```

---

### 补充说明

- `deepseek-v4-pro` 是性能最强的版本，适合复杂推理；如果日常用想省钱，可以换 `deepseek-v4-flash` [^1^]
- 旧模型 ID `deepseek-chat` 和 `deepseek-reasoner` 将在 **2026年7月24日** 弃用，建议直接切到 V4 系列 [^1^]
- 如果已有会话中途切换 V4 模型报错，升级到 OpenClaw **v2026.4.24** 以上版本即可修复 [^1^]

需要我帮你检查当前 OpenClaw 版本或排查 API Key 配置吗？

---

### 🧑 用戶
*2026-04-30T11:41:02.281077Z*

我要换openclaw的模型。。给我命令换deepseek最新那个pro 用api

---

