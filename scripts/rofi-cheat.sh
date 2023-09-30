#!/usr/bin/env bash
#
# this script search and shows cheat sheets for many languages and commands using the cheat.sh service
# it also shows an option to copy the displayed text to the clipboard
#
# dependencies: rofi, curl, xclip/wl-clipboard

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
CHEAT_MSG="Type your query and press \"Enter\" to search cheat.sh.&#x0a;Type \":list\" to list available language cheat sheets.&#x0a;Type \":learn\" to get the language basics."

if [ -n "$WAYLAND_DISPLAY" ]; then
    clip_cmd="wl-copy"
elif [ -n "$DISPLAY" ]; then
    clip_cmd="xclip -sel clip"
else
    echo "Error: No Wayland or X11 display detected" >&2
    exit 1
fi

base_url="cheat.sh"
all_entries=$(curl "cheat.sh/:list")

while entry=$(echo -en "$all_entries" | $ROFI_CMD -p "Entry"); do
    while query=$((echo) | $ROFI_CMD -p "Query" -mesg "$CHEAT_MSG"); do
        encoded_query=${query// /"+"}

        if [ "$query" != ":list" ]; then
            encoded_query="$encoded_query?T"
        fi

        url="$base_url/$entry?T"

        if [ -n "$query" ]; then
            url="$base_url/$entry/$encoded_query"
        fi

        cheat=$(curl "$url")

        choice=$(echo -en "Copy to Clipboard\n\n$cheat" | $ROFI_CMD -p "$query")

        if [ "$choice" = "Copy to Clipboard" ]; then
            echo "$cheat" | $clip_cmd
            exit 0
        fi
    done
done

exit 1
