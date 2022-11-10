#!/usr/bin/env bash

# depends: jq mpv

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"
ROFI_CMD="rofi -dmenu -i -p Channel"
CHANNELS_FILE="$SCRIPT_PATH/data/channels.json"
CHANNELS_URL="https://iptv-org.github.io/iptv/channels.json"
CACHE_FILE="$HOME/.cache/rofi-tv"
PLAYER="mpv --no-resume-playback --force-window=immediate"

play(){
    if [ -n "$1" ]; then
        printf "Fetching channel, please wait...\n"
        $PLAYER "$1"
    fi
}

select_channel(){
    local name var
    local selected_row

    selected_row=$(cat "$CACHE_FILE")

    while name=$(jq ".[].name" "$CHANNELS_FILE" | tr -d '"' |\
        sort | $ROFI_CMD -selected-row "${selected_row}" -format 'i s'); do

        index=$(echo "$name" | awk '{print $1;}')
        echo "$index" > "$CACHE_FILE"

        name_str=$(echo "$name" | cut -d' ' -f2-)
        var=".[] | select(.name==\"$name_str\") | .url"

        play "$(jq "$var" "$CHANNELS_FILE" | tr -d '"')"

        exit 0
    done

    exit 1
}

mkdir -p "${CHANNELS_FILE%channels.json}"

# TODO: do this job in background and display message
if [ ! -f "$CHANNELS_FILE" ]; then
    printf "Downloading channel list...\n";

    wget -q --show-progress $CHANNELS_URL -O "$CHANNELS_FILE" ||\
        print_error "Cannot download channel list" 
fi

#bash -c "sleep 2 && killall rofi" &
#pid=$!

#while kill -0 $pid 2>/dev/null
#do
#    rofi -e "Downloading channel list..." -normal-window
#done

select_channel
