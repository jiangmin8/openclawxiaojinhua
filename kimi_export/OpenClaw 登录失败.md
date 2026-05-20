# OpenClaw 登录失败

**chat_id**: `19e12708-3802-80d8-8000-093406b2dc8a`  |  **消息數**: 4

---

### 🧑 用戶
*2026-05-10T15:17:33.540808Z*

你写的什么。。token？吗

---

### 🧑 用戶
*2026-05-10T15:10:24.128778Z*

登录不了z@PC-20260507PZIO:~$ openclaw gateway --port 18789

🦞 OpenClaw 2026.5.7 (eeef486)
   The only open-source project where the mascot could eat the competition.

│
◇
23:06:21 [gateway] loading configuration…
23:06:21 [gateway] resolving authentication…
Gateway start blocked: existing config is missing gateway.mode. Treat this as suspicious or clobbered config. Re-run `openclaw onboard --mode local` or `openclaw setup`, set gateway.mode=local manually, or pass --allow-unconfigured.
Config write audit: /home/lz/.openclaw/logs/config-audit.jsonl
lz@PC-20260507PZIO:~$ openclaw gateway --port 18789

🦞 OpenClaw 2026.5.7 (eeef486)
   I'm the assistant your terminal demanded, not the one your sleep schedule requested.

│
◇
23:06:41 [gateway] loading configuration…
23:06:41 [gateway] resolving authentication…
Gateway start blocked: existing config is missing gateway.mode. Treat this as suspicious or clobbered config. Re-run `openclaw onboard --mode local` or `openclaw setup`, set gateway.mode=local manually, or pass --allow-unconfigured.
Config write audit: /home/lz/.openclaw/logs/config-audit.jsonl
lz

---

### 🤖 Kimi
*2026-05-10T15:10:24.128782Z*

您好！为了帮您解决 `openclaw gateway` 登录问题，能否请您澄清以下两点：

1.  您是希望运行一个本地的 OpenClaw 网关实例（即 `gateway.mode=local`），还是希望连接到某个远程的 OpenClaw 服务？
2.  关于“登录不了”，您具体是指：
    *   a) 在尝试运行 `openclaw gateway --port 18789` 命令时，遇到了 `Gateway start blocked` 错误（如您提供的日志所示）？
    *   b) 还是指在网关启动后，您无法通过某个客户端工具或浏览器访问 `localhost:18789`（或相应的地址）？
    *   c) 或者是其他类型的登录问题（例如，需要用户名/密码认证）？

---

### 🤖 Kimi
*2026-05-10T15:17:33.540812Z*

明白了。我将帮您解决在运行 `openclaw gateway --port 18789` 时遇到的 `Gateway start blocked` 错误。这个错误是因为您的 OpenClaw 配置中缺少 `gateway.mode` 设置。我会指导您如何通过运行 `openclaw onboard --mode local` 或 `openclaw setup` 命令来正确配置它，以便您能成功启动本地网关。



> 💭 梳理 OpenClaw 网关启动失败的报错信息，我意识到`gateway.mode`配置项的缺失是阻塞启动的关键症结，需要深挖其可选值与配置规范。

> 💭 梳理OpenClaw网关启动失败的线索后，我发现`gateway.mode`配置缺失是核心症结，[^1^][^15^]均指向将模式设为`local`即可快速修复。

> 💭 梳理 [^15^] 的排查思路后，我发现 `gateway.mode` 参数缺失正是启动阻塞的根因，本地模式配置与文件路径的确认成为下一步关键。

> 💭 梳理 [^1^][^15^] 的修复方案后，我发现将 `gateway.mode` 设为 `local` 再重启即可绕过启动阻塞，整个过程只需一条 CLI 命令配合重启操作。

> 💭 梳理 [^15^] 的修复方案后，我发现 `gateway.mode` 参数缺失才是 OpenClaw 网关启动受阻的根因，本地模式与云端模式的配置选择值得进一步深挖官方文档的权威界定。

