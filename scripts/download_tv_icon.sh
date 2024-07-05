#!/bin/bash

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_DATA_DIR="${ROFI_DATA_DIR:-$SCRIPT_PATH/data}"
LINK=$(grep "$1" "$ROFI_DATA_DIR/channels.m3u" | cut -d' ' -f3- | cut -d'"' -f 2)

if [ -z "$LINK" ]; then
    exit 1
fi

nice -n 19 /usr/bin/wget -q -O "$2" "$LINK"
