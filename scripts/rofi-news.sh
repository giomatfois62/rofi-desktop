#!/bin/bash
#
# this script fetches and show the latest news from bbc internationals rss
# selecting an entry will open the corresponding web page
#
# dependencies: rofi, curl

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
RSS_URL="${RSS_URL:-http://feeds.bbci.co.uk/news/rss.xml?edition=int}"
RSS_CACHE="${RSS_CACHE:-$HOME/.cache/news}"
RSS_EXPIRATION_TIME=${RSS_EXPIRATION_TIME:-600} # refresh news file every ten minutes

declare -A rss_urls=(
	["BBC World"]="http://feeds.bbci.co.uk/news/rss.xml?edition=int"
	["AP News"]="https://rsshub.app/apnews/topics/apf-topnews"
	["ANSA.it"]="https://www.ansa.it/sito/ansait_rss.xml"
	["Al Jazeera"]="https://www.aljazeera.com/xml/rss/all.xml"
	["BuzzFeed"]="https://www.buzzfeed.com/index.xml"
)

providers="BBC World\nAP News\nAl Jazeera\nANSA.it"

mkdir -p "$RSS_CACHE"

# remember last entry chosen
provider_row=0

while provider=$(echo -en "$providers" | $ROFI_CMD -selected-row ${provider_row} -format 'i s' -p "News"); do
	provider_row=$(echo "$provider" | awk '{print $1;}')
	provider_text=$(echo "$provider" | cut -d' ' -f2-)

	RSS_URL=${rss_urls[$provider_text]}
	RSS_FILE="$RSS_CACHE/$provider_text.news"

	# TODO: do this job in background and display message
	if [ -f "$RSS_FILE" ]; then
		# compute time delta between current date and news file date
		news_date=$(date -r "$RSS_FILE" +%s)
		current_date=$(date +%s)

		delta=$((current_date - news_date))

		# refresh news file if it's too old
		if [ $delta -gt $RSS_EXPIRATION_TIME ]; then
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
		$ROFI_CMD -p "$provider_text")

	# get selected news and open corresponding link in browser
	if [ -n "$selected" ]; then
		link=$(awk "/$selected/{getline;getline; print}" "$RSS_FILE")

		echo "$link" | sed -e 's/<link>//' -e 's/<\/link>//' | xargs -I {} xdg-open {}

		exit 0;
	fi

done

exit 1
