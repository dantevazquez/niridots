#!/bin/sh

set -eu

sink='@DEFAULT_AUDIO_SINK@'
step=5

case "${1:-}" in
    up)
        wpctl set-volume -l 1.0 "$sink" "${step}%+"
        wpctl set-mute "$sink" 0
        ;;
    down)
        wpctl set-volume "$sink" "${step}%-"
        wpctl set-mute "$sink" 0
        ;;
    mute)
        wpctl set-mute "$sink" toggle
        ;;
    *)
        echo "Usage: $0 {up|down|mute}" >&2
        exit 2
        ;;
esac

status=$(wpctl get-volume "$sink")
percent=$(printf '%s\n' "$status" | awk '{ printf "%.0f", $2 * 100 }')

case "$status" in
    *MUTED*)
        icon='audio-volume-muted-symbolic'
        value=0
        label="Muted · ${percent}%"
        ;;
    *)
        value=$percent
        label="${percent}%"
        if [ "$percent" -eq 0 ]; then
            icon='audio-volume-muted-symbolic'
        elif [ "$percent" -lt 34 ]; then
            icon='audio-volume-low-symbolic'
        elif [ "$percent" -lt 67 ]; then
            icon='audio-volume-medium-symbolic'
        else
            icon='audio-volume-high-symbolic'
        fi
        ;;
esac

notify-send \
    --app-name='Volume OSD' \
    --urgency=low \
    --expire-time=1200 \
    --transient \
    --icon="$icon" \
    --hint=string:x-dunst-stack-tag:volume-osd \
    --hint=int:value:"$value" \
    'Volume' "$label"
