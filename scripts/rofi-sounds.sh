#!/bin/bash
#
# rofi sound theme selection script

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
SOUNDS="$SCRIPT_PATH/sounds"

current=$(readlink -f "$SOUNDS/current")
current=$(basename "$current")

theme=$(find "$SOUNDS" -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | sed -e "s/$current/<b>$current<\/b>/g" | $ROFI_CMD -p "Sounds" -markup-rows)

if [ -d "$SOUNDS/$theme" ] && [ -n "$theme" ]; then
    rm "$SOUNDS/current"
    ln -s "$SOUNDS/$theme" "$SOUNDS/current"
fi
