#!/usr/bin/env bash

# depends: jq mpv

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
CHANNELS_FILE="$SCRIPT_PATH/data/channels.json"
CHANNELS_URL="https://iptv-org.github.io/iptv/channels.json"
PLAYER="mpv --no-resume-playback --force-window=immediate"
ROFI_CMD="rofi -dmenu -i"

play(){
    if [ -n "$1" ]; then
        printf "Fetching channel, please wait...\n"
        $PLAYER "$1"
    fi
}

select_channel(){
    local name var

    while name=$(cat "$CHANNELS_FILE" | jq ".[].name" | tr -d '"' |\
                 sort | $ROFI_CMD -p "TV" ); do
        var=".[] | select(.name==\"$name\") | .url"
        play "$(cat $CHANNELS_FILE | jq "$var" | tr -d '"')"

        exit 0
    done

    exit 1
}

mkdir -p "${CHANNELS_FILE%channels.json}"

if [[ ! -f "$CHANNELS_FILE" ]]; then
    printf "Downloading channel list...\n";

    wget -q --show-progress $CHANNELS_URL -O "$CHANNELS_FILE" ||\
        print_error "Cannot download channel list" 
fi

select_channel
