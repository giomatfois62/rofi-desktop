#!/bin/bash

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"
XKCD_CACHE="$ROFI_CACHE_DIR/xkcd"

comic_id=$1
comic_url="https://xkcd.com/$comic_id/info.0.json"
comic_file="$XKCD_CACHE/$comic_id"

if [ ! -f "$comic_file" ]; then
    curl --silent "$comic_url" -o "$comic_file"
    comic_image=$(jq -r '.img' "$comic_file")
    curl --silent "$comic_image" -o "$XKCD_CACHE/$comic_id.png"
fi

if [ ! -f "$2" ]; then
    cp "$XKCD_CACHE/$comic_id.png" "$2"
fi
