# xmir-patcher 安装日志

**chat_id**: `19df26d4-f8c2-841f-8000-0934ad744474`  |  **消息數**: 2

---

### 🤖 Kimi
*2026-05-04T09:59:03.308922Z*

pip 在尝试连接 `127.0.0.1` 下载 `pyftpdlib`，这明显不是正常的 PyPI 行为。大概率是你的 pip 配置了错误的代理或镜像源。

先确认一下配置，然后给你修复方案：

```bash
# 查看当前 pip 配置
pip config list

# 查看配置文件位置
pip config list -v
```

如果输出里有类似 `global.index-url = http://127.0.0.1:xxxx` 或 `global.proxy` 的内容，那就是配置问题。

**修复步骤：**

```bash
# 1. 编辑或删除 pip 配置文件（根据上面 -v 输出的路径，通常是 ~/.config/pip/pip.conf 或 ~/.pip/pip.conf）
nano ~/.config/pip/pip.conf

# 2. 把里面的 index-url 改成官方源，或者直接删除整个文件恢复默认
```

如果文件里有 `[global]` 段配置了 `index-url = http://127.0.0.1:...`，改成：

```ini
[global]
index-url = https://pypi.org/simple
```

或者直接用命令重置：

```bash
pip config unset global.index-url
pip config unset global.proxy
pip config unset global.trusted-host
```

改完后重试：

```bash
pip install -r requirements.txt
```

如果 `pyftpdlib` 仍然装不上（这个包在 requirements.txt 里可能是可选依赖），也可以先跳过它看看程序能不能跑：

```bash
pip install -r requirements.txt --no-deps
# 或者手动装其他依赖，跳过 pyftpdlib
```

你先执行 `pip config list -v` 看看输出是什么？

---

### 🧑 用戶
*2026-05-04T09:59:03.308920Z*

z@PC-20260425YEDW:~$ cd /mnt/c/Users/lz.PC-20260425YEDW.000/Desktop/xmir-patcher-main/xmir-patcher-main
pip install -r requirements.txt
bash run.sh
Defaulting to user installation because normal site-packages is not writeable
Ignoring ssh2-python: markers 'python_version >= "3.12"' don't match your environment
Requirement already satisfied: charset_normalizer in /home/lz/.local/lib/python3.10/site-packages (from -r requirements.txt (line 1)) (3.4.7)
Requirement already satisfied: idna in /usr/lib/python3/dist-packages (from -r requirements.txt (line 2)) (3.3)
Requirement already satisfied: urllib3 in /usr/lib/python3/dist-packages (from -r requirements.txt (line 3)) (1.26.5)
Requirement already satisfied: certifi in /home/lz/.local/lib/python3.10/site-packages (from -r requirements.txt (line 4)) (2026.4.22)
Requirement already satisfied: requests in /home/lz/.local/lib/python3.10/site-packages (from -r requirements.txt (line 5)) (2.33.1)
WARNING: Retrying (Retry(total=4, connect=None, read=None, redirect=None, status=None)) after connection broken by 'ConnectTimeoutError(<pip._vendor.urllib3.connection.HTTPSConnection object at 0x74bddfce5270>, 'Connection to 127.0.0.1 timed out. (connect timeout=15)')': /simple/pyftpdlib/
WARNING: Retrying (Retry(total=3, connect=None, read=None, redirect=None, status=None)) after connection broken by 'ConnectTimeoutError(<pip._vendor.urllib3.connection.HTTPSConnection object at 0x74bddfce5150>, 'Connection to 127.0.0.1 timed out. (connect timeout=15)')': /simple/pyftpdlib/
WARNING: Retrying (Retry(total=2, connect=None, read=None, redirect=None, status=None)) after connection broken by 'ConnectTimeoutError(<pip._vendor.urllib3.connection.HTTPSConnection object at 0x74bddfce6ec0>, 'Connection to 127.0.0.1 timed out. (connect timeout=15)')': /simple/pyftpdlib/
WARNING: Retrying (Retry(total=1, connect=None, read=None, redirect=None, status=None)) after connection broken by 'ConnectTimeoutError(<pip._vendor.urllib3.connection.HTTPSConnection object at 0x74bddfce7010>, 'Connection to 127.0.0.1 timed out. (connect timeout=15)')': /simple/pyftpdlib/
WARNING: Retrying (Retry(total=0, connect=None, read=None, redirect=None, status=None)) after connection broken by 'ConnectTimeoutError(<pip._vendor.urllib3.connection.HTTPSConnection object at 0x74bddfce50c0>, '

---

