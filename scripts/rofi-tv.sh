#!/usr/bin/env bash
#
# this script fetches and show a list of iptv stations
# selecting an entry will open the tv stream with mpv
#
# dependencies: rofi, mpv

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_DATA_DIR="${ROFI_DATA_DIR:-$SCRIPT_PATH/data}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"
ROFI_ICONS="${ROFI_ICONS:-}"
TV_PLAYER="${TV_PLAYER:-mpv --no-resume-playback --force-window=immediate}"

tv_file="$ROFI_DATA_DIR/channels.m3u"
tv_cache="$ROFI_CACHE_DIR/rofi-tv"
tv_preview=$SCRIPT_PATH'/download_tv_icon.sh "{input}" "{output}"'
tv_url="https://iptv-org.github.io/iptv/index.m3u"

rofi_flags=""

((ROFI_ICONS)) && rofi_flags="-show-icons"

if [ ! -f "$tv_file" ]; then
    printf "Downloading channel list...\n";

    wget -q --show-progress $tv_url -O "$tv_file" ||\
        print_error "Cannot download channel list"
fi

row=$(cat "$tv_cache")

# TODO: tvg-logo contains the url to the icon to show
while channel=$(\
    grep "#EXTINF" "$tv_file" | rev | cut -d"," -f1  | rev | awk '{print $0"<ICON>"$0}' |\
    sed -e "s/<ICON>/\\x00icon\\x1fthumbnail:\/\//g" |\
    $ROFI -dmenu -i $rofi_flags -preview-cmd "$tv_preview" -selected-row "${row}" -format 'i s' -p "Channel"); do

    channel_index=$(echo "$channel" | awk '{print $1;}')
    channel_name=$(echo "$channel" | cut -d' ' -f2-)
    channel_name=${channel_name//[/\\[}
    channel_name=${channel_name//]/\\]}

    channel_link=$(grep -A 1 "$channel_name" "$tv_file" | tail -1)

    echo "Playing " "$channel_link"
    echo "$channel_index" > "$tv_cache"

    $TV_PLAYER "$channel_link"

    exit 0
done

exit 1
