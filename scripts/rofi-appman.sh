#!/bin/bash
#
# this script download and show the list of appimages from https://portable-linux-apps.github.io
# selecting an entry will launch a terminal with the command to install the appimage
#
# dependencies: rofi, curl, xmllint

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"
ROFI_ICONS="${ROFI_ICONS:-}"
TERMINAL="${TERMINAL:-xterm}"

apps_refresh=3600 # refresh apps file every hour
appman_url="https://raw.githubusercontent.com/ivan-hc/AM/main/APP-MANAGER"
apps_url="https://portable-linux-apps.github.io/apps"
apps_file="$ROFI_CACHE_DIR/portable-apps"
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
		curl --insecure -s "$apps_url" -o "$apps_file"
	fi
else
	curl --insecure -s "$apps_url" -o "$apps_file"
fi

all_apps=$(cat "$apps_file")

app_names=$(echo "$all_apps" | xmllint --html --xpath '//tr/td/a/em/strong/text()' - |\
    sed '/^splayer/d' |\
    sed 's/^/<b>/' |\
    sed 's/$/<\/b>/')
app_descs=$(echo "$all_apps" | xmllint --html --xpath '//tr/td/em[1]/text()[1]' -)
app_icons=$(echo "$all_apps" | xmllint --html --xpath '//tr/td/img/@src' - |\
    sed '/icons\/splayer/d' |\
    sed -e 's/^[^"]*"//' -e 's/"$//' |\
    sed 's/^/https:\/\/portable-linux-apps.github.io\//g')
app_descs=$(paste -d'|' <(echo "$app_descs" | awk '{$1=$1;print}') <(echo "$app_icons" | awk '{$1=$1;print}'))
app_descs=$(echo "$app_descs" | sed 's/|/<ICON>/g')

lines=$(paste -d'|' <(echo "$app_names") <(echo "$app_descs") | sed 's/|/ - /g')

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
