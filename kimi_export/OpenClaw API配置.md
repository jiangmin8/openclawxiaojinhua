# OpenClaw API配置

**chat_id**: `19e122fb-d872-8684-8000-0934978688cd`  |  **消息數**: 4

---

### 🧑 用戶
*2026-05-10T14:00:48.786205Z*

{
  "agents": {
    "defaults": {
      "workspace": "/home/lz/.openclaw/workspace",
      "bootstrapMaxChars": 15000,
      "model": "ollama/qwen2.5-coder:7b",
      "models": {
        "deepseek/deepseek-v4-pro": {
          "alias": "default",
          "params": {
            "max_tokens": 12000,
            "temperature": 0.5,
            "top_p": 0.8
          }
        },
        "deepseek/deepseek-v4-flash": {},
        "ollama/qwen2.5-coder:7b": {
          "alias": "本地"
        }
      }
    }
  },
  "models": {
    "mode": "merge",
    "providers": {
      "deepseek": {
        "baseUrl": "https://api.deepseek.com",
        "apiKey": "sk-9a9b99b40d1a4282a114bd5969f9ea76",
        "api": "openai-completions",
        "models": [
          {
            "id": "deepseek-chat",
            "name": "DeepSeek Chat",
            "reasoning": false,
            "input": [
              "text"
            ],
            "contextWindow": 163840
          },
          {
            "id": "deepseek-v4-pro",
            "name": "DeepSeek V4 Pro",
            "reasoning": true,
            "input": [
              "text"
            ],
            "contextWindow": 163840
          },
          {
            "id": "deepseek-v4-flash",
            "name": "DeepSeek V4 Flash",
            "reasoning": false,
            "input": [
              "text"
            ],
            "contextWindow": 163840
          }
        ]
      }
    }
  },
  "gateway": {
    "mode": "local",
    "port": 18789,
    "bind": "loopback",
    "auth": {
      "mode": "token",
      "token": "18418663d4431ca12e19e246fb4d8b46a22a1d5303738902"
    }
  },
  "logging": {
    "level": "info",
    "consoleLevel": "warn"
  },
  "plugins": {
    "entries": {
      "deepseek": {
        "enabled": true
      },

---

### 🧑 用戶
*2026-05-10T13:59:39.143011Z*

写个openclaw用API KEY的json   模型mimamax  2.5

---

### 🤖 Kimi
*2026-05-10T13:59:39.143015Z*

您好！为了帮您准确编写 OpenClaw 使用 MiniMax 2.5 模型的 API Key JSON 配置，想确认两个细节：

1.  您使用的 MiniMax 2.5 模型是 MiniMax 官方原版（通常通过 MiniMax 平台直接获取 API Key），还是通过其他平台（如阿里云、SCNet 等）提供的 MiniMax 2.5 模型服务（这些平台可能有自己的 API Key 和接入点）？
2.  关于 JSON 配置的具体内容，您是希望了解如何配置 `~/.openclaw/openclaw.json` 文件中的 `models` 部分来使用这个 API Key 和模型，还是需要了解如何通过 OpenClaw 的命令行配置向导来设置？

---

### 🤖 Kimi
*2026-05-10T14:00:48.786209Z*

您好！为了帮您准确地在 `openclaw.json` 中配置 MiniMax 2.5 模型及其 API Key，能否请您澄清以下两点：

1.  您计划使用的 MiniMax 2.5 模型具体是哪个版本或变体（例如，是 MiniMax 官方原版，还是通过其他平台如阿里云、SCNet 等提供的服务）？这会影响 API Key 的获取方式和 `provider` 的配置。
2.  关于配置内容，您是希望了解如何在 `~/.openclaw/openclaw.json` 文件中手动添加 MiniMax 2.5 模型的配置，还是希望通过 OpenClaw 的命令行配置向导来设置？

> 💭 梳理OpenClaw Mimamax 2.5的API设计时，我意识到需要确认端点地址、Key嵌入位置以及版本特有的参数要求，才能构建出规范的JSON格式。

> 💭 梳理OpenClaw与MiniMax的对接逻辑后，我发现OAuth和API Key两种认证路径各有适用场景，而[^4^]中的完整JSON配置片段恰好提供了可直接复用的模板框架。

> 💭 梳理OpenClaw与MiniMax的对接逻辑后，我发现现有配置片段已涵盖baseUrl、apiKey及模型核心参数，但为确保JSON格式的完整性与可运行性，仍需进一步验证或搜寻更权威的示例参照。

> 💭 梳理[^6^][^7^]的配置细节后，我发现MiniMax M2.5的国内版需要调整baseUrl至minimaxi.com并同步修改模型ID与名称，准备进一步核验参数完整性。

> 💭 梳理[^1^]的配置细节后，我已拼凑出MiniMax M2.5的完整JSON框架，从环境变量到模型参数逐一落位，正准备向下滚动确认有无遗漏的隐藏配置项。

> 💭 梳理MiniMax的接入机制后，我发现OAuth与手动配置的双轨设计颇具灵活性，而`cost`参数的缺失暗示着计费维度仍有待补齐。

> 💭 梳理MiniMax M2.7的配置结构后，我注意到M2.5在上下文窗口和定价参数上存在显著差异，正从[^14^]提取准确的成本数据以完成适配。

> 💭 梳理MiniMax M2.5的定价脉络后，我注意到其缓存读写成本远低于M2.7版本，这一差异值得在配置时细细掂量。

> 💭 梳理OpenClaw与MiniMax M2.5的对接逻辑，我发现国内版专属地址和模型ID的细微差异是配置成败的关键，正打算从[^21^]中确认完整参数细节。

> 💭 梳理OpenClaw的MiniMax M2.5配置要点后，我发现国内版专属地址和模型ID的精准匹配是接入成功的关键。

> 💭 梳理OpenClaw的MiniMax配置时，我注意到官方文档默认指向M2.7版本，而M2.5的完整配置细节仍需从教程中进一步核实。

> 💭 梳理[^1^]与[^18^]的配置碎片后，我拼凑出MiniMax M2.5的完整接入方案：国内专属地址、双版本模型ID切换，以及精确到小数点后两位的成本参数。

> 💭 梳理MiniMax M2.5的配置脉络后，我发现国内版API端点与Anthropic兼容格式是关键，正将环境变量注入与模型参数校准整合为一份可直接落地的JSON方案。

> 💭 梳理OpenClaw文档中的MiniMax配置结构后，我发现M2.7的完整JSON模板可作为M2.5的改编基础，关键在于调整模型标识、上下文窗口及成本参数。

> 💭 梳理现有配置片段后，我发现官方文档尚未收录MiniMax-M2.5的完整参数，尤其是cost字段仍待确认。

> 💭 Cross-referencing [^34^], [^36^], and [^40^] reveals MiniMax M2.5's pricing structure with surprising consistency—input at $0.30, output at $1.20, plus notably low cache read costs at $0.03, which I'm now weaving into a complete OpenClaw configuration with the domestic endpoint and 200K context window.

以下是 OpenClaw 配置 MiniMax M2.5 的推荐 JSON 核心结构，采用环境变量引用模式确保安全：

```json
{
  "env": { "MINIMAX_API_KEY": "sk-sp-xxxxxxxxxxxxxxxx" },
  "agents": { "defaults": { "model": { "primary": "minimax/MiniMax-M2.5" } } },
  "models": {
    "mode": "merge",
    "providers": {
      "minimax": {
        "baseUrl": "https://api.minimaxi.com/anthropic",
        "apiKey": "${MINIMAX_API_KEY}",
        "api": "anthropic-messages",
        "authHeader": true,
        "models": [{
          "id": "MiniMax-M2.5", "name": "MiniMax M2.5",
          "reasoning": false, "input": ["text"],
          "cost": { "input": 0.30, "output": 1.20, "cacheRead": 0.03, "cacheWrite": 0.375 },
          "contextWindow": 200000, "maxTokens": 8192
        }]
      }
    }
  }
}
```



---

