#!/usr/bin/env bash
#
# this script fetches and shows a list of radio stations
# selecting an entry will open the radio stream with mpv
#
# dependencies: rofi, wget, jq, mpv

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_DATA_DIR="${ROFI_DATA_DIR:-$SCRIPT_PATH/data}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"
RADIO_ICONS="${RADIO_ICONS:-}"
RADIO_PLAYER="${RADIO_PLAYER:-mpv --no-resume-playback --force-window=immediate}"

radio_file="$ROFI_DATA_DIR/radios.json"
radio_cache="$ROFI_CACHE_DIR/rofi-radio"
radio_url="https://de1.api.radio-browser.info/json/stations/search?name="
radio_preview="$SCRIPT_PATH/download_icon.sh {input} {output} {size}"

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

    selected_row=$(cat "$radio_cache")
    
    # favicon key contains the url to the icon to show
    while name=$(\
            jq '.[] | "[\(.countrycode)] \(.name)<ICON>\(.favicon)"' "$radio_file" |\
            tr -d '"' |\
            sort |\
            sed -e "s/<ICON>/\\x00icon\\x1fthumbnail:\/\//g" |\
            $ROFI -dmenu -i -p "Radio" -selected-row "${selected_row}" -format 'i s' $flags -preview-cmd "$radio_preview" \
        ); do

        index=$(echo "$name" | awk '{print $1;}')
        echo "$index" > "$radio_cache"

        name_str=$(echo "$name" | cut -d' ' -f3-)
        var=".[] | select(.name==\"$name_str\") | .url"

        play "$(jq "$var" "$radio_file" | tr -d '"')"

        exit 0
    done

    exit 1
}

mkdir -p "${radio_file%radios.json}"

# TODO: do this job in background and display message
if [ ! -f "$radio_file" ];then
    printf "Downloading channel list...\n";

    wget -q --show-progress "$radio_url" -O "$radio_file" ||\
        print_error "Cannot download channel list" 
fi

select_channel
