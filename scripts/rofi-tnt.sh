#!/bin/sh
#
# this script fetches and search torrents inside the tntvillage csv archive
# selecting an entry will generate the magnet link and open it
#
# dependencies: rofi

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_DATA_DIR="${ROFI_DATA_DIR:-$SCRIPT_PATH/data}"
TORRENT_CLIENT=${TORRENT_CLIENT:-qbittorrent}
TNT_FILE="$ROFI_DATA_DIR/tntvillage-release-dump.csv"
TNT_URL="https://raw.githubusercontent.com/edoardopigaiani/tntvillage-release-dump/master/tntvillage-release-dump.csv"

mkdir -p "${TNT_FILE%tntvillage-release-dump.csv}"

# TODO: do this job in background and display message
if [ ! -f "$TNT_FILE" ];then
    printf "Downloading torrent list...\n";

    wget -q --show-progress $TNT_URL -O "$TNT_FILE" ||\
        print_error "Cannot download torrent list" 
fi

selected=$(\
    awk -F "\"*,\"*" 'NR>1 {print $6 $7" - " $2}' "$TNT_FILE" |\
    $ROFI -dmenu -i -p "Torrent" | rev | cut -d " " -f 1 | rev |\
    awk '{print "magnet:?xt=urn:btih:"$1"&dn=&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A80&tr=udp%3A%2F%2Fopentor.org%3A2710&tr=udp%3A%2F%2Ftracker.ccc.de%3A80&tr=udp%3A%2F%2Ftracker.blackunicorn.xyz%3A6969&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969"}'\
)

if [ -n "$selected" ]; then
    $TORRENT_CLIENT "$selected"
    exit 0
fi

exit 1
