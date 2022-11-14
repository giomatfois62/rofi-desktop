#!/usr/bin/env bash

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"
CHAR_FILE="$SCRIPT_PATH"/data/unicode.txt
ROFI_CMD="rofi -dmenu -i -p Characters"

selected=$(cat "$CHAR_FILE" | $ROFI_CMD)

if [ ${#selected} -gt 0 ]; then
    echo "$selected" | awk '{print $1;}' | xclip -selection clipboard
    exit 0
fi

exit 1

