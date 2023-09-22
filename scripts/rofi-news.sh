#!/bin/bash
#
# this script fetches and show the latest news from bbc internationals rss
# selecting an entry will open the corresponding web page
# add other sources in the "../data/news" file using the format "PROVIDER_NAME=RSS_URL"
#
# dependencies: rofi, curl

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
RSS_FILE=${RSS_FILE:-"$SCRIPT_PATH/../data/news"}
RSS_CACHE="${RSS_CACHE:-$HOME/.cache/news}"
RSS_EXPIRATION_TIME=${RSS_EXPIRATION_TIME:-600} # refresh news file every ten minutes

providers=$(cat "$RSS_FILE" | cut -d'=' -f1)

mkdir -p "$RSS_CACHE"

# remember last entry chosen
provider_row=0

while provider=$(echo -en "$providers" | $ROFI_CMD -selected-row ${provider_row} -format 'i s' -p "News"); do
	provider_row=$(echo "$provider" | awk '{print $1;}')
	provider_name=$(echo "$provider" | cut -d' ' -f2-)

	rss_url=$(grep "$provider_name=" "$RSS_FILE" | cut -d'=' -f2-)
	rss_cache_file="$RSS_CACHE/$provider_name.news"

	# TODO: do this job in background and display message
	if [ -f "$rss_cache_file" ]; then
		# compute time delta between current date and news file date
		news_date=$(date -r "$rss_cache_file" +%s)
		current_date=$(date +%s)

		delta=$((current_date - news_date))

		# refresh news file if it's too old
		if [ $delta -gt $RSS_EXPIRATION_TIME ]; then
			curl --silent "$rss_url" -o "$rss_cache_file"
		fi
	else
		curl --silent "$rss_url" -o "$rss_cache_file"
	fi

	selected=$(grep -E '(title>|/title>)' "$rss_cache_file" |\
		tail -n +4 | sed -e 's/^[ \t]*//' |\
		sed -e 's/<title>//' -e 's/<\/title>//' -e 's/<description>/  /'\
			-e 's/<\/description>//' -e 's/\!\[CDATA\[//' -e 's/\]\]//' |\
		tr -d '<>,' |\
		awk '$1=$1' |\
		$ROFI_CMD -p "$provider_name")

	# get selected news and open corresponding link in browser
	if [ -n "$selected" ]; then
		link=$(awk "/$selected/{getline;getline; print}" "$rss_cache_file")

		echo "$link" | sed -e 's/<link>//' -e 's/<\/link>//' | xargs -I {} xdg-open {}

		exit 0;
	fi
done

exit 1
