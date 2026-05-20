#!/usr/bin/env python3
"""
RAX3000Me 路由器自动登录 + 信息爬取工具
用途: 刷机后自动登录OpenWrt、取信息、改配置
用法: python3 router_ctl.py <路由器IP> [命令]

命令:
  scan     → 扫开放端口
  info     → 取系统信息
  login    → 自动登录(需先配密码)
  wifi     → 获取WiFi状态
  reboot   → 重启路由器
"""

import urllib.request, json, sys, subprocess, re

BASE_URL = sys.argv[1] if len(sys.argv) > 1 else "http://192.168.1.1"
CMD = sys.argv[2] if len(sys.argv) > 2 else "info"

def sh(cmd):
    r = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=10)
    return r.stdout + r.stderr

def http_get(path):
    try:
        r = urllib.request.urlopen(f"{BASE_URL}{path}", timeout=5)
        return r.read().decode()
    except Exception as e:
        return f"[error] {e}"

if CMD == "scan":
    print(f"[扫描] {BASE_URL} 开放端口...")
    print(sh(f"nmap -p 22,80,443,8080,8443 {BASE_URL} 2>/dev/null"))

elif CMD == "info":
    print(f"[信息] 正在连 {BASE_URL}...\n")
    # 走SSH直连路由器看系统状态
    router_ip = re.search(r"(\d+\.\d+\.\d+\.\d+)", BASE_URL)
    if router_ip:
        result = sh(f"ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 root@{router_ip.group(1)} 'uname -a && uptime && free && df -h && iwinfo 2>/dev/null' 2>&1")
        print(result)
    else:
        print("无法解析IP")

elif CMD == "wifi":
    print(http_get("/cgi-bin/luci/admin/status/overview"))

elif CMD == "reboot":
    print("[重启] 正在重启路由器...")
    print(sh(f"ssh -o StrictHostKeyChecking=no root@{BASE_URL.strip('http://').strip('/')} reboot 2>&1"))

else:
    print(f"未知命令: {CMD}")
    print("可用命令: scan, info, wifi, reboot")
