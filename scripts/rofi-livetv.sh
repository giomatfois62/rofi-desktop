#!/usr/bin/env bash
#
# this script scrape and show the list of upcoming sport events streamed on livetv.sx
#
# dependencies: rofi, jq, python3-lxml, python3-requests

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"

livetv_refresh=3600 # refresh livetv file every hour
livetv_file="$ROFI_CACHE_DIR/livetv.json"

if [ -f "$livetv_file" ]; then
    # compute time delta between current date and news file date
	news_date=$(date -r "$livetv_file" +%s)
	current_date=$(date +%s)

	delta=$((current_date - news_date))

	# refresh livetv file if it's too old
	if [ $delta -gt $livetv_refresh ]; then
		"$SCRIPT_PATH"/scrape_livetv.py "$livetv_file"
	fi
else
	"$SCRIPT_PATH"/scrape_livetv.py "$livetv_file"
fi

while name=$(jq '.[] | "{\(.time)} \(.category) \(.name)"' "$livetv_file" | tr -d '"' |\
        sort | $ROFI -dmenu -i -p "LiveTV" -format 'i s'); do

    name_idx=$(echo "$name" | cut -d' ' -f1)
    link_sel=".[$name_idx].link"
    event_link=$(jq "$link_sel" "$livetv_file" | tr -d '"')

    echo "$name"
    echo "name: $name_str sel: $link_sel event: $event_link"

    # follow redirect with curl using -L
    streams=$(curl -L "$event_link" | grep "OnClick=\"show_webplayer" |\
		sed -E 's/^.*href/href/; s/>.*//' | sed -r 's/.*href="([^"]+).*/\1/g')

	if [ -z "$streams" ]; then
		$ROFI -e "No stream links available, retry later."
	else
		selected_stream=$(echo -en "$streams" | $ROFI -dmenu -i -p "Link")

		if [ -n "$selected_stream" ]; then

			xdg-open https:"$selected_stream"

			exit 0
		fi
	fi
done

exit 1
