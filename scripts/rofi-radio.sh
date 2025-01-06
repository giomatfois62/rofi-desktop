#!/usr/bin/env bash
#
# this script fetches and shows a list of radio stations
# selecting an entry will open the radio stream with mpv
#
# dependencies: rofi, wget, jq, mpv

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
ROFI_DATA_DIR="${ROFI_DATA_DIR:-$SCRIPT_PATH/data}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"
RADIO_ICONS="${RADIO_ICONS:-}"
RADIO_PLAYER="${RADIO_PLAYER:-mpv --no-resume-playback --force-window=immediate}"
RADIO_FILE="$ROFI_DATA_DIR/radios.json"
RADIO_CACHE="$ROFI_CACHE_DIR/rofi-radio"
RADIO_URL="https://de1.api.radio-browser.info/json/stations/search?name="
PREVIEW_CMD="$SCRIPT_PATH/download_icon.sh {input} {output} {size}"

if [ -n "$RADIO_ICONS" ]; then
    flags="-show-icons"
fi

play(){
    if [ -n "$1" ]; then
        printf "Fetching channel, please wait...\n"
        $RADIO_PLAYER "$1"
    fi
}

select_channel(){
    local name var
    local selected_row
    local show_favicon

    selected_row=$(cat "$RADIO_CACHE")
    
    # favicon key contains the url to the icon to show
    while name=$(\
            jq '.[] | "[\(.countrycode)] \(.name)<ICON>\(.favicon)"' "$RADIO_FILE" |\
            tr -d '"' |\
            sort |\
            sed -e "s/<ICON>/\\x00icon\\x1fthumbnail:\/\//g" |\
            $ROFI_CMD -p "Radio" -selected-row "${selected_row}" -format 'i s' $flags -preview-cmd "$PREVIEW_CMD" \
        ); do

        index=$(echo "$name" | awk '{print $1;}')
        echo "$index" > "$RADIO_CACHE"

        name_str=$(echo "$name" | cut -d' ' -f3-)
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
