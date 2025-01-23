#!/usr/bin/env bash
#
# this script shows a rofi clipboard menu
#
# dependencies: rofi, clipster/cliphist, wl-clipboard

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"

if [[ -n $WAYLAND_DISPLAY  ]]; then
    clip_exe="cliphist"
    clip_daemon="wl-paste --watch $clip_exe store"
elif [[ -n $DISPLAY ]]; then
    clip_exe="clipster"
    clip_daemon="$clip_exe -d"
else
    echo "Error: No Wayland or X11 display detected" >&2
    exit 1
fi

[ -n "$(command -v $clip_exe)" ] && clip_cmd="$clip_exe"
[ -f "$SCRIPT_PATH/$clip_exe" ] && clip_cmd="$SCRIPT_PATH/$clip_exe"
[ -z "$clip_cmd" ] && $ROFI -e "Download $clip_exe and place it inside \"$SCRIPT_PATH\" to enable the clipboard menu." && exit 1

if [ "$(ps aux | grep -c "$clip_exe")" -lt 2 ]; then
    $ROFI -e "Run \"$clip_daemon\" to enable the clipboard menu"
    exit 1
fi

if [[ -n $WAYLAND_DISPLAY  ]]; then
    "$clip_cmd" list | $ROFI -dmenu -i -p "Clipboard" | "$clip_cmd" decode | wl-copy
    exit 0
else
    # Extract clipboard history from clipster and format for rofi
    clipboard=$("$clip_cmd" -c -o -n 500 -0 \
        | gawk 'BEGIN {RS = "\0"; ORS = "\0"} NF > 0 { print substr($0, 1, 250) }' \
        | gawk 'BEGIN {RS = "\0"; FS="\n"; OFS=" " } { $1=$1; print $0 }'  \
        | sed 's/^ *//')

    selection="$(echo "$clipboard" | $ROFI -dmenu -i -format 'i s' -p 'Clipboard')"

    if [ -n "$selection" ]; then
        row=$(($(echo "$selection" | cut -d' ' -f1)+1))

        # Extract clipboard history from clipster and find the nth non-empty clip based selected line number
        selection=$("$clip_cmd" -c -o -n 500 -0 \
                        | gawk 'BEGIN {RS = "\0"; ORS = "\0"} NF > 0 { print }' \
                        | gawk 'BEGIN {RS = "\0"}'"NR == $row { print; exit }")

        # Echo the selection back to clipster
        echo -n "$selection" | "$clip_cmd" -c
        exit 0
    fi
fi

exit 1
