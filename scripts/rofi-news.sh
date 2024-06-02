#!/bin/bash
#
# this script fetches and show the latest news from bbc internationals rss
# selecting an entry will open the corresponding web page
# add other sources in the "$ROFI_DATA_DIR/news" file using the format "PROVIDER_NAME=RSS_URL"
#
# dependencies: rofi, curl, libxml2

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
ROFI_DATA_DIR="${ROFI_DATA_DIR:-$SCRIPT_PATH/data}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"
RSS_EXPIRATION_TIME=${RSS_EXPIRATION_TIME:-600} # refresh news file every ten minutes
RSS_FILE="$ROFI_DATA_DIR/news"
RSS_CACHE="$ROFI_CACHE_DIR/news"

show_news() {
	local provider_name="$1"

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

	titles=$(cat "$rss_cache_file" | xmllint --xpath '/rss/channel/item[*]/title/text()' - | sed -e 's/\!\[CDATA\[//' -e 's/\]\]//' | tr -d '<>,')

	selected=$(echo "$titles" | $ROFI_CMD -p "$provider_name" -format 'i s')

	# get selected news and open corresponding link in browser
	if [ -n "$selected" ]; then
		selected_row=$(echo "$selected" | awk '{print $1;}')
		selected_row=$(($selected_row+1)) # xpath arrays starts from 1

		link=$(cat "$rss_cache_file" | xmllint --xpath "/rss/channel/item[$selected_row]/link/text()" -)

		xdg-open "$link"

		exit 0;
	fi

	exit 1
}

mkdir -p "$RSS_CACHE"

providers=$(cat "$RSS_FILE" | cut -d'=' -f1)
providers_count=$(cat "$RSS_FILE" | wc -l)

if [ $providers_count -gt 1 ]; then
	# remember last entry chosen
	provider_row=0

	while provider=$(echo -en "$providers" | $ROFI_CMD -selected-row ${provider_row} -format 'i s' -p "News"); do
		provider_row=$(echo "$provider" | awk '{print $1;}')
		provider_name=$(echo "$provider" | cut -d' ' -f2-)

		$(show_news "$provider_name") && exit 0
	done
else
	provider_name=$(head -n 1 "$RSS_FILE" | cut -d'=' -f1)
	$(show_news "$provider_name") && exit 0
fi

exit 1
