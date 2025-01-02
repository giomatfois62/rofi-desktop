#!/usr/bin/env bash
#
# this script scrape and show the list of upcoming sport events streamed on livetv.sx
#
# dependencies: rofi, jq, python3-lxml, python3-requests

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"
LIVETV_FILE="$ROFI_CACHE_DIR/livetv.json"
LIVETV_EXPIRATION_TIME=${LIVETV_EXPIRATION_TIME:-3600} # refresh livetv file every hour

if [ -f "$LIVETV_FILE" ]; then
    # compute time delta between current date and news file date
	news_date=$(date -r "$LIVETV_FILE" +%s)
	current_date=$(date +%s)

	delta=$((current_date - news_date))

	# refresh livetv file if it's too old
	if [ $delta -gt $LIVETV_EXPIRATION_TIME ]; then
		"$SCRIPT_PATH"/scrape_livetv.py "$LIVETV_FILE"
	fi
else
	"$SCRIPT_PATH"/scrape_livetv.py "$LIVETV_FILE"
fi

while name=$(jq '.[] | "{\(.time)} \(.category) \(.name)"' "$LIVETV_FILE" | tr -d '"' |\
        sort | $ROFI_CMD -p "LiveTV" -format 'i s'); do

    name_idx=$(echo "$name" | cut -d' ' -f1)
    link_sel=".[$name_idx].link"
    event_link=$(jq "$link_sel" "$LIVETV_FILE" | tr -d '"')
    
    echo "$name"
    echo "name: $name_str sel: $link_sel event: $event_link"

    # follow redirect with curl using -L
    streams=$(curl -L "$event_link" | grep "OnClick=\"show_webplayer" |\
		sed -E 's/^.*href/href/; s/>.*//' | sed -r 's/.*href="([^"]+).*/\1/g')

	if [ -z "$streams" ]; then
		rofi -e "No stream links available, retry later."
	else
		selected_stream=$(echo -en "$streams" | $ROFI_CMD -p "Link")

		if [ -n "$selected_stream" ]; then

			xdg-open https:"$selected_stream"

			exit 0
		fi
	fi
done

exit 1
