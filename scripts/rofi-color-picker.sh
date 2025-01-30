#!/bin/bash
#
# script to display and pick colors
#
# dependencies: rofi, xclip/wl-clip

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

ROFI="${ROFI:-rofi}"
ROFI_DATA_DIR="${ROFI_DATA_DIR:-$SCRIPT_PATH/data}"

colors_file="$ROFI_DATA_DIR/colors-name.txt"

if [ -n "$WAYLAND_DISPLAY" ]; then
    clip_cmd="wl-copy"
elif [ -n "$DISPLAY" ]; then
    clip_cmd="xclip -sel clip"
else
    echo "Error: No Wayland or X11 display detected" >&2
    exit 1
fi

selected=$(cat "$colors_file" | $ROFI -dmenu -i -markup-rows -p "Colors")

if [ -n "$selected" ]; then
    echo -n "$(echo "$selected" | cut -d\' -f2)" | $clip_cmd
    exit 0
fi

exit 1
