#!/usr/bin/env bash
#
# this script shows a rofi clipboard menu
#
# dependencies: rofi, greenclip/cliphist, wl-clipboard

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"

if [[ -n $WAYLAND_DISPLAY  ]]; then
    if command -v cliphist &> /dev/null; then
        cliphist list | $ROFI -dmenu -i -p "Clipboard" | cliphist decode | wl-copy
    elif [ -f "$SCRIPT_PATH/cliphist" ]; then
        if [ "$(ps aux | grep -c "cliphist")" -gt 1 ]; then
            "$SCRIPT_PATH/cliphist" list | $ROFI -dmenu -i -p "Clipboard" | "$SCRIPT_PATH/cliphist" decode | wl-copy
        else
            $ROFI -e "Run \"wl-paste --watch $SCRIPT_PATH/cliphist store\" to enable the clipboard menu"
        fi
    else
        $ROFI -e "Download cliphist and place it inside \"$SCRIPT_PATH\" to enable the clipboard menu"
    fi
elif [[ -n $DISPLAY ]]; then
    if command -v greenclip &> /dev/null; then
        $ROFI -modi "Clipboard:greenclip print" -show Clipboard -run-command '{cmd}'
    elif [ -f "$SCRIPT_PATH/greenclip" ]; then
        if [ "$(ps aux | grep -c "greenclip")" -gt 1 ]; then
            $ROFI -modi "Clipboard:$SCRIPT_PATH/greenclip print" -show Clipboard -run-command '{cmd}'
        else
            $ROFI -e "Run \"$SCRIPT_PATH/greenclip daemon &\" to enable the clipboard menu"
        fi
    else
        $ROFI -e "Download greenclip and place it inside \"$SCRIPT_PATH\" to enable the clipboard menu"
    fi
else
    echo "Error: No Wayland or X11 display detected" >&2
    exit 1
fi
