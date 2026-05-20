# OpenClaw 清理重装

**chat_id**: `19e02343-88f2-8474-8000-0934aff70829`  |  **消息數**: 20

---

### 🤖 Kimi
*2026-05-07T12:31:31.072042Z*

你说的是 **Copilot** 那些 AI 扩展吧？

---

**不需要装**，对你没用。

---

**你现在只需要装一个扩展**

| 扩展 | 干嘛的 | 要不要装 |
|---|---|---|
| **Remote - WSL** | 连 WSL2 Ubuntu | ✅ **必须装** |
| Copilot / Copilot Chat | GitHub 的 AI 编程助手 | ❌ 不装 |
| 其他 AI 扩展 | 各种代码补全 | ❌ 不装 |

---

**装 WSL 扩展步骤**

1. VS Code 左侧四个方块图标（扩展）
2. 搜 `Remote - WSL`
3. 找到微软官方的，点 **安装**

装完左下角出现 **绿色图标**（>< 形状），点它就能连你的 Ubuntu。

---

**Copilot 那个弹窗**

直接点 **X** 关掉，或者点 **Back** → **Get Started** 随便走一遍然后关掉，以后不会再弹。

---

**你现在进度**

- ✅ VS Code 装好了
- ⏳ 装 WSL 扩展
- ⏳ 连 WSL，清理 yadianna，重新克隆 OpenClaw

先装 WSL 扩展，装完告诉我。

---

### 🧑 用戶
*2026-05-07T12:31:31.072039Z*

这个AI什么东西扩展这些抓不抓吧。

---

### 🤖 Kimi
*2026-05-07T12:31:03.970472Z*

**VS Code 已经装好了**，这是 VS Code 的 **Copilot Chat** 欢迎界面，不是安装卡死。

---

**你之前看到的"卡住"其实是装完了自动打开了 VS Code**，然后弹出这个 Copilot 引导窗口。

---

**现在需要做的**

1. **点左下角 X 关掉这个 Copilot 弹窗**
2. 或者点 **"Back"** 退出引导

---

**然后装 WSL 扩展**

1. 左侧四个方块图标（扩展）
2. 搜 `Remote - WSL`
3. 点安装

装完左下角会有绿色图标，点它连 WSL。

---

**验证安装**

```powershell
code --version
```

有版本号 = 完全搞定，可以开始搞 OpenClaw 了。

你 `code --version` 跑一下？

---

### 🧑 用戶
*2026-05-07T12:31:03.970469Z*

*[無內容]*

---

### 🤖 Kimi
*2026-05-07T12:26:04.345693Z*

**查硬盘和系统日志，看卡在哪个环节。**

---

**先看硬盘是不是满了或出问题了**

```powershell
# 管理员 PowerShell 执行
Get-PSDrive C | Select-Object Used,Free
# 看 C 盘剩余空间，低于 5GB 就可能卡

wmic diskdrive get status
# 看硬盘健康状态，正常应该输出 OK
```

---

**再看系统事件日志，找安装报错**

```powershell
# 查最近 10 分钟的应用程序错误
Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=(Get-Date).AddMinutes(-10)} | 
    Where-Object {$_.Message -like "*code*" -or $_.Message -like "*install*"} | 
    Select-Object TimeCreated, LevelDisplayName, Message
```

---

**最可能的原因**

| 情况 | 表现 |
|---|---|
| **C 盘满了** | 安装解压到一半没空间，卡住不动 |
| **硬盘有坏块** | 写入某个文件时 IO 卡死 |
| **杀毒软件拦截** | 实时监控扫描安装包，拖慢或锁死 |
| **Windows Update 后台占用** | 系统更新和安装程序抢资源 |

---

**你先跑前两个命令**，把输出贴给我：

1. C 盘还剩多少空间？
2. 硬盘状态是不是 OK？
3. 事件日志里有没有报错？

---

**同时临时关杀毒试试**

