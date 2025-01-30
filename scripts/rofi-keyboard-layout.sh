#!/usr/bin/env bash
#
# this script manages the current keyboard layout (on x11)
#
# dependencies: rofi, setxkbmap

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_CONFIG_DIR="${ROFI_CONFIG_DIR:-$SCRIPT_PATH/config}"

keymap_cache="$ROFI_CONFIG_DIR/keyboard-layout"
keymaps="/usr/share/X11/xkb/rules/evdev.lst"

rofi_mesg="Current Layout: "$(setxkbmap -query | grep layout | cut -d':' -f2 | sed 's/ //g')

selected=$(cat $keymaps |\
    grep -Poz '(?<=layout\n)(.|\n)*(?=! variant)' |\
    head -n -2 |\
    $ROFI -dmenu -i -p "Keyboard Layout" -mesg "$rofi_mesg" |\
    awk '{print $1;}'
)

if [ -n "$selected" ]; then
    setxkbmap "$selected"

    echo "$selected" > "$keymap_cache"
fi
