#!/usr/bin/env bash

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
ROFI_CMD="rofi -dmenu -i -matching fuzzy"

API=$1

# TODO: add reddit API
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
have_blocks=`rofi -dump-config | grep blocks`

if [ ${#have_blocks} -gt 0 ]; then
    logfile="$SCRIPT_PATH/data/suggestions.tmp"
    blockfile="$SCRIPT_PATH/rofi-web-suggestions.sh"

    mkdir -p "${logfile%suggestions.tmp}"

    printf "$API" > "$logfile"

    rofi -modi blocks -show blocks -blocks-wrap $blockfile -display-blocks $API 2>/dev/null

    [ -f $logfile ] && query="$(cat "$logfile")" || exit 1

    rm $logfile

    if [ ${#query} -gt 0 ]; then

	    # extract wikipedia page id from string
	    if [ "$API" = "wikipedia" ]; then
		    word_count=$(echo "$query" | wc -w)
		    if [ $word_count -gt 1 ]; then
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
    query=$((echo) | $ROFI_CMD -p $API);

    if [ ${#query} -gt 0 ]; then
	    url=$api_url$query
	    xdg-open "$url"
	    exit 0
    fi
fi

exit 1