右下角杀毒图标 → 右键 → **暂停保护 10 分钟**，然后重新运行安装包。

先查硬盘，再关杀毒，看还卡不卡。

---

### 🧑 用戶
*2026-05-07T12:26:04.345690Z*

管理员身份也在这里卡住了，是不是他妈的？呃，查什么东西哦？

---

### 🤖 Kimi
*2026-05-07T12:25:21.568474Z*

确实，残留太多了，三次都卡同一个地方。

**直接彻底清干净再装。**

---

**强力清理（管理员 PowerShell）**

```powershell
# 1. 结束所有相关进程
Get-Process *code*,*setup*,*installer* | Stop-Process -Force -ErrorAction SilentlyContinue

# 2. 删除所有 VS Code 残留目录
$paths = @(
    "C:\Users\$env:USERNAME\AppData\Local\Programs\Microsoft VS Code",
    "C:\Users\$env:USERNAME\AppData\Local\Programs\VS Code",
    "C:\Program Files\Microsoft VS Code",
    "C:\Program Files\VS Code",
    "C:\Users\$env:USERNAME\AppData\Roaming\Code",
    "C:\Users\$env:USERNAME\AppData\Local\Code"
)
foreach ($p in $paths) {
    Remove-Item -Recurse -Force $p -ErrorAction SilentlyContinue
}

# 3. 删除微软商店残留（关键）
Get-AppxPackage *vscode* | Remove-AppxPackage -ErrorAction SilentlyContinue

# 4. 确认干净了
Get-ChildItem "C:\Users\$env:USERNAME\AppData\Local\Programs\" | Select-String "VS Code|Code"
# 没输出 = 干净了
```

---

**然后重启电脑**

注销不够，必须重启，把系统里卡死的安装服务彻底清掉。

---

**重启完**

1. 右键安装包 → **以管理员身份运行**
2. 只勾这两个：
   - [x] 注册为文件编辑器
   - [x] 添加到 PATH
3. 下一步，应该秒过

---

跑完清理命令，重启，再装。这次再卡就是见鬼了。

---

### 🧑 用戶
*2026-05-07T12:25:21.568471Z*

我都装了3次了，里面是不是东西超鸡巴多哟？那些垃圾。

---

### 🤖 Kimi
*2026-05-07T12:24:22.961399Z*

**直接管理员身份运行**，别折腾了。

---

**操作**

1. 找到你下载的安装包 `VSCodeUserSetup-x64-xxx.exe`
2. **右键** → **以管理员身份运行**
3. 勾选选项和之前一样，下一步

---

**原因**

你系统里可能有之前微软商店安装的残留权限锁，普通用户身份打不开。管理员直接绕过去。

---

**装完验证**

```powershell
code --version
```

有版本号 = 搞定，然后装 WSL 扩展。

---

管理员身份试一次，看还卡不卡。

---

### 🧑 用戶
*2026-05-07T12:24:22.961396Z*

我又重新装他那里，又卡在那一步了。

---

### 🤖 Kimi
*2026-05-07T12:22:14.646789Z*

不需要，普通用户安装就行。

**原因**

