#!/usr/bin/bash
#
# https://github.com/Bugswriter/pirokit
#
# this script search torrent files from 1377x.to and scrape magnet links to be opened
# with a torrent client
#
# dependencies: rofi, curl

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

baseurl="https://www.1337xx.to"
query="$(sed 's/ /+/g' <<<$query)"
counter=1

#curl -s $baseurl/category-search/$query/Movies/1/ > $TORRENT_CACHE/tmp.html
curl -s $baseurl/search/$query/$counter/ > $TORRENT_CACHE/tmp.html

# Get Titles
grep -o '<a href="/torrent/.*</a>' $TORRENT_CACHE/tmp.html |
  sed 's/<[^>]*>//g' > $TORRENT_CACHE/titles.bw

result_count=$(wc -l $TORRENT_CACHE/titles.bw | awk '{print $1}')

if [ "$result_count" -lt 1 ]; then
  rofi -e "No results found, try again."
  exit 1
fi

scrape_torrents() {
  # Get Titles
  grep -o '<a href="/torrent/.*</a>' $TORRENT_CACHE/tmp.html |
  sed 's/<[^>]*>//g' > $TORRENT_CACHE/titles.bw

  # Seeders and Leechers
  grep -o '<td class="coll-2 seeds.*</td>\|<td class="coll-3 leeches.*</td>' $TORRENT_CACHE/tmp.html |
    sed 's/<[^>]*>//g' | sed 'N;s/\n/ /' > $TORRENT_CACHE/seedleech.bw

  # Size
  grep -o '<td class="coll-4 size.*</td>' $TORRENT_CACHE/tmp.html |
    sed 's/<span class="seeds">.*<\/span>//g' |
    sed -e 's/<[^>]*>//g' > $TORRENT_CACHE/size.bw

  # Links
  grep -E '/torrent/' $TORRENT_CACHE/tmp.html |
    sed -E 's#.*(/torrent/.*)/">.*/#\1#' |
    sed 's/td>//g' > $TORRENT_CACHE/links.bw

  # Clearning up some data to display
  sed 's/\./ /g; s/\-/ /g' $TORRENT_CACHE/titles.bw |
    sed 's/[^A-Za-z0-9 ]//g' | tr -s " " > $TORRENT_CACHE/tmp && mv $TORRENT_CACHE/tmp $TORRENT_CACHE/titles.bw

  awk '{print NR " - ["$0"]"}' $TORRENT_CACHE/size.bw > $TORRENT_CACHE/tmp && mv $TORRENT_CACHE/tmp $TORRENT_CACHE/size.bw
  awk '{print "[S:"$1 ", L:"$2"]" }' $TORRENT_CACHE/seedleech.bw > $TORRENT_CACHE/tmp && mv $TORRENT_CACHE/tmp $TORRENT_CACHE/seedleech.bw
}

scrape_torrents

torrents=$(paste -d\   $TORRENT_CACHE/size.bw $TORRENT_CACHE/seedleech.bw $TORRENT_CACHE/titles.bw)
torrents="$torrents\nMore..."

# Getting the line number
while torrent=$(echo -en "$torrents" | $ROFI_CMD -p "Torrent" | cut -d\- -f1 | awk '{$1=$1; print}'); do
  if [ -z "$torrent" ]; then
    exit 1
  fi

  if [ "$torrent" = "More..." ]; then
    counter=$((counter+1))
    curl -s $baseurl/search/$query/$counter/ >> $TORRENT_CACHE/tmp.html

    scrape_torrents

    torrents=$(paste -d\   $TORRENT_CACHE/size.bw $TORRENT_CACHE/seedleech.bw $TORRENT_CACHE/titles.bw)
    torrents="$torrents\nMore..."
  else
    # Building the url to scrape
    url=$(head -n $torrent $TORRENT_CACHE/links.bw | tail -n +$torrent)
    fullURL="${baseurl}${url}/"

    # Requesting page for magnet link
    curl -s $fullURL > $TORRENT_CACHE/tmp.html
    magnet=$(grep -Po "magnet:\?xt=urn:btih:[a-zA-Z0-9]*" $TORRENT_CACHE/tmp.html | head -n 1)

    $TORRENT_CLIENT "$magnet" & disown

    exit 0
  fi
done

exit 1
