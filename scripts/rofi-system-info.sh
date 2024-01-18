#!/bin/bash
#
# script to pipe system info into a rofi menu
#

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
SYSTEM_INFO="${SYSTEM_INFO:-inxi -c0 -v2}" # neofetch --stdout --color_blocks off

eval "$SYSTEM_INFO" | $ROFI_CMD -p "System Info"
