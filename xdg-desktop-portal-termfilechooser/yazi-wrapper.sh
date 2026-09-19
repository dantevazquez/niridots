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

# Launch foot with app ID yazi-chooser and dimensions
foot --app-id=yazi-chooser -T "File Chooser" \
    --window-size-chars="${COLUMNS}x${LINES}" \
    -e "$cmd" "$@"

if [ "$directory" = "1" ]; then
    if [ ! -s "$out" ] && [ -s "$out.1" ]; then
        cat "$out.1" > "$out"
        rm -f "$out.1"
    else
        rm -f "$out.1"
    fi
fi
