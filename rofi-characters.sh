#!/usr/bin/env bash

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"
CHAR_FILE="$SCRIPT_PATH"/data/unicode.txt
ROFI_CMD="rofi -dmenu -i -p Characters"

if [[ -n $WAYLAND_DISPLAY ]]; then
    xdotool="ydotool type --file -"
elif [[ -n $DISPLAY ]]; then
    xdotool="xdotool type --clearmodifiers --file -"
else
    echo "Error: No Wayland or X11 display detected" >&2
    exit 1
fi

selected=$(cat "$CHAR_FILE" | $ROFI_CMD)

# use xclip instead of xdotool
#xclip -selection clipboard

if [ ${#selected} -gt 0 ]; then
    echo "$selected" | awk '{print $1;}' | $xdotool
    exit 0
fi

exit 1