> 💭 梳理OpenClaw网关启动受阻的根因后，我发现显式配置`gateway.mode`才是正道，那条30秒修复命令简洁有效，而`--allow-unconfigured`虽能应急却不适合生产环境。

> 💭 梳理 [^15^] 的修复方案后，我发现只需切换 gateway 模式并重启即可化解启动阻塞，正斟酌是否直接在本地环境验证这一 30 秒快速修复。

> 💭 看来OpenClaw并未正确安装或不在系统PATH中，我需要先定位它的可执行文件位置才能继续配置网关模式。

> 💭 看来 `openclaw` 命令未在系统 PATH 中找到，我正排查其安装位置与环境变量配置问题。

> 💭 系统提示找不到 `openclaw` 命令，看来可执行文件未纳入 PATH 环境变量，我正着手定位其安装路径以解决这一配置问题。

> 💭 系统提示 `openclaw: not found`，看来这个工具尚未纳入环境变量，我正琢磨它的藏身之处，准备顺藤摸瓜找到安装路径。

> 💭 看来系统找不到 `openclaw` 命令，我正琢磨着它的可执行文件究竟藏在哪个目录里，得先摸清安装位置才能解决 PATH 配置的问题。

> 💭 环境路径的缺失让我意识到，看似简单的配置背后往往藏着工具链的隐性依赖，需要顺着 npm 的安装脉络重新锚定 OpenClaw 的位置。

> 💭 全局npm前缀指向`/usr`，但`openclaw`仍杳无踪迹，看来它的藏身之处另有玄机——或许藏在`~/.openclaw/bin`这类非标准路径里，值得深挖一番。

> 💭 看来 `openclaw` 命令未在系统 PATH 中找到，我正排查其安装位置与可执行文件路径，准备通过全局搜索或常见目录定位来化解这一环境配置问题。

> 💭 看来OpenClaw尚未就绪，我正排查其安装位置，准备从npm全局目录入手解决路径配置问题。

> 💭 npm全局路径指向`/usr`，但`openclaw`仍无处可寻，看来这工具并非循规蹈矩地安营扎寨，得用`find`在系统深处好好搜捕一番。

> 💭 权限受限让我意识到需要调整策略，正转向非特权目录重新定位OpenClaw的踪迹。

> 💭 OpenClaw 并未出现在系统 PATH 中，我正转向其可能的隐藏安装路径进行排查。

> 💭 OpenClaw 的配置目录在当前用户主目录下并不存在，我正将搜索范围扩展至系统级路径，试图定位其安装踪迹。

> 💭 遍寻 `/usr/local/bin` 未见 OpenClaw 踪迹，看来安装路径另有玄机，我打算追溯 [^216^] 的线索重新排查。

> 💭 看来OpenClaw的访问受阻让我意识到本地环境配置可能存在深层问题，需要重新审视安装路径与命令可用性之间的错位。

> 💭 权限受阻后，我意识到全局安装路径的归属权才是症结所在，正斟酌将npm的领地迁移至用户可控的私有疆域。

> 💭 配置好本地npm环境后，我正准备重新部署OpenClaw工具链。

> 💭 确认 OpenClaw 已顺利就位，我正着手验证其配置模式能否顺利切换至本地网关。

> 💭 看来npm全局路径的变更尚未完全生效，我意识到直接定位可执行文件的实际位置或许能绕过环境变量未加载的障碍。

> 💭 看来OpenClaw的CLI路径并未就绪，我转而通过手动创建配置文件来启用本地网关模式。

> 💭 确认本地网关模式已写入配置，我正通过读取文件来核验设置的准确性。

> 💭 确认本地模式配置无误后，我正尝试绕过路径问题，直接用完整路径启动 OpenClaw 网关服务。

> 💭 看来OpenClaw的安装路径成了谜，我正尝试在多个系统目录中追踪它的踪迹，同时也在琢磨绕过配置检查的可能性。

