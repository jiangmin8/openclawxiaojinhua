# Ollama 本地 AI — 模型清单与用法

## GPU 资源
| 项目 | 值 |
|------|-----|
| 显卡 | NVIDIA RTX 3060 |
| 显存 | 12GB (常剩 ~10GB) |
| WSL 调用 | nvidia-smi.exe (Windows 侧) |
| 服务端口 | 11434 |

## 已下载模型
| 模型 | 大小 | VRAM | 用途 |
|------|------|------|------|
| qwen2.5:7b (Q4_K_M) | 4.7GB | ✅ | 主力本地, 支持 tools |
| qwen2.5-coder:7b (Q4_K_M) | 4.7GB | ✅ | 代码, 支持 tools |
| deepseek-coder-v2:16b (Q4_0) | 8.9GB | ✅ | 复杂代码 |
| deepseek-r1:8b (Q4_K_M) | 5.2GB | ✅ | 深度推理 |
| gemma3:12b-it-qat (Q4_0) | 8.9GB | ✅ | 备用 |
| nomic-embed-text (F16) | 274MB | ✅ | 知识库嵌入 |
| gemma4:26b (Q4_K_M) | 17GB | ❌ | 超显存, 备用 |

## VRAM 预算
```
总计 12GB - 系统 2GB = 可用 10GB
qwen2.5:7b      5GB  ← Cron 巡检用
                 5GB  ← 剩余可加载另一个 7B-8B
deepseek-coder  9GB  ← 单独加载时
```

## 启动/管理
```bash
ollama serve > /tmp/ollama.log 2>&1 &  # 后台启动
ollama list                             # 列出模型
ollama pull <model>                     # 下载新模型
ollama rm <model>                       # 删除模型
```

## API 端点
- Chat: `http://localhost:11434/v1/chat/completions`
- Tags: `http://localhost:11434/api/tags`
- Embed: `http://localhost:11434/api/embed`

## OpenClaw 对接
- Provider: ollama (models.json)
- API 类型: ollama
- 支持 tools: qwen2.5:7b ✅, deepseek-coder-v2:16b ✅

## 注意事项
- gemma4:26b 超显存不能跑，除非 offload 部分到 CPU (极慢)
- 7B 模型推理速度约 30-50 tokens/s (RTX 3060)
- 16B 模型推理速度约 15-25 tokens/s
- 多模型同时加载会争抢显存
