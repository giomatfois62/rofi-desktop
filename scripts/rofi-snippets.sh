#!/usr/bin/env bash
#
# https://github.com/raphaelfournier/rofi-modi-snippets
#
# a snippet menu for rofi
#
# dependencies: rofi, xdotool/ydotool

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

snipfile="$SCRIPT_PATH/data/snippets"
snipmesg="Add snippets in $snipfile.&#x0a;Snippets starting by <i>cmd</i> are eval'd"
snipseparator='_'

declare -A snippets

# loading snippets from file into array
while read line; do
    key=$(echo $line | cut -d $snipseparator -f1)
    value=$(echo $line | cut -d $snipseparator -f2-)
    snippets["$key"]="$value"
done < $snipfile

if [[ -n $WAYLAND_DISPLAY ]]; then
    xdotool="ydotool type --file -"
elif [[ -n $DISPLAY ]]; then
    xdotool="xdotool type --clearmodifiers --file -"
else
    echo "Error: No Wayland or X11 display detected" >&2
    exit 1
fi

read_snippets() {
    for K in "${!snippets[@]}"; do
      echo $K
    done
}

snippet=$(read_snippets | rofi -dmenu -i -markup-rows -mesg "$snipmesg" -p "Snippet")

if [[ ${snippets[$snippet]+_} ]]; then
    if [[ $snippet = cmd* ]]; then
        x=$(eval ${snippets[$snippet]})
        echo -n "$x" | $xdotool
    else
        echo -n ${snippets[$snippet]} | $xdotool
    fi

    exit 0
fi

exit 1
