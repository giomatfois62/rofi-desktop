#!/usr/bin/bash
#
# https://github.com/Bugswriter/pirokit
#
# this script search torrent files from 1377x.to and scrape magnet links to be opened
# with a torrent client
#
# dependencies: rofi, curl

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
CACHE_DIR=${CACHE_DIR:-"$HOME/.cache/pirokit"}
TORRENT_CLIENT=${TORRENT_CLIENT:-qbittorrent}

mkdir -p "$CACHE_DIR"

if [ -z $1 ]; then
  query=$(echo "" | $ROFI_CMD -p "Search Torrent: ")
else
  query=$1
fi

if [ -z "$query" ]; then
  exit 1
fi

baseurl="https://1337x.to"
query="$(sed 's/ /+/g' <<<$query)"

#curl -s https://1337x.to/category-search/$query/Movies/1/ > $CACHE_DIR/tmp.html
curl -s https://1337x.to/search/$query/1/ > $CACHE_DIR/tmp.html

# Get Titles
grep -o '<a href="/torrent/.*</a>' $CACHE_DIR/tmp.html |
  sed 's/<[^>]*>//g' > $CACHE_DIR/titles.bw

result_count=$(wc -l $CACHE_DIR/titles.bw | awk '{print $1}')

if [ "$result_count" -lt 1 ]; then
  rofi -e "No results found, try again."
  exit 1
fi

# Seeders and Leechers
grep -o '<td class="coll-2 seeds.*</td>\|<td class="coll-3 leeches.*</td>' $CACHE_DIR/tmp.html |
  sed 's/<[^>]*>//g' | sed 'N;s/\n/ /' > $CACHE_DIR/seedleech.bw

# Size
grep -o '<td class="coll-4 size.*</td>' $CACHE_DIR/tmp.html |
  sed 's/<span class="seeds">.*<\/span>//g' |
  sed -e 's/<[^>]*>//g' > $CACHE_DIR/size.bw

# Links
grep -E '/torrent/' $CACHE_DIR/tmp.html |
  sed -E 's#.*(/torrent/.*)/">.*/#\1#' |
  sed 's/td>//g' > $CACHE_DIR/links.bw

# Clearning up some data to display
sed 's/\./ /g; s/\-/ /g' $CACHE_DIR/titles.bw |
  sed 's/[^A-Za-z0-9 ]//g' | tr -s " " > $CACHE_DIR/tmp && mv $CACHE_DIR/tmp $CACHE_DIR/titles.bw

awk '{print NR " - ["$0"]"}' $CACHE_DIR/size.bw > $CACHE_DIR/tmp && mv $CACHE_DIR/tmp $CACHE_DIR/size.bw
awk '{print "[S:"$1 ", L:"$2"]" }' $CACHE_DIR/seedleech.bw > $CACHE_DIR/tmp && mv $CACHE_DIR/tmp $CACHE_DIR/seedleech.bw

# Getting the line number
LINE=$(paste -d\   $CACHE_DIR/size.bw $CACHE_DIR/seedleech.bw $CACHE_DIR/titles.bw |
  $ROFI_CMD |
  cut -d\- -f1 |
  awk '{$1=$1; print}')

if [ -z "$LINE" ]; then
  exit 1
fi

# Building the url to scrape
url=$(head -n $LINE $CACHE_DIR/links.bw | tail -n +$LINE)
fullURL="${baseurl}${url}/"

# Requesting page for magnet link
curl -s $fullURL > $CACHE_DIR/tmp.html
magnet=$(grep -Po "magnet:\?xt=urn:btih:[a-zA-Z0-9]*" $CACHE_DIR/tmp.html | head -n 1)

$TORRENT_CLIENT "$magnet"

exit 0
