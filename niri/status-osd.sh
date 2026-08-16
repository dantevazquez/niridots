#!/bin/sh

set -eu

# -----------------------------------------------------------------------------
# 1. Date and Time
# -----------------------------------------------------------------------------
time_str=$(date "+%H:%M")
date_str=$(date "+%A, %B %-d, %Y")
summary="$time_str · $date_str"

# -----------------------------------------------------------------------------
# 2. Network Connection
# -----------------------------------------------------------------------------
net_info=""

if command -v nmcli >/dev/null 2>&1; then
    eth_conn=$(nmcli -t -f TYPE,STATE,CONNECTION dev status 2>/dev/null | grep '^ethernet:connected:' | head -n 1 | cut -d: -f3 || true)
    if [ -n "$eth_conn" ]; then
        net_info="Ethernet ($eth_conn)"
    else
        wifi_conn=$(nmcli -t -f TYPE,STATE,CONNECTION dev status 2>/dev/null | grep '^wifi:connected:' | head -n 1 | cut -d: -f3 || true)
        if [ -n "$wifi_conn" ]; then
            signal=$(nmcli -t -f active,signal dev wifi 2>/dev/null | grep '^yes:' | head -n 1 | cut -d: -f2 || true)
            if [ -n "$signal" ]; then
                net_info="$wifi_conn ($signal%)"
            else
                net_info="$wifi_conn"
            fi
        fi
    fi
fi

if [ -z "$net_info" ]; then
    default_iface=$(ip route 2>/dev/null | grep '^default' | awk '{print $5}' | head -n 1 || true)
    if [ -n "$default_iface" ]; then
        case "$default_iface" in
            wl*|wlan*|wld*)
                net_info="Wi-Fi ($default_iface)"
                ;;
            eth*|en*)
                net_info="Ethernet ($default_iface)"
                ;;
            *)
                net_info="Connected ($default_iface)"
                ;;
        esac
    else
        net_info="Disconnected"
    fi
fi

# -----------------------------------------------------------------------------
# 3. Battery
# -----------------------------------------------------------------------------
bat_info=""
bat_path=""
bat_pct=""
bat_status=""

for p in /sys/class/power_supply/*; do
    if [ -f "$p/type" ] && [ "$(cat "$p/type" 2>/dev/null)" = "Battery" ]; then
        bat_path="$p"
        break
    fi
done

if [ -n "$bat_path" ] && [ -f "$bat_path/capacity" ]; then
    bat_pct=$(cat "$bat_path/capacity" 2>/dev/null || echo "")
    bat_status=$(cat "$bat_path/status" 2>/dev/null || echo "")
    if [ -n "$bat_pct" ]; then
        if [ -n "$bat_status" ]; then
            bat_info="${bat_pct}% · ${bat_status}"
        else
            bat_info="${bat_pct}%"
        fi
    fi
fi

if [ -z "$bat_info" ] && command -v upower >/dev/null 2>&1; then
    bat_dev=$(upower -e 2>/dev/null | grep -i 'battery' | head -n 1 || true)
    if [ -n "$bat_dev" ]; then
        bat_pct=$(upower -i "$bat_dev" 2>/dev/null | grep 'percentage:' | awk '{print $2}' || true)
        bat_status=$(upower -i "$bat_dev" 2>/dev/null | grep 'state:' | awk '{print $2}' || true)
        if [ -n "$bat_pct" ]; then
            bat_info="${bat_pct} · ${bat_status}"
        fi
    fi
fi

if [ -z "$bat_info" ]; then
    bat_info="N/A"
fi

# -----------------------------------------------------------------------------
# 4. Notification output
# -----------------------------------------------------------------------------
body="Network: $net_info
Battery: $bat_info"

notify-send \
    --app-name='Status OSD' \
    --urgency=low \
    --expire-time=2500 \
    --transient \
    --hint=string:x-dunst-stack-tag:status-osd \
    "$summary" \
    "$body"
