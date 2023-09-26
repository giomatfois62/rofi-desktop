#!/usr/bin/env bash
#
# this script fetches and shows a list of radio stations
# selecting an entry will open the radio stream with mpv
#
# dependencies: rofi, wget, jq, mpv

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
RADIO_PLAYER="${RADIO_PLAYER:-mpv --no-resume-playback --force-window=immediate}"
RADIO_FILE="${RADIO_FILE:-$SCRIPT_PATH/../data/radios.json}"
RADIO_CACHE="${RADIO_CACHE:-$HOME/.cache/rofi-radio}"
RADIO_URL="https://de1.api.radio-browser.info/json/stations/search?name="

play(){
    if [ -n "$1" ]; then
        printf "Fetching channel, please wait...\n"
        $RADIO_PLAYER "$1"
    fi
}

select_channel(){
    local name var
    local selected_row

    selected_row=$(cat "$RADIO_CACHE")

    while name=$(jq '.[] | "\(.name) {\(.country)}"' "$RADIO_FILE" | tr -d '"' |\
        sort | $ROFI_CMD -p "Radio" -selected-row "${selected_row}" -format 'i s'); do

        index=$(echo "$name" | awk '{print $1;}')
        echo "$index" > "$RADIO_CACHE"

        name_str=$(echo "$name" | cut -d' ' -f2- | cut -d"{" -f1 | sed 's/ *$//g')
        var=".[] | select(.name==\"$name_str\") | .url"

        play "$(jq "$var" "$RADIO_FILE" | tr -d '"')"

        exit 0
    done

    exit 1
}

mkdir -p "${RADIO_FILE%radios.json}"

# TODO: do this job in background and display message
if [ ! -f "$RADIO_FILE" ];then
    printf "Downloading channel list...\n";

    wget -q --show-progress "$RADIO_URL" -O "$RADIO_FILE" ||\
        print_error "Cannot download channel list" 
fi

select_channel
