#!/usr/bin/env bash
#
# this script fetches and show a list of iptv stations
# selecting an entry will open the tv stream with mpv
#
# dependencies: rofi, mpv

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
TV_PLAYER="${TV_PLAYER:-mpv --no-resume-playback --force-window=immediate}"
TV_FILE="${TV_FILE:-$SCRIPT_PATH/../data/channels.m3u}" # ../data/channels.m3u
TV_CACHE="${TV_CACHE:-$HOME/.cache/rofi-tv}"
TV_URL="https://iptv-org.github.io/iptv/index.nsfw.m3u"

if [ ! -f "$TV_FILE" ]; then
    printf "Downloading channel list...\n";

    wget -q --show-progress $TV_URL -O "$TV_FILE" ||\
        print_error "Cannot download channel list"
fi

selected_row=$(cat "$TV_CACHE")

while channel=$(grep "#EXTINF" "$TV_FILE" | rev | cut -d"," -f1  | rev |\
        $ROFI_CMD -selected-row "${selected_row}" -format 'i s' -p "Channel"); do

    channel_index=$(echo "$channel" | awk '{print $1;}')
    channel_name=$(echo "$channel" | cut -d' ' -f2-)
    channel_name=${channel_name//[/\\[}
    channel_name=${channel_name//]/\\]}

    channel_link=$(grep -A 1 "$channel_name$" "$TV_FILE" | tail -1)

    echo "Playing " "$channel_link"
    echo "$channel_index" > "$TV_CACHE"

    $TV_PLAYER "$channel_link"

    exit 0
done

exit 1
