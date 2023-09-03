#!/usr/bin/env bash
#
# this script fetches and show a list of tv stations
# selecting an entry will open the tv stream with mpv
#
# dependencies: rofi, jq, mpv

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
TV_PLAYER="${TV_PLAYER:-mpv --no-resume-playback --force-window=immediate}"
TV_FILE="${TV_FILE:-$SCRIPT_PATH/../data/channels.json}"
TV_CACHE="${TV_CACHE:-$HOME/.cache/rofi-tv}"
TV_URL="https://iptv-org.github.io/iptv/channels.json"

play(){
    if [ -n "$1" ]; then
        printf "Fetching channel, please wait...\n"
        $TV_PLAYER "$1"
    fi
}

select_channel(){
    local name var
    local selected_row

    selected_row=$(cat "$TV_CACHE")

    while name=$(jq '.[] | "\(.name) [\(.countries[0].name)]"' "$TV_FILE" | tr -d '"' |\
        sort | $ROFI_CMD -p "Channel" -selected-row "${selected_row}" -format 'i s'); do

        index=$(echo "$name" | awk '{print $1;}')
        echo "$index" > "$TV_CACHE"

        name_str=$(echo "$name" | cut -d' ' -f2- | cut -d"[" -f1 | sed 's/ *$//g')
        echo $name_str
        var=".[] | select(.name==\"$name_str\") | .url"

        play "$(jq "$var" "$TV_FILE" | tr -d '"')"

        exit 0
    done

    exit 1
}

mkdir -p "${TV_FILE%channels.json}"

# TODO: do this job in background and display message
if [ ! -f "$TV_FILE" ]; then
    printf "Downloading channel list...\n";

    wget -q --show-progress $TV_URL -O "$TV_FILE" ||\
        print_error "Cannot download channel list" 
fi

#bash -c "sleep 2 && killall rofi" &
#pid=$!

#while kill -0 $pid 2>/dev/null
#do
#    rofi -e "Downloading channel list..." -normal-window
#done

select_channel
