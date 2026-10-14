#!/bin/bash
#
# rofi sound theme selection script

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"

sounds_dir="$SCRIPT_PATH/sounds"
current=$(readlink -f "$sounds_dir/current")
current=$(basename "$current")

theme=$(find "$sounds_dir" -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | sed -e "s/$current/<b>$current<\/b>/g" | $ROFI -dmenu -i -p "Sounds" -markup-rows)

if [ -d "$sounds_dir/$theme" ] && [ -n "$theme" ]; then
    cd $sounds_dir && rm current && ln -s "$theme" current
fi