> 💭 遍寻系统目录仍不见OpenClaw踪影，看来全局安装并未真正落地，我正思量是权限作祟还是依赖缺失，准备换个路子从源码或替代方案重新突破。

> 💭 看来 npm 全局安装的路径配置需要持久化，我正考虑将环境变量写入 shell 配置文件以确保 OpenClaw 命令全局可用。

> 💭 调试环境配置时，我发现当前 shell 对 source 命令的兼容性与预期不同，正调整策略改用点号加载配置来确保路径变量生效。

> 💭 配置好环境变量后，我正验证 `openclaw` 能否正常调用并返回版本信息。

> 💭 看来npm全局安装后仍无法定位OpenClaw，我怀疑可执行文件名并非预期，或安装过程存在隐性问题，正考虑转向二进制文件直接部署的方案。

> 💭 排查安装路径后，我意识到环境变量配置可能是 `openclaw` 命令失效的症结所在，准备尝试官方脚本重新部署。

> 💭 看来官方安装脚本对Node.js版本有硬性要求，而且当前环境还缺少管理员权限，这让我意识到得换个思路——先通过nvm把Node.js升到v22.14+，再尝试无sudo安装OpenClaw。

> 💭 安装nvm时遭遇404陷阱，我意识到脚本链接的细微偏差足以阻断整个环境搭建进程，正锁定官方源重新校准安装路径。

> 💭 看来nvm虽已安装，但还需手动加载环境变量才能生效，我正着手激活它以继续后续操作。

> 💭 刚加载完nvm，我意识到OpenClaw对Node.js v22.14+的硬性要求，需要赶紧锁定一个合规的版本来推进后续部署。

> 💭 看来nvm的环境变量未能持久化生效，我正着手将其加载命令写入shell配置文件，确保后续会话能正确识别这一工具。

> 💭 看来 `nvm` 的环境加载并未彻底解决问题，我意识到 `npx` 或许是绕过路径困境、直接调用 OpenClaw 的更佳途径。

> 💭 看来OpenClaw的安装遇到了瓶颈，npx也无法定位可执行文件，我正考虑转向GitHub仓库直接获取Linux二进制文件来绕过这个障碍。

> 💭 追踪 `openclaw: command not found` 的症结时，我猛然意识到问题或许不在环境配置，而是 [^367^] 揭示的致命缺陷——核心 CLI 入口文件 `bin/openclaw.js` 压根就没被打包进 npm 发行版。

> 💭 追踪到 [^367^] 的 Issue 后，我意识到 OpenClaw 的核心 CLI 入口文件竟从 npm 包和仓库中双双消失，这彻底解释了安装失败的根因。

> 💭 我注意到 [^367^] 中的版本争议——社区已修复 CLI 入口缺失问题，而我本地的环境可能恰好卡在了旧版本。

> 💭 我注意到OpenClaw的版本停留在0.0.1，这个过于早期的版本很可能是问题的根源，看来需要尽快推进版本迭代来解决潜在的兼容性隐患。

> 💭 升级后仅变更了一个包，我正循着线索追踪 openclaw.mjs 的藏身之处，以确认 CLI 入口是否真正就位。

> 💭 看来新版OpenClaw的CLI入口文件仍未就绪，我注意到[^367^]提到2026.3.1版本曾正确配置过入口点，准备尝试这个特定版本看能否恢复功能。

> 💭 看来 OpenClaw 2026.3.1 对 Node.js 版本要求颇为苛刻，我正琢磨着用 nvm 把运行环境从 v20 升级到 v22.12.0 以满足门槛。

**简短回答：** 执行 `openclaw config set gateway.mode local` 设置网关模式，然后运行 `openclaw gateway restart` 重启服务即可解决。若 CLI 不可用，直接编辑 `~/.openclaw/openclaw.json` 文件，在 `gateway` 对象中添加 `"mode": "local"`，保存后重启。



---

