#!/usr/bin/env bash
#
# this script allows searching from various web sources with real time suggestions
#
# dependencies: rofi
# optional: rofi-blocks

# TODO: implement other apis for suggestions

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"

search_blocks_help="Type to search"

api=$1

case "$api" in
    "google") api_url="https://www.google.com/search?q=" ;;
    "youtube") api_url="https://www.youtube.com/results?search_query=" ;;
    "wikipedia") api_url="https://en.wikipedia.org/?curid=" ;;
    "archwiki") api_url="https://wiki.archlinux.org/index.php?search=" ;;
    "maps") api_url="https://nominatim.openstreetmap.org/search?q=" ;;
    *) echo "unrecognized api" && exit 1 ;;
esac

# detect rofi-blocks and integrate suggestions
have_blocks=$(rofi -dump-config | grep blocks)

if [ -n "$have_blocks" ]; then
    logfile="$HOME/.cache/suggestions.tmp"
    blockfile="$SCRIPT_PATH/rofi-web-suggestions.sh"

    mkdir -p "${logfile%suggestions.tmp}"
    echo "$api" > "$logfile"

    $ROFI -modi blocks -show blocks -blocks-wrap "$blockfile" -display-blocks "$api" 2>/dev/null

    [ -f "$logfile" ] && query="$(cat "$logfile")" || exit 1

    rm "$logfile"

    if [ -n "$query" ]; then
	    # extract wikipedia page id from string
	    if [ "$api" = "wikipedia" ]; then
		    word_count=$(echo "$query" | wc -w)

		    if [ "$word_count" -gt 1 ]; then
			    query=$(echo "$query" | awk '{print $NF}')
		    else
			    api_url="https://en.wikipedia.org/w/index.php?fulltext=1&search="
		    fi
	    fi

	    url=$api_url$query
	    xdg-open "$url"

	    exit 0
    fi
else
    query=$((echo) | $ROFI -dmenu -i -p "$api");

    if [ -n "$query" ]; then
	    url=$api_url$query
	    xdg-open "$url"

	    exit 0
    fi
fi

exit 1
