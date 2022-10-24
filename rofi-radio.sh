#!/usr/bin/env bash

# depends: jq mpv

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
ROFI_CMD="rofi -dmenu -i -p Radio"
CHANNELS_FILE="$SCRIPT_PATH/data/radios.json"
CHANNELS_URL="https://de1.api.radio-browser.info/json/stations/search?name="
CACHE_FILE="$HOME/.cache/rofi-radio"
PLAYER="mpv --no-resume-playback --force-window=immediate"

play(){
    if [ -n "$1" ]; then
        printf "Fetching channel, please wait...\n"
        $PLAYER "$1"
    fi
}

select_channel(){
    local name var
    local selected_row=$(cat $CACHE_FILE)

    while name=$(cat "$CHANNELS_FILE" | jq ".[].name" | tr -d '"' |\
                 sort | $ROFI_CMD -selected-row ${selected_row} -format 'i s'); do
        index=$(echo $name | awk '{print $1;}')
        echo $index > $CACHE_FILE

        name_str=$(echo $name | cut -d' ' -f2-)

        var=".[] | select(.name==\"$name_str\") | .url"
        play "$(cat $CHANNELS_FILE | jq "$var" | tr -d '"')"

        exit 0
    done

    exit 1
}

mkdir -p "${CHANNELS_FILE%radios.json}"

if [[ ! -f "$CHANNELS_FILE" ]];then
    printf "Downloading channel list...\n";

    wget -q --show-progress $CHANNELS_URL -O "$CHANNELS_FILE" ||\
        print_error "Cannot download channel list" 
fi

select_channel
