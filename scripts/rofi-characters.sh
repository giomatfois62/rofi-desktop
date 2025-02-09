#!/usr/bin/env bash
#
# this script displays unicode characters in a rofi menu
# selecting an entry will copy the character to the clipboard using xdotool (ydotool on wayland)
#
# dependencies: rofi, xdotool/ydotool

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_DATA_DIR="${ROFI_DATA_DIR:-$SCRIPT_PATH/data}"

characters_file="$ROFI_DATA_DIR/unicode.txt"

# to use xclip instead of xdotool
#xclip -selection clipboard

if [[ -n $WAYLAND_DISPLAY ]]; then
    xdotool="ydotool type --file -"
elif [[ -n $DISPLAY ]]; then
    xdotool="xdotool type --clearmodifiers --file -"
else
    echo "Error: No Wayland or X11 display detected" >&2
    exit 1
fi

selected=$(cat "$characters_file" | $ROFI -dmenu -i -p "Characters")

if [ -n "$selected" ]; then
    echo "$selected" | awk '{print $1;}' | $xdotool
    exit 0
fi

exit 1
