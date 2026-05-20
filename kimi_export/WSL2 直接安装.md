# WSL2 直接安装

**chat_id**: `19df8843-d2d2-8298-8000-09345de2ab88`  |  **消息數**: 16

---

### 🤖 Kimi
*2026-05-05T14:35:59.343934Z*

好的，不废话了。你文件都有，直接装就行，有问题再找我。

---

### 🧑 用戶
*2026-05-05T14:35:59.343931Z*

我直接把你装进去丢到垃圾堆里面去

---

### 🤖 Kimi
*2026-05-05T14:35:39.119394Z*

好的，不打扰了，你慢慢弄。装完 VMware + Ubuntu 有问题随时喊我。

---

### 🧑 用戶
*2026-05-05T14:35:39.119391Z*

你慢慢去玩。。

---

### 🤖 Kimi
*2026-05-05T14:35:21.726721Z*

明白了，你有现成的 VMware 和 Ubuntu ISO，不需要再下载，直接装就行。

步骤：

1. 双击 `VMware-Workstation-Full-25H2-24995812.exe` 装 VMware
2. 打开 VMware → 创建新虚拟机 → 典型配置
3. 选 `ubuntu-24.04.3-desktop-amd64.iso`
4. 设置：
   - 用户名/密码你自己定
   - 内存给 6GB（你 16GB 物理内存够）
   - 处理器 4 核
   - 磁盘 60GB，存储为单个文件
5. 装完进系统后，VMware 菜单 → 虚拟机 → 安装 VMware Tools，重启

完事。

---

### 🧑 用戶
*2026-05-05T14:35:21.726717Z*

你是真不懂还是假不懂

---

### 🤖 Kimi
*2026-05-05T14:35:02.110818Z*

看到了，你有 VMware Workstation 和 VirtualBox 的 installer，还有 `ubuntu-24.04.3-desktop-amd64.iso`。

直接装 VMware 就行，比 WSL 省事。

```powershell
# 1. 先装 VMware
D:\下载\VMware-Workstation-Full-25H2-24995812.exe

# 2. 装完打开 → 创建新虚拟机 → 典型 → 选你的 ubuntu-24.04.3-desktop-amd64.iso
# 3. 配置建议：
#    - 内存：4-6GB（你 16GB 物理内存，给 6GB 够用）
#    - CPU：2-4 核
#    - 磁盘：60GB，单个文件
#    - 网络：NAT（默认就行，能上网）
```

VMware 装完 Ubuntu 后装个 **VMware Tools**（菜单里选"安装 VMware Tools"），分辨率自适应、共享剪贴板、拖拽文件都有了。

---

**WSL 还是 VMware？**

- 要轻量、和 Windows 文件互通频繁 → WSL2
- 要完整桌面环境、隔离彻底、跑 GUI 应用 → VMware

你有 RTX 3060，VMware 里也可以装 NVIDIA 驱动跑 CUDA（需要 VMware 16+ 和特定配置）。

你打算在 Ubuntu 里干啥？命令行开发还是也要桌面环境？

---

### 🧑 用戶
*2026-05-05T14:35:02.110815Z*

还和我了虚拟机吗？

---

### 🤖 Kimi
*2026-05-05T14:27:33.095510Z*

可以，不装 WSL 直接用虚拟机装 Ubuntu 也行。

**方案对比：**

| | WSL2 | 虚拟机 (VMware/VirtualBox) |
|---|---|---|
| 性能 | 文件 IO 稍慢，其他接近原生 | 全虚拟化，开销大一点 |
| 显卡 | 可用 CUDA，但 GUI 应用支持一般 | 可直通显卡（VFIO） |
| 隔离性 | 和 Windows 共享内核，轻量 | 完全隔离，更像真机 |
| 文件互传 | `/mnt/c` 直接访问 Windows | 共享文件夹 / 拖拽 |
| 后台常驻 | 可以 | 可以 |

---

