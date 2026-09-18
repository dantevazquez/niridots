#!/usr/bin/env sh
# Wrapper script invoked by xdg-desktop-portal-termfilechooser

multiple="$1"
directory="$2"
save="$3"
path="$4"
out="$5"

set -e

if [ -z "$path" ] || [ ! -e "$path" ]; then
    path="$HOME"
fi

cmd="yazi"

if [ "$save" = "1" ]; then
    set -- --chooser-file="$out" "$path"
elif [ "$directory" = "1" ]; then
    set -- --chooser-file="$out" --cwd-file="$out.1" "$path"
elif [ "$multiple" = "1" ]; then
    set -- --chooser-file="$out" "$path"
else
    set -- --chooser-file="$out" "$path"
fi

# Dimensions: columns=110, lines=30 (larger 3-column view for yazi)
COLUMNS=110
LINES=30

# Approximate center coordinates for immediate effect
POS_ARGS=""
res=$(xdpyinfo 2>/dev/null | awk '/dimensions:/ {print $2}')
if [ -n "$res" ]; then
    screen_w="${res%x*}"
    screen_h="${res#*x}"
    win_w=$(( COLUMNS * 24 ))
    win_h=$(( LINES * 53 ))
    pos_x=$(( (screen_w - win_w) / 2 ))
    pos_y=$(( (screen_h - win_h) / 2 ))
    if [ "$pos_x" -gt 0 ] && [ "$pos_y" -gt 0 ]; then
        POS_ARGS="-o window.position.x=$pos_x -o window.position.y=$pos_y"
    fi
fi

# Launch Alacritty with class yazi-chooser and dimensions
alacritty --class yazi-chooser,yazi-chooser -T "File Chooser" \
    -o window.dimensions.columns=$COLUMNS \
    -o window.dimensions.lines=$LINES \
    $POS_ARGS \
    -e "$cmd" "$@"

if [ "$directory" = "1" ]; then
    if [ ! -s "$out" ] && [ -s "$out.1" ]; then
        cat "$out.1" > "$out"
        rm -f "$out.1"
    else
        rm -f "$out.1"
    fi
fi
