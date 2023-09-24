#!/usr/bin/env bash
#
# this script manages the current keyboard layout (on x11)
#
# dependencies: rofi, setxkbmap

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
KEYMAP_CACHE=${KEYMAP_CACHE:-"$HOME/.cache/keymap"}
LAYOUT_FILE="/usr/share/X11/xkb/rules/evdev.lst"

selected=$(cat $LAYOUT_FILE |\
    grep -Poz '(?<=layout\n)(.|\n)*(?=! variant)' |\
    head -n -2 |\
    $ROFI_CMD - p "Layout"  |\
    awk '{print $1;}'
)

if [ -n "$selected" ]; then
    setxkbmap "$selected"
    echo "$selected" > "$KEYMAP_CACHE"
fi
