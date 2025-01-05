#!/usr/bin/bash
#
# this script search torrent files from bitsearch.to and scrape magnet links to be opened
# with a torrent client
#
# dependencies: rofi, curl, xmllint

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"
TORRENT_CLIENT=${TORRENT_CLIENT:-qbittorrent}
TORRENT_PLACEHOLDER="Type something and press \"Enter\" to search torrents"
TORRENT_CACHE="$ROFI_CACHE_DIR/bitsearch"

get_torrents() {
    page="$1"
    query=$(echo "$2" | sed 's/ /+/g')
    url="https://bitsearch.to/search?q=$query&page=$page"

    bitsearch=$(curl -s "$url")

    titles=$(echo "$bitsearch" | \
        xmllint --html --xpath '//h5[@class="title w-100 truncate"]/a/text()' -)

    magnets=$(echo "$bitsearch" | \
        xmllint --html --xpath '//a[@class="dl-magnet"]/@href' - | \
        sed -n 's/.*href="\([^"]*\).*/\1/p')

    sizes=$(echo "$bitsearch" | \
        xmllint --html --xpath '//div[@class="stats"]/div[2]/text()' - | \
        sed 's/^/\[/' | \
        sed 's/$/\]/')

    seeders=$(echo "$bitsearch" | \
        xmllint --html --xpath '//div[@class="stats"]/div[3]/font/text()' - | \
        sed 's/^/S:/')

    leechers=$(echo "$bitsearch" | \
        xmllint --html --xpath '//div[@class="stats"]/div[4]/font/text()' - | \
        sed 's/^/L:/')

    #count=$(echo "$sizes" | wc -l)
    #indices=$(seq $((20*(page - 1) + 1)) $((20*(page - 1) + count)))
    if [ -n "$titles" ]; then
        paste -d'|' <(echo "$magnets") <(echo "$sizes") <(echo "$seeders") <(echo "$leechers") <(echo "$titles")
    fi
}

mkdir -p "$ROFI_CACHE_DIR"

if [ -z $1 ]; then
    query=$(echo "" | $ROFI_CMD -theme-str "entry{placeholder:\"$TORRENT_PLACEHOLDER\";"} -p "Search Torrents")
else
    query=$1
fi

if [ -z "$query" ]; then
    exit 1
fi

while [ -n "$query" ]; do
    # search first results page
    counter=1
    selected_row=$((20*($counter-1)))

    results=$(get_torrents "$counter" "$query")

    if [ -z "$results" ]; then
        rofi -e "No results found, try again."
        exit 1
    else
        echo "$results" > "$TORRENT_CACHE"
    fi

    torrents=$(cat "$TORRENT_CACHE" | cut -d'|' -f2- | column -s "|" -t)
    torrents="$torrents\nMore..."

    # display menu
    while selection=$(echo -en "$torrents" | $ROFI_CMD -p "Torrent" -format 'i s' -selected-row ${selected_row}); do
        row=$(($(echo "$selection" | awk '{print $1;}') + 1))
        torrent=$(echo "$selection" | cut -d' ' -f2-)

        if [ -z "$torrent" ]; then
            exit 1
        fi

        if [ "$torrent" = "More..." ]; then
            # increment page counter and search again
            counter=$((counter+1))
            selected_row=$((20*($counter-1)))

            results=$(get_torrents "$counter" "$query")

            if [ -z "$results" ]; then
                counter=$((counter-1))
            else
                echo "$results" >> "$TORRENT_CACHE"
            fi

            torrents=$(cat "$TORRENT_CACHE" | cut -d'|' -f2- | column -s "|" -t)
            torrents="$torrents\nMore..."
        else
            # open selected magnet link
            magnet=$(sed "${row}q;d" "$TORRENT_CACHE" | cut -d'|' -f1)

            $TORRENT_CLIENT "$magnet" & disown

            exit 0
        fi
    done

    query=$(echo "" | $ROFI_CMD -theme-str "entry{placeholder:\"$TORRENT_PLACEHOLDER\";"} -p "Search Torrents")
done

exit 1
