#!/bin/bash

ROFI_CMD="rofi -dmenu -i -p News"
RSS_URL="http://feeds.bbci.co.uk/news/rss.xml?edition=int"
RSS_FILE="$HOME/.cache/news"
EXPIRATION_TIME=600 # refresh news file every ten minutes

mkdir -p "${RSS_FILE%news}"

# TODO: do this job in background and display message+
if [ -f "$RSS_FILE" ]; then
	# compute time delta between current date and news file date
	news_date=$(date -r "$RSS_FILE" +%s)
	current_date=$(date +%s)

	delta=$((current_date - news_date))

	# refresh news file if it's too old
	if [ $delta -gt $EXPIRATION_TIME ]; then
		curl --silent "$RSS_URL" -o "$RSS_FILE"
	fi
else
	curl --silent "$RSS_URL" -o "$RSS_FILE"
fi

selected=$(grep -E '(title>|/title>)' "$RSS_FILE" |\
	tail -n +4 | sed -e 's/^[ \t]*//' |\
	sed -e 's/<title>//' -e 's/<\/title>//' -e 's/<description>/  /'\
		-e 's/<\/description>//' -e 's/\!\[CDATA\[//' -e 's/\]\]//' |\
	tr -d '<>,' |\
	awk '$1=$1' |\
	$ROFI_CMD)

# get selected news and open corresponding link in browser
if [ ${#selected} -gt 0 ]; then
	link=$(awk "/$selected/{getline;getline; print}" "$RSS_FILE")

	echo "$link" | sed -e 's/<link>//' -e 's/<\/link>//' | xargs -I {} xdg-open {}

	exit 0;
fi

exit 1
