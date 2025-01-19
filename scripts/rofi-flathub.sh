#!/usr/bin/env bash
#
# this script downloads and shows the list of flatpaks on flathub
# selecting an entry will launch a terminal with the command to install the flatpak
#
# dependencies: rofi, flatpak, jq

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"
TERMINAL="${TERMINAL:-xterm}"
FLATHUB_CACHE="$ROFI_CACHE_DIR/flathub.json"
FLATHUB_EXPIRATION_TIME=${FLATHUB_EXPIRATION_TIME:-3600} # refresh applications list every hour
FLATHUB_URL="https://flathub.org/api/v1/apps"
FLATHUB_ICONS=${FLATHUB_ICONS:-}
PREVIEW_CMD="$SCRIPT_PATH/download_icon.sh {input} {output} {size}"

# TODO: do this job in background and display message
if [ -f "$FLATHUB_CACHE" ]; then
    # compute time delta between current date and news file date
    file_date=$(date -r "$FLATHUB_CACHE" +%s)
    current_date=$(date +%s)

    delta=$((current_date - file_date))

    # refresh news file if it's too old
    if [ $delta -gt $FLATHUB_EXPIRATION_TIME ]; then
        curl --silent "$FLATHUB_URL" -o "$FLATHUB_CACHE"
    fi
else
    curl --silent "$FLATHUB_URL" -o "$FLATHUB_CACHE"
fi

if [ -n "$FLATHUB_ICONS" ]; then
    #flags="-show-icons -theme-str $(build_theme $GRID_ROWS $GRID_COLS $ICON_SIZE)"
    flags="-show-icons"
fi

selected=$(jq '.[] | .name + " - " + .summary+"<ICON>"+.iconDesktopUrl' "$FLATHUB_CACHE" |\
    sed -e "s/<ICON>/\\x00icon\\x1fthumbnail:\/\//g" |\
    tr -d '"' |\
    $ROFI -dmenu -i $flags -preview-cmd "$PREVIEW_CMD" -p "Flatpak")

if [ -n "$selected" ]; then
    # check flatpak cmd
    if ! command -v flatpak &> /dev/null; then
        $ROFI -e "Install flatpak"
        exit 1
    fi

    app_name=$(echo "$selected" | awk '{print $1;}')
    app_id=$(jq ".[] | select(.name==\"$app_name\") | .flatpakAppId" "$FLATHUB_CACHE" | tr -d '"')

    $TERMINAL -e "flatpak install $app_id"

    exit 0;
fi

exit 1
