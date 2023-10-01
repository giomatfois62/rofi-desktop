#!/usr/bin/env bash
#
# this script scrape and show xkcd comics
#
# dependencies: rofi, jq, python3-lxml, python3-requests

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
XKCD_FILE=${LIVETV_FILE:-"$HOME/.cache/xkcd"}
XKCD_CACHE=${LIVETV_FILE:-"$HOME/.cache/xkcd_cache"}
XKCD_EXPIRATION_TIME=${XKCD_EXPIRATION_TIME:-86400} # refresh xkcd file every day
XKCD_ICON_SIZE=${XKCD_ICON_SIZE:-35}

mkdir -p "$XKCD_CACHE"

if [ -f "$XKCD_FILE" ]; then
    # compute time delta between current date and news file date
	news_date=$(date -r "$XKCD_FILE" +%s)
	current_date=$(date +%s)

	delta=$((current_date - news_date))

	# refresh xkcd file if it's too old
	if [ $delta -gt $XKCD_EXPIRATION_TIME ]; then
		"$SCRIPT_PATH"/scrape_xkcd.py "$XKCD_FILE"
	fi
else
	"$SCRIPT_PATH"/scrape_xkcd.py "$XKCD_FILE"
fi

while comic=$(cat "$XKCD_FILE" | $ROFI_CMD -p "XKCD"); do
    comic_id=$(echo "$comic" | cut -d' ' -f1)
    comic_title=$(echo "$comic" | cut -d' ' -f2-)
    comic_url="https://xkcd.com/$comic_id/info.0.json"
    comic_file="$XKCD_CACHE/$comic_id"

    if [ ! -f "$comic_file" ]; then
        curl --silent "$comic_url" -o "$comic_file"
        comic_image=$(jq -r '.img' "$comic_file")
        curl --silent "$comic_image" -o "$XKCD_CACHE/$comic_id.png"
    fi

    comic_alt=$(jq -r '.alt' "$comic_file")
    comic_date=$(jq -r '"\(.day)/\(.month)/\(.year)"' "$comic_file")
    comic_image="$XKCD_CACHE/$comic_id.png"

    build_theme() {
        icon_size=$1

        echo "element{orientation:vertical;}element-text{horizontal-align:0.5;}element-icon{size:$icon_size.0000em;}listview{lines:1;columns:1;}"
    }

    echo -en "Open in Browser\x00icon\x1f$comic_image\n" | $ROFI_CMD -show-icons -theme-str $(build_theme $XKCD_ICON_SIZE) -p "$comic_title" -mesg "($comic_date) $comic_alt"

    [ "$?" -eq 0 ] && xdg-open "https://xkcd.com/$comic_id" && exit 0
done

exit 1
