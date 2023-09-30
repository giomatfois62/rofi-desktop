#!/usr/bin/env bash
#
# this script downloads and shows the list of flatpaks on flathub
# selecting an entry will launch a terminal with the command to install the flatpak
#
# dependencies: rofi, flatpak, jq

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
TERMINAL="${TERMINAL:-xterm}"
FLATHUB_CACHE="${FLATHUB_CACHE:-$HOME/.cache/flathub.json}"
FLATHUB_EXPIRATION_TIME=${FLATHUB_EXPIRATION_TIME:-3600} # refresh applications list every hour
FLATHUB_URL="https://flathub.org/api/v1/apps"

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

selected=$(jq '.[] | .name + " - " + .summary' "$FLATHUB_CACHE" | tr -d '"' | $ROFI_CMD -p "Flatpak")

if [ -n "$selected" ]; then
    # check flatpak cmd
    if ! command -v flatpak &> /dev/null; then
        rofi -e "Install flatpak first"
        exit 1
    fi

    app_name=$(echo "$selected" | awk '{print $1;}')
    app_id=$(jq ".[] | select(.name==\"$app_name\") | .flatpakAppId" "$FLATHUB_CACHE" | tr -d '"')

    $TERMINAL -e "flatpak install $app_id"

    exit 0;
fi

exit 1
