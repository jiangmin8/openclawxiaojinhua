# CloakBrowser 研究

> 源：`/mnt/e/知识库种子/CloakBrowser/` (github.com/CloakHQ/CloakBrowser)
> 日期：2026-05-20
> 星数：16K | 协议：MIT

## 核心能力

修改 Chromium C++ 源码，49 处指纹补丁（canvas/WebGL/audio/fonts/GPU/WebRTC/网络时序），通过 Cloudflare Turnstile + FingerprintJS + BrowserScan 全 30 项检测。

## API

```python
from cloakbrowser import launch
browser = launch(headless=True)  # 默认 headless
page = browser.new_page()
page.goto("https://protected-site.com")
browser.close()
```

```bash
# Docker 一键测试
docker run --rm cloakhq/cloakbrowser cloaktest
```

## 关键参数

| 参数 | 默认 | 说明 |
|:---|:---|:---|
| `headless` | `True` | WSL2 可用 ✅ |
| `proxy` | `None` | 支持 http/socks5 |
| `humanize` | `False` | 启用 = 人类鼠标/键盘/滚动模式 |
| `geoip` | `False` | 从代理 IP 自动检测时区 |
| `stealth_args` | `True` | 49 个 stealth 标志 |

## 架构

```
cloakbrowser/
├── browser.py       # launch/launch_async
├── download.py      # 自动下载 stealth Chromium (~200MB)
├── config.py         # 配置
├── human/            # 人类行为模拟
│   ├── mouse.py      #   鼠标曲线
│   ├── keyboard.py   #   键盘时序
│   └── scroll.py     #   滚动模式
└── geoip.py          # 代理 IP 地理检测
```

## 对雅典娜的价值

- 替代当前不可用的 browser-automation 技能
- headless=True 兼容 WSL2 无桌面环境
- Docker 可用，避免本地安装
- 过所有 bot 检测，网页抓取不再被盾
