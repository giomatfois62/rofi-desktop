#!/bin/sh

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
ROFI_CMD="rofi -dmenu -i -p Torrent"
TNT_URL="https://raw.githubusercontent.com/edoardopigaiani/tntvillage-release-dump/master/tntvillage-release-dump.csv"
TNT_FILE=$SCRIPT_PATH/data/tntvillage-release-dump.csv

mkdir -p "${TNT_FILE%tntvillage-release-dump.csv}"

# TODO: do this job in background and display message
if [[ ! -f "$TNT_FILE" ]];then
    printf "Downloading torrent list...\n";

    wget -q --show-progress $TNT_URL -O "$TNT_FILE" ||\
        print_error "Cannot download torrent list" 
fi

selected=$(\
    awk -F "\"*,\"*" '{print $6 $7" - " $2}' $TNT_FILE |\
    $ROFI_CMD | rev | cut -d " " -f 1 | rev |\
    awk '{print "magnet:?xt=urn:btih:"$1"&dn=&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A80&tr=udp%3A%2F%2Fopentor.org%3A2710&tr=udp%3A%2F%2Ftracker.ccc.de%3A80&tr=udp%3A%2F%2Ftracker.blackunicorn.xyz%3A6969&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969"}'\
)

if [ ${#selected} -gt 0 ]; then
    xdg-open $selected
    exit 0
fi

exit 1
