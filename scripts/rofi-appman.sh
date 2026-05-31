#!/bin/bash
#
# this script download and show the list of appimages from https://portable-linux-apps.github.io
# selecting an entry will launch a terminal with the command to install the appimage
#
# dependencies: rofi, curl, jq

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"
ROFI_ICONS="${ROFI_ICONS:-}"
TERMINAL="${TERMINAL:-xterm}"

apps_refresh=3600 # refresh apps file every hour
appman_url="https://raw.githubusercontent.com/ivan-hc/AM/main/APP-MANAGER"
apps_url="https://portable-linux-apps.github.io/apps.json"
apps_file="$ROFI_CACHE_DIR/portable-apps.json"
apps_preview="$SCRIPT_PATH/download_icon.sh {input} {output} {size}"

rofi_flags=""

((ROFI_ICONS)) && rofi_flags="-show-icons"

download_appman() {
    wget -q "$appman_url" -O "$SCRIPT_PATH/appman" && chmod a+x "$SCRIPT_PATH/appman"
}

if [ -f "$apps_file" ]; then
    # compute time delta between current date and news file date
	file_date=$(date -r "$apps_file" +%s)
	current_date=$(date +%s)

	delta=$((current_date - file_date))

	# refresh apps file if it's too old
	if [ $delta -gt $apps_refresh ]; then
		curl -fsS "$apps_url" -o "$apps_file"
	fi
else
	curl -fsS "$apps_url" -o "$apps_file"
fi

# Build rofi rows straight from the JSON feed, one per app:
#   <b>name</b> - description<ICON>iconurl
# Keeping fields together in jq removes the old line-by-line paste alignment.
# splayer is excluded to match the previous behavior.
lines=$(jq -r '.[] | select(.packageName != "splayer")
    | "<b>\(.packageName)</b> - \(.description)<ICON>\(.icon)"' "$apps_file")

while match=$(echo -en "$lines" |\
    sed -e "s/<ICON>/\\x00icon\\x1fthumbnail:\/\//g" |\
    $ROFI $rofi_flags -markup-rows -preview-cmd "$apps_preview" -dmenu -i -p "Applications"); do

    app=$(echo "$match" | cut -d' ' -f1 | sed -e 's/<[^>]*>//g')

    choice=$(echo -e "Yes\nNo" |\
    $ROFI -p "Install $app?" -dmenu -i -a 0 -u 1)

    if [ "$choice" == "Yes" ]; then
        [[ ! -f "$SCRIPT_PATH/appman" ]] && download_appman
        $TERMINAL -e "cd \"${SCRIPT_PATH}\" && ./appman -i $app; read -n1"
        exit 0
    fi
done

exit 1
