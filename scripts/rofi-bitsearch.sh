#!/usr/bin/bash
#
# this script search torrent files from bitsearch.to and scrape magnet links to be opened
# with a torrent client
#
# dependencies: rofi, curl, xmllint

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"
TORRENT_CLIENT=${TORRENT_CLIENT:-qbittorrent}

torrent_cache="$ROFI_CACHE_DIR/bitsearch"
query="$1"

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

    if [ -n "$titles" ]; then
        paste -d'|' <(echo "$magnets") <(echo "$sizes") <(echo "$seeders") <(echo "$leechers") <(echo "$titles")
    fi
}

[ -z "$query" ] && query=$($ROFI -dmenu -i -p "Search Torrents")
[ -z "$query" ] && exit 1

while [ -n "$query" ]; do
    # search first results page
    page=1
    row=$((20*($page-1)))

    results=$(get_torrents "$page" "$query")

    if [ -z "$results" ]; then
        $ROFI -e "No torrents found, try again."
        exit 1
    else
        echo "$results" > "$torrent_cache"
    fi

    torrents=$(cat "$torrent_cache" | cut -d'|' -f2- | column -s "|" -t)
    torrents="$torrents\nMore..."

    # display torrents
    while selection=$(echo -en "$torrents" | \
        $ROFI -dmenu -i -p "Torrent" -format 'i s' -selected-row ${row}); do

        row=$(($(echo "$selection" | awk '{print $1;}') + 1))
        torrent=$(echo "$selection" | cut -d' ' -f2-)

        [ -z "$torrent" ] && exit 1

        if [ "$torrent" = "More..." ]; then
            # increment page page and search again
            page=$((page+1))
            row=$((20*($page-1)))

            results=$(get_torrents "$page" "$query")

            if [ -z "$results" ]; then
                page=$((page-1))
            else
                echo "$results" >> "$torrent_cache"
            fi

            torrents=$(cat "$torrent_cache" | cut -d'|' -f2- | column -s "|" -t)
            torrents="$torrents\nMore..."
        else
            # open selected magnet link
            magnet=$(sed "${row}q;d" "$torrent_cache" | cut -d'|' -f1)

            $TORRENT_CLIENT "$magnet" & disown

            exit 0
        fi
    done

    query=$($ROFI -dmenu -i -p "Search Torrents")
done

exit 1
