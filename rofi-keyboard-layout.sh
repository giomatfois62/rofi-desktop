#!/usr/bin/env bash

LAYOUT_FILE="/usr/share/X11/xkb/rules/evdev.lst"
ROFI_CMD="rofi -dmenu -i -p Layout"

selected=$(cat $LAYOUT_FILE |\
    grep -Poz '(?<=layout\n)(.|\n)*(?=! variant)' |\
    head -n -2 |\
    $ROFI_CMD  |\
    awk '{print $1;}'
)

if [ ${#selected} -gt 0 ]; then
    setxkbmap "$selected"
fi
