#!/usr/bin/env bash
#
# this script shows a rofi clipboard menu
#
# dependencies: rofi, greenclip/cliphist, wl-clipboard

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"

if [[ -n $WAYLAND_DISPLAY  ]]; then
    if command -v cliphist &> /dev/null; then
        cliphist list | $ROFI_CMD -p "Clipboard" | cliphist decode | wl-copy
    elif [ -f "$SCRIPT_PATH/cliphist" ]; then
        if [ "$(ps aux | grep -c "cliphist")" -gt 1 ]; then
            "$SCRIPT_PATH/cliphist" list | $ROFI_CMD -p "Clipboard" | "$SCRIPT_PATH/cliphist" decode | wl-copy
        else
            rofi -e "Run \"wl-paste --watch $SCRIPT_PATH/cliphist store\" to enable the clipboard menu"
        fi
    else
        rofi -e "Download cliphist and place it inside \"$SCRIPT_PATH\" to enable the clipboard menu"
    fi
elif [[ -n $DISPLAY ]]; then
    if command -v greenclip &> /dev/null; then
        rofi -modi "Clipboard:greenclip print" -show Clipboard -run-command '{cmd}'
    elif [ -f "$SCRIPT_PATH/greenclip" ]; then
        if [ "$(ps aux | grep -c "greenclip")" -gt 1 ]; then
            rofi -modi "Clipboard:$SCRIPT_PATH/greenclip print" -show Clipboard -run-command '{cmd}'
        else
            rofi -e "Run \"$SCRIPT_PATH/greenclip daemon &\" to enable the clipboard menu"
        fi
    else
        rofi -e "Download greenclip and place it inside \"$SCRIPT_PATH\" to enable the clipboard menu"
    fi
else
    echo "Error: No Wayland or X11 display detected" >&2
    exit 1
fi
