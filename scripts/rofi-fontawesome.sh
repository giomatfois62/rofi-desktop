#!/bin/bash
#
# https://github.com/wstam88/rofi-fontawesome
#
# script to display and pick fontawesome icons
#
# dependencies: rofi, xclip/wl-clip

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

ROFI="${ROFI:-rofi}"
ROFI_DATA_DIR="${ROFI_DATA_DIR:-$SCRIPT_PATH/data}"

icons_file="$ROFI_DATA_DIR/fa5-icon-list.txt"

if [ -n "$WAYLAND_DISPLAY" ]; then
    clip_cmd="wl-copy"
elif [ -n "$DISPLAY" ]; then
    clip_cmd="xclip -sel clip"
else
    echo "Error: No Wayland or X11 display detected" >&2
    exit 1
fi

selected=$(cat "$icons_file" | $ROFI -dmenu -i -markup-rows -p "Icons")

if [ -n "$selected" ]; then
    echo -ne "$(echo "$selected" \
        | awk -F';' -v RS='>' '
            NR==2{sub("&#x","",$1);print "\\u" $1;exit}'
      )" |  $clip_cmd
    exit 0
fi

exit 1
