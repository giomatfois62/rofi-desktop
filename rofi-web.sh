#!/usr/bin/env bash

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
ROFI_CMD="rofi -dmenu -i -matching fuzzy"
API="google" # TODO: implement other APIs for suggestions

#SEARCH_URL="https://www.google.com/search?q="
#SEARCH_URL=https://en.wikipedia.org/w/index.php?search=
#SEARCH_URL=https://www.youtube.com/results?search_query=

# detect rofi-blocks and integrate suggestions
have_blocks=`rofi -dump-config | grep blocks`

if [ ${#have_blocks} -gt 0 ]; then
	logfile="$SCRIPT_PATH/suggestions.tmp"
	blockfile="$SCRIPT_PATH/rofi-web-suggestions.sh"
	
	printf "$API" > "$logfile"

	rofi -modi blocks -show blocks -blocks-wrap $blockfile -display-blocks "Google" 2>/dev/null

	[ -f $logfile ] && query="$(cat "$logfile")" || exit 1

	rm $logfile

	if [ ${#query} -gt 0 ]; then
		url=https://www.google.com/search?q=$query
		xdg-open "$url"
		exit 0
	fi
else
	query=$((echo) | $ROFI_CMD -p "Google");

	if [ ${#query} -gt 0 ]; then
		url=https://www.google.com/search?q=$query
		xdg-open "$url"
		exit 0
	fi
fi

exit 1
