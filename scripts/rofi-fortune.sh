#!/usr/bin/bash
#
# this script shows fortunes
#
# dependencies: rofi, fortune
# optional: cowsay

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"

if ! command -v fortune &> /dev/null; then
    rofi -e "Install fortune"
    exit 1
fi

get_fortune() {
    if command -v cowsay &> /dev/null; then
        fortune | cowsay
    else
        fortune
    fi
}

theme="listview{lines:1;columns:1;}entry{enabled:false;}mainbox{children:[message,listview];}"

while continue=$(echo -en "Next\x00icon\x1fgo-next" | $ROFI_CMD -p "Fortune" -theme-str "$theme" -mesg "$(get_fortune)"); do
    echo "next"
done
