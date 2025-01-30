#!/usr/bin/env bash
#
# this script downloads and shows the list of flatpaks on flathub
# selecting an entry will launch a terminal with the command to install the flatpak
#
# dependencies: rofi, flatpak, jq

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"
ROFI_ICONS=${ROFI_ICONS:-}
TERMINAL="${TERMINAL:-xterm}"

flathub_refresh=3600 # refresh applications list every hour
flathub_url="https://flathub.org/api/v2/appstream"
flathub_cache="$ROFI_CACHE_DIR/flathub.json"
flathub_preview="$SCRIPT_PATH/download_flathub_icon.sh {input} {output} {size}"
rofi_flags=""

[ -n "$ROFI_ICONS" ] && rofi_flags="-show-icons"

# TODO: do this job in background and display message
if [ -f "$flathub_cache" ]; then
    # compute time delta between current date and news file date
    file_date=$(date -r "$flathub_cache" +%s)
    current_date=$(date +%s)

    delta=$((current_date - file_date))

    # refresh news file if it's too old
    if [ $delta -gt $flathub_refresh ]; then
        curl --silent "$flathub_url" -o "$flathub_cache"
    fi
else
    curl --silent "$flathub_url" -o "$flathub_cache"
fi

row=0

while selected=$(jq -r '.[]' "$flathub_cache" | awk '{print $1"<ICON>"$1}' |\
    sed -e "s/<ICON>/\\x00icon\\x1fthumbnail:\/\//g" |\
    $ROFI -dmenu -i $rofi_flags -format 'i s' -selected-row "$row" -preview-cmd "$flathub_preview" -p "Flatpak"); do
    
    row=$(echo "$selected" | cut -d' ' -f1)
    app_id=$(echo "$selected" | cut -d' ' -f2)

    if [ -n "$app_id" ]; then
        appstream=$(curl --silent "$flathub_url/$app_id")

        actions="Install\nOpen page in flathub.org"
        mesg=$(echo "$appstream" | jq -r '"\(.summary)"')
        action=$(echo -e "$actions" | $ROFI -dmenu -i -p "$app_id" -mesg "$mesg")

        if [ "$action" = "Install" ]; then
            # check flatpak cmd
            if ! command -v flatpak &> /dev/null; then
                $ROFI -e "Install flatpak"
                exit 1
            fi

            $TERMINAL -e "flatpak install $app_id" && exit 0

        elif [ "$action" = "Open page in flathub.org" ]; then
            app_url="https://flathub.org/apps/$app_id"
            xdg-open "$app_url" && exit 0
        fi
    fi
done

exit 1
