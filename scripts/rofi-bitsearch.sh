#!/usr/bin/bash
#
# this script search torrent files from bitsearch.to and scrape magnet links to be opened
# with a torrent client
#
# dependencies: rofi, python3-requests

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
TORRENT_CACHE=${TORRENT_CACHE:-"$HOME/.cache/torrents"}
TORRENT_CLIENT=${TORRENT_CLIENT:-qbittorrent}
TORRENT_PLACEHOLDER=${TORRENT_PLACEHOLDER:-"Type something and press \"Enter\" to search"}

mkdir -p "$TORRENT_CACHE"

if [ -z $1 ]; then
    query=$(echo "" | $ROFI_CMD -theme-str "entry{placeholder:\"$TORRENT_PLACEHOLDER\";"} -p "Search Torrent")
else
    query=$1
fi

if [ -z "$query" ]; then
    exit 1
fi

# search first results page
counter=1
selected_row=$((20*($counter-1)))

"$SCRIPT_PATH/scrape_bitsearch.py" "$query" "$counter" > "$TORRENT_CACHE/bitsearch"
result_count=$(cat "$TORRENT_CACHE/bitsearch" | wc -l)

if [ "$result_count" -lt 1 ]; then
    rofi -e "No results found, try again."
    exit 1
fi

torrents=$(cat "$TORRENT_CACHE/bitsearch" | cut -d' ' -f2-)
torrents="$torrents\nMore..."

# display menu
while selection=$(echo -en "$torrents" | $ROFI_CMD -p "Torrent" -format 'i s' -selected-row ${selected_row}); do
    row=$(echo "$selection" | awk '{print $1;}')
    torrent=$(echo "$selection" | cut -d' ' -f2-)

    if [ -z "$torrent" ]; then
        exit 1
    fi

    if [ "$torrent" = "More..." ]; then
        # increment page counter and search again
        counter=$((counter+1))
        selected_row=$((20*($counter-1)))

        "$SCRIPT_PATH/scrape_bitsearch.py" "$query" "$counter" >> "$TORRENT_CACHE/bitsearch"

        torrents=$(cat "$TORRENT_CACHE/bitsearch" | cut -d' ' -f2-)
        torrents="$torrents\nMore..."
    else
        # open selected magnet link
        magnet=$(sed "${row}q;d" "$TORRENT_CACHE/bitsearch" | cut -d' ' -f1)

        $TORRENT_CLIENT "$magnet" & disown

        exit 0
    fi
done

exit 1
