#!/bin/bash
# ==========================================
# RAX3000Me 刷机后快速配置脚本
# 用途: 刷完 OpenWrt 后一键配置基础网络
# 用法: 在路由器终端运行本脚本
# ==========================================
# 雅典娜准备 — 到父母家后通过 SSH 执行

echo "╔══════════════════════════════════╗"
echo "║  RAX3000Me 开荒配置              ║"
echo "╚══════════════════════════════════╝"

echo ""
echo "[1/5] 设置root密码"
passwd

echo ""
echo "[2/5] 开启SSH"
uci set dropbear.@dropbear[0].enable=1
uci set dropbear.@dropbear[0].PasswordAuth=on
uci set dropbear.@dropbear[0].RootPasswordAuth=on
uci commit dropbear
/etc/init.d/dropbear enable
/etc/init.d/dropbear restart
echo "  SSH已启用"

echo ""
echo "[3/5] 配置LAN（默认192.168.1.1）"
cat /etc/config/network | grep -A5 "config interface 'lan'"
echo ""
echo "  LAN的IP: $(uci get network.lan.ipaddr 2>/dev/null || echo 192.168.1.1)"

echo ""
echo "[4/5] 配置WiFi"
echo ""
uci set wireless.@wifi-device[0].disabled=0
uci set wireless.@wifi-device[1].disabled=0
uci set wireless.default_radio0.ssid="RAX3000Me-5G"
uci set wireless.default_radio1.ssid="RAX3000Me-2G"
uci commit wireless
wifi reload
echo "  WiFi已开启"

echo ""
echo "[5/5] 安装Tailscale"
opkg update
opkg install tailscale
/etc/init.d/tailscale enable
tailscale up
echo "  请访问登录连接..."

echo ""
echo "╔══════════════════════════════════╗"
echo "║  配置完成！                         ║"
echo "║  路由器: http://192.168.1.1         ║"
echo "║  SSH   : ssh root@192.168.1.1       ║"
echo "║  密码  : 你刚才设的                  ║"
echo "╚══════════════════════════════════╝"