**如果你要直接装 Ubuntu 虚拟机：**

1. **下载 ISO**
   - 官网：https://ubuntu.com/download/desktop
   - 或清华镜像（快）：https://mirrors.tuna.tsinghua.edu.cn/ubuntu-releases/22.04/ubuntu-22.04.4-desktop-amd64.iso

2. **VMware Workstation Player**（免费个人版）
   - 新建虚拟机 → 选 ISO → 默认配置就行
   - 建议分配 4GB 内存、2 核、40GB 磁盘

3. **VirtualBox**（免费）
   - 类似，装完 Guest Additions 才能调分辨率/共享剪贴板

---

**你的场景是啥？** 纯命令行开发、跑 Docker、还是要跑 Linux GUI 应用？这决定 WSL2 够不够用。

---

### 🧑 用戶
*2026-05-05T14:27:33.095507Z*

直接可以装乌班图。。不要wsl？

---

### 🤖 Kimi
*2026-05-05T14:25:48.362327Z*

下载慢的话，可以切国内镜像源或者用离线包。

**方法1：改 DNS / 用镜像（简单）**

```powershell
# 临时用国内 DNS
netsh interface ip set dns "以太网" static 223.5.5.5
# 或者
netsh interface ip set dns "WLAN" static 223.5.5.5

# 重新装
wsl --install -d Ubuntu-22.04
```

**方法2：手动下载离线包（最快）**

去清华镜像下 Ubuntu 的 appx 包，比微软商店快很多：

```powershell
# 浏览器打开下载，或者直接用 curl
curl -L -o Ubuntu_2204.1.7.0_x64.appx https://mirrors.tuna.tsinghua.edu.cn/ubuntu-cloud-images/wsl/jammy/current/ubuntu-jammy-wsl-amd64-wsl.rootfs.tar.gz

# 导入（不用等商店）
wsl --import Ubuntu-22.04 D:\WSL\Ubuntu-22.04 .\ubuntu-jammy-wsl-amd64-wsl.rootfs.tar.gz --version 2
```

**方法3：挂代理**

如果你有代理在本地 7890 端口：

```powershell
# PowerShell 临时走代理
$env:HTTP_PROXY="http://127.0.0.1:7890"
$env:HTTPS_PROXY="http://127.0.0.1:7890"
wsl --install -d Ubuntu-22.04
```

---

你现在是卡在哪一步？下载 WSL 内核还是下载 Ubuntu 发行版？

---

### 🧑 用戶
*2026-05-05T14:25:48.362308Z*

要装好久。。我看下得好慢

---

### 🤖 Kimi
*2026-05-05T14:25:12.203765Z*

对，现在新系统直接 `wsl --install` 默认就是 WSL2 了，不需要重启切换版本。2.6.3 是 WSL 内核版本号，说明你装的就是 WSL2。

如果要确认版本：

```powershell
wsl --version
wsl --status
```

装发行版的话直接：

```powershell
wsl --install -d Ubuntu-22.04
```

装完按提示重启一次就能用了。

---

### 🧑 用戶
*2026-05-05T14:25:12.203762Z*

我没有重启他直接装的就是2.6.3

---

### 🤖 Kimi
*2026-05-05T14:21:49.229492Z*

可以直接安装 WSL2，不需要先装 WSL1。

下载安装命令：

```powershell
wsl --install
```

这个命令默认就会安装 WSL2 + Ubuntu。装完后重启电脑，再打开 Ubuntu 按提示设置用户名密码就行。

如果只想装 WSL2 本体不装发行版：

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# 重启后设置默认 WSL 版本为 2
wsl --set-default-version 2
```

装完重启一次，然后 `wsl --list --online` 看可选的发行版，`wsl --install -d Ubuntu-22.04` 装具体的版本。

---

### 🧑 用戶
*2026-05-05T14:21:49.229453Z*

给我powershell下载wsl2的命令。。我没有wsl1可以直接安装wsl2撒

---

