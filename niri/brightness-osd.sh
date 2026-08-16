#!/bin/sh

set -eu

action=${1:-}
set -- /sys/class/backlight/*
backlight_path=$1

if [ ! -d "$backlight_path" ]; then
    notify-send --urgency=critical --expire-time=2500 \
        'Brightness OSD' 'No backlight device was found'
    exit 1
fi

device=${backlight_path##*/}
current=$(sed -n '1p' "$backlight_path/brightness")
maximum=$(sed -n '1p' "$backlight_path/max_brightness")
step=$(( (maximum + 19) / 20 ))
minimum=$(( (maximum + 99) / 100 ))

case "$action" in
    up)
        target=$((current + step))
        [ "$target" -le "$maximum" ] || target=$maximum
        ;;
    down)
        target=$((current - step))
        [ "$target" -ge "$minimum" ] || target=$minimum
        ;;
    *)
        echo "Usage: $0 {up|down}" >&2
        exit 2
        ;;
esac

# logind safely grants the active graphical session access to its backlight.
busctl call \
    org.freedesktop.login1 \
    /org/freedesktop/login1/session/auto \
    org.freedesktop.login1.Session \
    SetBrightness ssu backlight "$device" "$target" >/dev/null

percent=$(( (target * 100 + maximum / 2) / maximum ))

if [ "$percent" -lt 34 ]; then
    icon='display-brightness-low-symbolic'
elif [ "$percent" -lt 67 ]; then
    icon='display-brightness-medium-symbolic'
else
    icon='display-brightness-high-symbolic'
fi

notify-send \
    --app-name='Brightness OSD' \
    --urgency=low \
    --expire-time=1200 \
    --transient \
    --icon="$icon" \
    --hint=string:x-dunst-stack-tag:brightness-osd \
    --hint=int:value:"$percent" \
    'Brightness' "${percent}%"
