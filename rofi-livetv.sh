#!/usr/bin/env bash

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
# TODO: make file path configurable and use it in python script
LIVETV_FILE="$HOME/.cache/livetv.json"
LIVETV_EXPIRATION_TIME=${LIVETV_EXPIRATION_TIME:-3600} # refresh livetv file every hour

if [ -f "$LIVETV_FILE" ]; then
    # compute time delta between current date and news file date
	news_date=$(date -r "$LIVETV_FILE" +%s)
	current_date=$(date +%s)

	delta=$((current_date - news_date))

	# refresh livetv file if it's too old
	if [ $delta -gt $LIVETV_EXPIRATION_TIME ]; then
        # TODO: call python script
		echo "Refreshing livetv file"
		"$SCRIPT_PATH"/scrape_livetv.py
	fi
else
    # TODO: call python script
	echo "Creating livetv file"
	"$SCRIPT_PATH"/scrape_livetv.py
fi

while name=$(jq '.[] | "\(.name) {\(.time)} \(.category)"' "$LIVETV_FILE" | tr -d '"' |\
        sort | $ROFI_CMD -p "LiveTV" -format 'i s'); do

    name_str=$(echo "$name" | cut -d' ' -f2- | cut -d"{" -f1 | sed 's/ *$//g')
    link_sel=".[] | select(.name==\"$name_str\") | .link"

    xdg-open "$(jq "$link_sel" "$LIVETV_FILE" | tr -d '"')"

    exit 0
done

exit 1