- 你选的是 **User 安装版**（`VSCodeUserSetup`），默认装到用户目录 `AppData\Local\`，不需要管理员权限
- 管理员身份反而可能搞乱权限，WSL 连进来读写文件出问题

---

**现在卡的原因**

大概率是之前微软商店那个残留进程还在后台占着安装锁，不是权限问题。

---

**操作**

1. 任务管理器 → 结束那个 `安装 - Microsoft Visual Studio...`
2. 同时把 `Setup/Uninstall (32位)` 也结束掉
3. 重新双击安装包，**不要右键管理员运行**

---

**如果还是卡**

再考虑管理员身份，但先按正常流程试一次。M.2 装这个真不该超过 30 秒。

结束任务了没？

---

### 🧑 用戶
*2026-05-07T12:22:14.646786Z*

我觉得这个是不是要用管理员身份安装哦？

---

### 🤖 Kimi
*2026-05-07T12:21:57.262319Z*

不用清注册表，直接结束任务重新装就行。

**操作**

1. 任务管理器 → 右键 `安装 - Microsoft Visual Studio...` → **结束任务**
2. 重新双击官网下载的安装包

M.2 硬盘装这个 10 秒的事，结束任务重装最快。

---

**如果重装还卡**

再考虑清残留，但先别动注册表：

```powershell
# 只删安装目录，不动注册表
Remove-Item -Recurse -Force "C:\Users\$env:USERNAME\AppData\Local\Programs\Microsoft VS Code" -ErrorAction SilentlyContinue
```

然后重装。

---

先结束任务，双击重装，看这次快不快。

---

### 🧑 用戶
*2026-05-07T12:21:57.262314Z*

是不是又要清一次注册表？

---

### 🤖 Kimi
*2026-05-07T12:18:38.564744Z*

M.2 SSD 的话 30 秒就该装完了，你这确实久了点。

**再等 1 分钟**，如果还没完：

1. 任务管理器里右键那个 `安装 - Microsoft Visual Studio...` → **结束任务**
2. 重新双击安装包再装一次

M.2 不可能卡这么久，大概率是微软商店残留进程还在干扰。杀完重装秒过。

---

### 🧑 用戶
*2026-05-07T12:18:38.564739Z*

我是M点2好不好。

---

### 🤖 Kimi
*2026-05-07T12:18:15.212311Z*

**没卡死，正常安装中。**

---

**看图判断**

任务管理器里显示：
- `安装 - Microsoft Visual Studio...` 还在运行
- CPU 0%、内存 185MB — 安装程序有时候就是这样，大部分时间是在解压/写入文件，CPU 占用不高

---

**等多久算正常**

VS Code 安装包 80MB 左右，解压+写入大概 **1-3 分钟**，取决于硬盘速度。

---

**别动它，等**

- 不要点取消
- 不要关任务管理器
- 不要注销/重启

---

**如果超过 5 分钟还没完**

```powershell
# 管理员 PowerShell 查看安装进程在干嘛
Get-Process *code* | Select-Object Name, CPU, WorkingSet
```

或者看任务管理器里那个进程的 **磁盘** 列有没有在动，有读写就是还在干活。

---

**你现在硬盘是什么？** 机械硬盘还是 SSD？SSD 应该 30 秒就完了，机械可能要等久一点。

---

### 🧑 用戶
*2026-05-07T12:18:15.212307Z*

我这个要安装，是不是卡死了哟？怎么半天都没结束？

---

### 🤖 Kimi
*2026-05-07T12:01:51.641032Z*

不需要，WSL2 Ubuntu 自带 Git，你之前克隆到 Windows 的那份没用，重新在 WSL 里克隆。

---

**操作步骤**

```bash
# 1. 确认 WSL 里有 Git
git --version

# 2. 删除 Windows 里的那份（没用）
rm -rf /mnt/c/Users/lz/你克隆的目录

# 3. 在 WSL 里重新克隆到正确位置
cd ~/yadianna
git clone https://github.com/openclaw/openclaw.git
cd openclaw
pnpm install
```

---

**原因**

- WSL 和 Windows 文件系统互通，但 **Node 项目在 WSL 里编译运行** 才正常
- Windows 路径下的项目，`pnpm install` 会出一堆权限和路径问题

---

**你现在只需要**

1. VS Code 装完，连 WSL
2. WSL 终端里跑上面的命令
3. 把之前 Windows 那份删了

VS Code 装好了吗？

---

### 🧑 用戶
*2026-05-07T12:01:51.641029Z*

我仓库已经用。Getub的桌面仓库版克隆到了Windows里面了。然后我的意思是，需不需要把Windows的get到Ubuntu里面？

---

