# snapshot-context.ps1
# 用途：备份 context.md（并可选备份 agent/tools/user/CHANGELOG），写审计日志

$base = 'C:\Users\lz\Desktop\12'
$context = Join-Path $base 'context.md'
$backupRoot = Join-Path $base '.backups'
if (!(Test-Path $backupRoot)) { New-Item -ItemType Directory -Path $backupRoot | Out-Null }
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$dest = Join-Path $backupRoot $timestamp
New-Item -ItemType Directory -Path $dest | Out-Null

if (Test-Path $context) {
    Copy-Item -Path $context -Destination (Join-Path $dest 'context.md') -Force
    foreach ($f in @('agent.md','tools.md','user.md','CHANGELOG.md')) {
        $p = Join-Path $base $f
        if (Test-Path $p) { Copy-Item -Path $p -Destination (Join-Path $dest $f) -Force }
    }

    $auditDir = Join-Path $base 'audit'
    if (!(Test-Path $auditDir)) { New-Item -ItemType Directory -Path $auditDir | Out-Null }
    $auditFile = Join-Path $auditDir ("backup_" + $timestamp + ".log")
    @("Timestamp: $(Get-Date -Format o)", "Action: context backup", "Source: $context", "Dest: $dest") | Out-File -FilePath $auditFile -Encoding utf8

    Write-Output "Backup created: $dest"
    exit 0
} else {
    Write-Error "context.md not found at $context"
    exit 1
}
