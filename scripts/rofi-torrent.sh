#!/usr/bin/bash
#
# https://github.com/Bugswriter/pirokit
#
# this script search torrent files from 1377x.to and scrape magnet links to be opened
# with a torrent client
#
# dependencies: rofi, curl

ROFI="${ROFI:-rofi}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"
TORRENT_CLIENT=${TORRENT_CLIENT:-qbittorrent}

torrent_cache="$ROFI_CACHE_DIR/torrents"
mkdir -p "$torrent_cache"

if [ -z $1 ]; then
  query=$(echo "" | $ROFI -dmenu -i -p "Search Torrent")
else
  query=$1
fi

if [ -z "$query" ]; then
  exit 1
fi

baseurl="https://www.1337x.to"
query="$(sed 's/ /+/g' <<<$query)"
counter=1

#curl -s $baseurl/category-search/$query/Movies/1/ > $torrent_cache/tmp.html
curl -s $baseurl/search/$query/$counter/ > $torrent_cache/tmp.html

# Get Titles
grep -o '<a href="/torrent/.*</a>' $torrent_cache/tmp.html |
  sed 's/<[^>]*>//g' > $torrent_cache/titles.bw

result_count=$(wc -l $torrent_cache/titles.bw | awk '{print $1}')

if [ "$result_count" -lt 1 ]; then
  $ROFI -e "No results found, try again."
  exit 1
fi

scrape_torrents() {
  # Get Titles
  grep -o '<a href="/torrent/.*</a>' $torrent_cache/tmp.html |
  sed 's/<[^>]*>//g' > $torrent_cache/titles.bw

  # Seeders and Leechers
  grep -o '<td class="coll-2 seeds.*</td>\|<td class="coll-3 leeches.*</td>' $torrent_cache/tmp.html |
    sed 's/<[^>]*>//g' | sed 'N;s/\n/ /' > $torrent_cache/seedleech.bw

  # Size
  grep -o '<td class="coll-4 size.*</td>' $torrent_cache/tmp.html |
    sed 's/<span class="seeds">.*<\/span>//g' |
    sed -e 's/<[^>]*>//g' > $torrent_cache/size.bw

  # Links
  grep -E '/torrent/' $torrent_cache/tmp.html |
    sed -E 's#.*(/torrent/.*)/">.*/#\1#' |
    sed 's/td>//g' > $torrent_cache/links.bw

  # Clearning up some data to display
  sed 's/\./ /g; s/\-/ /g' $torrent_cache/titles.bw |
    sed 's/[^A-Za-z0-9 ]//g' | tr -s " " > $torrent_cache/tmp && mv $torrent_cache/tmp $torrent_cache/titles.bw

  awk '{print NR " - ["$0"]"}' $torrent_cache/size.bw > $torrent_cache/tmp && mv $torrent_cache/tmp $torrent_cache/size.bw
  awk '{print "[S:"$1 ", L:"$2"]" }' $torrent_cache/seedleech.bw > $torrent_cache/tmp && mv $torrent_cache/tmp $torrent_cache/seedleech.bw
}

scrape_torrents

torrents=$(paste -d\   $torrent_cache/size.bw $torrent_cache/seedleech.bw $torrent_cache/titles.bw)
torrents="$torrents\nMore..."

# Getting the line number
while torrent=$(echo -en "$torrents" | $ROFI -dmenu -i -p "Torrent" | cut -d\- -f1 | awk '{$1=$1; print}'); do
  if [ -z "$torrent" ]; then
    exit 1
  fi

  if [ "$torrent" = "More..." ]; then
    counter=$((counter+1))
    curl -s $baseurl/search/$query/$counter/ >> $torrent_cache/tmp.html

    scrape_torrents

    torrents=$(paste -d\   $torrent_cache/size.bw $torrent_cache/seedleech.bw $torrent_cache/titles.bw)
    torrents="$torrents\nMore..."
  else
    # Building the url to scrape
    url=$(head -n $torrent $torrent_cache/links.bw | tail -n +$torrent)
    fullURL="${baseurl}${url}/"

    # Requesting page for magnet link
    curl -s $fullURL > $torrent_cache/tmp.html
    magnet=$(grep -Po "magnet:\?xt=urn:btih:[a-zA-Z0-9]*" $torrent_cache/tmp.html | head -n 1)

    $TORRENT_CLIENT "$magnet" & disown

    exit 0
  fi
done

exit 1
