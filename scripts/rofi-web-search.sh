#!/usr/bin/env bash
#
# this script allows searching from various web sources with real time suggestions
#
# dependencies: rofi
# optional: rofi-blocks

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"

SEARCH_PLACEHOLDER=${SEARCH_PLACEHOLDER:-"Type a query and press \"Enter\" to search"}
SEARCH_BLOCKS_PLACEHOLDER=${SEARCH_BLOCKS_PLACEHOLDER:-"Type to search"}

API=$1

case "$API" in
    "google") api_url="https://www.google.com/search?q=" ;;
    "youtube") api_url="https://www.youtube.com/results?search_query=" ;;
    "wikipedia") api_url="https://en.wikipedia.org/?curid=" ;;
    "archwiki") api_url="https://wiki.archlinux.org/index.php?search=" ;;
    *) echo "unrecognized API" && exit 1 ;;
esac

# TODO: implement other APIs for suggestions

#SEARCH_URL="https://www.google.com/search?q="
#SEARCH_URL=https://en.wikipedia.org/w/index.php?search=
#SEARCH_URL=https://www.youtube.com/results?search_query=

# detect rofi-blocks and integrate suggestions
have_blocks=$(rofi -dump-config | grep blocks)

if [ -n "$have_blocks" ]; then
    logfile="$HOME/.cache/suggestions.tmp"
    blockfile="$SCRIPT_PATH/rofi-web-suggestions.sh"

    mkdir -p "${logfile%suggestions.tmp}"
    echo "$API" > "$logfile"

    rofi -theme-str "entry{placeholder:\"$SEARCH_BLOCKS_PLACEHOLDER\";}" -modi blocks -show blocks -blocks-wrap "$blockfile" -display-blocks "$API" 2>/dev/null

    [ -f "$logfile" ] && query="$(cat "$logfile")" || exit 1

    rm "$logfile"

    if [ -n "$query" ]; then
	    # extract wikipedia page id from string
	    if [ "$API" = "wikipedia" ]; then
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
    query=$((echo) | $ROFI_CMD -theme-str "entry{placeholder:\"$SEARCH_PLACEHOLDER\";}" -p "$API");

    if [ -n "$query" ]; then
	    url=$api_url$query
	    xdg-open "$url"

	    exit 0
    fi
fi

exit 1
