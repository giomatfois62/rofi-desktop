#!/usr/bin/env bash
#
# this script manages the current keyboard layout (on x11)
#
# dependencies: rofi, setxkbmap

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_CONFIG_DIR="${ROFI_CONFIG_DIR:-$SCRIPT_PATH/config}"
KEYMAP_CACHE="$ROFI_CONFIG_DIR/keyboard-layout"
LAYOUT_FILE="/usr/share/X11/xkb/rules/evdev.lst"

msg="Current Layout: "$(setxkbmap -query | grep layout | cut -d':' -f2 | sed 's/ //g')

selected=$(cat $LAYOUT_FILE |\
    grep -Poz '(?<=layout\n)(.|\n)*(?=! variant)' |\
    head -n -2 |\
    $ROFI -dmenu -i -p "Keyboard Layout" -mesg "$msg" |\
    awk '{print $1;}'
)

if [ -n "$selected" ]; then
    setxkbmap "$selected"

    echo "$selected" > "$KEYMAP_CACHE"
fi
