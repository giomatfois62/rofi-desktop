#!/bin/bash
#
# this script fetches and show the latest news from bbc internationals rss
# selecting an entry will open the corresponding web page
# add other sources in the "$ROFI_DATA_DIR/news" file using the format "PROVIDER_NAME=RSS_URL"
#
# dependencies: rofi, curl, libxml2

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_DATA_DIR="${ROFI_DATA_DIR:-$SCRIPT_PATH/data}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"

rss_refresh=600 # refresh news file every ten minutes
rss_file="$ROFI_DATA_DIR/news"
rss_cache="$ROFI_CACHE_DIR/news"

show_news() {
	local provider_name="$1"

	rss_url=$(grep "$provider_name=" "$rss_file" | cut -d'=' -f2-)
	rss_cache_file="$rss_cache/$provider_name.news"

	# TODO: do this job in background and display message
	if [ -f "$rss_cache_file" ]; then
		# compute time delta between current date and news file date
		news_date=$(date -r "$rss_cache_file" +%s)
		current_date=$(date +%s)

		delta=$((current_date - news_date))

		# refresh news file if it's too old
		if [ $delta -gt $rss_refresh ]; then
			curl --silent "$rss_url" -o "$rss_cache_file"
		fi
	else
		curl --silent "$rss_url" -o "$rss_cache_file"
	fi

	titles=$(cat "$rss_cache_file" | xmllint --xpath '/rss/channel/item[*]/title/text()' - | sed -e 's/\!\[CDATA\[//' -e 's/\]\]//' | tr -d '<>,')

	selected=$(echo "$titles" | $ROFI -dmenu -i -p "$provider_name" -format 'i s')

	# get selected news and open corresponding link in browser
	if [ -n "$selected" ]; then
		row=$(echo "$selected" | awk '{print $1;}')
		row=$(($row+1)) # xpath arrays starts from 1

		link=$(cat "$rss_cache_file" | xmllint --xpath "/rss/channel/item[$row]/link/text()" -)

		xdg-open "$link"

		exit 0;
	fi

	exit 1
}

mkdir -p "$rss_cache"

providers=$(cat "$rss_file" | cut -d'=' -f1)
providers_count=$(cat "$rss_file" | wc -l)

if [ $providers_count -gt 1 ]; then
	# remember last entry chosen
	provider_row=0

	while provider=$(echo -en "$providers" | $ROFI -dmenu -i -selected-row ${provider_row} -format 'i s' -p "News"); do
		provider_row=$(echo "$provider" | awk '{print $1;}')
		provider_name=$(echo "$provider" | cut -d' ' -f2-)

		$(show_news "$provider_name") && exit 0
	done
else
	provider_name=$(head -n 1 "$rss_file" | cut -d'=' -f1)

	$(show_news "$provider_name") && exit 0
fi

exit 1
