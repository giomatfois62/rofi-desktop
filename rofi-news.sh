#!/bin/bash

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
RSS_URL="http://feeds.bbci.co.uk/news/rss.xml?edition=int"
RSS_FILE="$SCRIPT_PATH/data/news"
ROFI_CMD="rofi -dmenu -i"
EXPIRATION_TIME=600 # refresh news file every ten minutes

mkdir -p "${RSS_FILE%news}"

if [ -f "$RSS_FILE" ]; then
	# compute time delta between current date and news file date
	newsdate=$(date -r $RSS_FILE +%s)
	currentdate=$(date +%s)
	delta=$((currentdate - newsdate))

	# refresh news file if it's too old
	if [ $delta -gt $EXPIRATION_TIME ]; then
		curl --silent "$RSS_URL" -o "$RSS_FILE"
	fi
else
	curl --silent "$RSS_URL" -o "$RSS_FILE"
fi

selected=$(cat "$RSS_FILE" |\
	grep -E '(title>|/title>)' |\
	tail -n +4 | sed -e 's/^[ \t]*//' |\
	sed -e 's/<title>//' -e 's/<\/title>//' -e 's/<description>/  /' -e 's/<\/description>//' -e 's/\!\[CDATA\[//' -e 's/\]\]//' |\
	tr -d '<>,' |\
	awk '$1=$1' |\
	$ROFI_CMD -p "News")

# get selected news and open corresponding link in browser
if [  ${#selected} -gt 0 ]; then
	link=$(awk "/$selected/{getline;getline; print}" $RSS_FILE)
	echo $link | sed -e 's/<link>//' -e 's/<\/link>//' | xargs -I {} xdg-open {}

	exit 0;
fi

exit 1
