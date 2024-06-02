#!/usr/bin/env bash
#
# this script fetches and show a list of iptv stations
# selecting an entry will open the tv stream with mpv
#
# dependencies: rofi, mpv

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
ROFI_DATA_DIR="${ROFI_DATA_DIR:-$SCRIPT_PATH/data}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"
TV_ICONS="${TV_ICONS:-}"
TV_PLAYER="${TV_PLAYER:-mpv --no-resume-playback --force-window=immediate}"
TV_FILE="$ROFI_DATA_DIR/channels.m3u"
TV_CACHE="$ROFI_CACHE_DIR/rofi-tv"
TV_URL="https://iptv-org.github.io/iptv/index.m3u"
PREVIEW_CMD=$SCRIPT_PATH'/download_tv_icon.sh "{input}" "{output}"'

if [ ! -f "$TV_FILE" ]; then
    printf "Downloading channel list...\n";

    wget -q --show-progress $TV_URL -O "$TV_FILE" ||\
        print_error "Cannot download channel list"
fi

if [ -n "$TV_ICONS" ]; then
    flags="-show-icons"
fi

selected_row=$(cat "$TV_CACHE")

# TODO: tvg-logo contains the url to the icon to show
while channel=$(\
    grep "#EXTINF" "$TV_FILE" | rev | cut -d"," -f1  | rev | awk '{print $0"<ICON>"$0}' |\
    sed -e "s/<ICON>/\\x00icon\\x1fthumbnail:\/\//g" |\
    $ROFI_CMD $flags -preview-cmd "$PREVIEW_CMD" -selected-row "${selected_row}" -format 'i s' -p "Channel"); do

    channel_index=$(echo "$channel" | awk '{print $1;}')
    channel_name=$(echo "$channel" | cut -d' ' -f2-)
    channel_name=${channel_name//[/\\[}
    channel_name=${channel_name//]/\\]}

    channel_link=$(grep -A 1 "$channel_name" "$TV_FILE" | tail -1)

    echo "Playing " "$channel_link"
    echo "$channel_index" > "$TV_CACHE"

    $TV_PLAYER "$channel_link"

    exit 0
done

exit 1
