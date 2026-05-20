#!/usr/bin/env python3
"""
网段扫描 + HTTP服务发现 + 网页批量采集器
用途: 发现父母家局域网所有设备、Web服务、开放端口
"""

import subprocess, json, re, sys
from datetime import datetime

def sh(cmd):
    r = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=30)
    return r.stdout + r.stderr

def scan_network(prefix):
    """扫一个网段所有活跃IP"""
    print(f"[扫描] 正在扫 {prefix}.0/24...")
    try:
        r = subprocess.run(f"nmap -sn {prefix}.0/24", shell=True,
                          capture_output=True, text=True, timeout=60)
        ips = re.findall(r"Nmap scan report for (\d+\.\d+\.\d+\.\d+)", r.stdout)
        macs = re.findall(r"MAC Address: ([0-9A-F:]{17})", r.stdout.upper())
        print(f"  找到 {len(ips)} 个设备在线")
        for i, ip in enumerate(ips):
            mac = macs[i] if i < len(macs) else "未知"
            try:
                host = subprocess.run(f"nslookup {ip} 2>/dev/null | grep name",
                                     shell=True, capture_output=True, text=True).stdout.strip()
                hostname = host.split("=")[-1].strip().rstrip(".") if host else ""
            except:
                hostname = ""
            print(f"  {ip}  {mac}  {hostname}")
        return ips
    except Exception as e:
        print(f"  扫描失败: {e}")
        return []

def web_check(ip):
    """检查一个IP有没有HTTP服务"""
    import urllib.request
    for port in [80, 8080, 443, 8443]:
        try:
            proto = "https" if port in [443, 8443] else "http"
            r = urllib.request.urlopen(f"{proto}://{ip}:{port}", timeout=3)
            title_match = re.search(r"<title>(.*?)</title>", r.read().decode("utf-8", errors="ignore"), re.I)
            title = title_match.group(1).strip()[:60] if title_match else "(无标题)"
            print(f"  {ip}:{port} → {title}")
            return True
        except:
            pass
    return False

if __name__ == "__main__":
    target = sys.argv[1] if len(sys.argv) > 1 else "192.168.10"
    
    print("╔══════════════════════════════════╗")
    print("║ 网络扫描 + Web发现 工具          ║")
    print("╚══════════════════════════════════╝")
    print(f"时间: {datetime.now().strftime('%H:%M:%S')}\n")
    
    ips = scan_network(target)
    
    print(f"\n[Web探测] 检查HTTP服务...")
    web_count = 0
    for ip in ips:
        if web_check(ip):
            web_count += 1
    
    print(f"\n[总结] 在线 {len(ips)} 台 · HTTP服务 {web_count} 个")
    print("[完成] 发现的所有IP在上面列表中")
