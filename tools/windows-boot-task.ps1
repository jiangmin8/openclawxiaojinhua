# Windows 开机自启脚本
# 由雅典娜创建 — 以管理员身份运行一次即可

Write-Host "正在创建开机自启任务..." -ForegroundColor Cyan

# 1. Tailscale 开机自启
sc.exe config Tailscale start=auto
sc.exe start Tailscale

# 2. WSL2 开机自启 + 启动 OpenClaw Gateway
$action = New-ScheduledTaskAction -Execute "wsl.exe" -Argument "-d Ubuntu -u lz -- exec systemctl --user restart openclaw-gateway"
$trigger = New-ScheduledTaskTrigger -AtStartup -RandomDelay "00:01:00"
$principal = New-ScheduledTaskPrincipal -UserId "lz" -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Register-ScheduledTask -TaskName "OpenClaw_WSL_Gateway" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force

Write-Host "完成！下次重启 PC 后自动生效。" -ForegroundColor Green
Write-Host "任务名: OpenClaw_WSL_Gateway" -ForegroundColor Gray
