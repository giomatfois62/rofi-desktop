#!/usr/bin/bash
#
# this script shows fortunes
#
# dependencies: rofi, fortune
# optional: cowsay

ROFI="${ROFI:-rofi}"
ROFI_ICONS="${ROFI_ICONS:-}"

rofi_flags=""

[ -n "$ROFI_ICONS" ] && rofi_flags="-show-icons"

if ! command -v fortune &> /dev/null; then
    $ROFI -e "Install fortune"
    exit 1
fi

get_fortune() {
    if command -v cowsay &> /dev/null; then
        fortune | cowsay
    else
        fortune
    fi
}

rofi_theme="listview{lines:1;}\
entry{enabled:false;}\
mainbox{children:[message,listview];}"

while continue=$(echo -en "Next\x00icon\x1fgo-next" | \
    $ROFI -dmenu -i $rofi_flags -p "Fortune" -rofi_theme-str "$rofi_theme" -mesg "$(get_fortune)"); do
    echo "next"
done
