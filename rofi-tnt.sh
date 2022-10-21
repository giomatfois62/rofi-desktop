#!/bin/sh

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
TNT_URL="https://raw.githubusercontent.com/edoardopigaiani/tntvillage-release-dump/master/tntvillage-release-dump.csv"
TNT_FILE=$SCRIPT_PATH/tntvillage-release-dump.csv
ROFI_CMD="rofi -dmenu -i"

if [[ ! -f "$TNT_FILE" ]];then
    printf "Downloading torrent list...\n";

    wget -q --show-progress $TNT_URL -O "$TNT_FILE" ||\
        print_error "Cannot download torrent list" 
fi

awk -F "\"*,\"*" '{print $6 $7" - " $2}' $TNT_FILE |\
    $ROFI_CMD -p "Torrent" | rev | cut -d " " -f 1 | rev |\
    awk '{print "magnet:?xt=urn:btih:"$1"&dn=&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A80&tr=udp%3A%2F%2Fopentor.org%3A2710&tr=udp%3A%2F%2Ftracker.ccc.de%3A80&tr=udp%3A%2F%2Ftracker.blackunicorn.xyz%3A6969&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969"}' |\
    xargs -i xdg-open {} && exit 0

exit 1
