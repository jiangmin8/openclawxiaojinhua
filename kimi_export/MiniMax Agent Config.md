# MiniMax Agent Config

**chat_id**: `19e1562c-cf62-8ee3-8000-09340e88119c`  |  **消息數**: 2

---

### 🧑 用戶
*2026-05-11T04:54:17.078295Z*

{
  "env": {
    "MINIMAX_API_KEY": "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"
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "minimax/MiniMax-M2.5"
      },
      "maxConcurrent": 4,
      "subagents": {
        "maxConcurrent": 8
      },
      "workspace": "~/.openclaw/workspace",
      "compaction": {
        "mode": "safeguard"
      },
      "timeoutSeconds": 300
    }
  },
  "models": {
    "mode": "merge",
    "providers": {
      "minimax": {
        "baseUrl": "https://api.minimaxi.com/anthropic",
      }
    },
    "api": "anthropic-messages",
    "authHeader": true,
    "models": [
      {
        "id": "MiniMax-M2.5",
        "name": "MiniMax M2.5",
        "reasoning": false,
        "input": [
          "text"
        ],
        "cost": {
          "input": 0.30,
          "output": 1.20,
          "cacheRead": 0.03,
          "cacheWrite": 0.375
        },
        "contextWindow": 200000,
        "maxTokens": 8192
      }
    ]
  }
}

---

### 🤖 Kimi
*2026-05-11T04:54:17.078298Z*

This configuration file appears to be for an AI agent platform. To help you best, could you please clarify what you're trying to achieve with this file? For example, are you:

1.  Encountering an error or issue while using it?
2.  Seeking to understand what a specific section or setting does?
3.  Looking to modify it for a particular use case or integration?
4.  Trying to troubleshoot a problem with agent behavior or performance?

Let me know your goal so I can tailor the research accordingly.

---

