#!/usr/bin/env bash

URL="https://flathub.org/api/v1/apps"
ROFI_CMD="rofi -dmenu -i"
TERMINAL="xterm"
CACHE_FILE="$HOME/.cache/flathub.json"
EXPIRATION_TIME=3600 # refresh applications list every hour

# TODO: do this job in background and display message
if [ -f "$CACHE_FILE" ]; then
    # compute time delta between current date and news file date
    filedate=$(date -r "$CACHE_FILE" +%s)
    currentdate=$(date +%s)
    delta=$((currentdate - filedate))

    # refresh news file if it's too old
    if [ $delta -gt $EXPIRATION_TIME ]; then
	curl --silent "$URL" -o "$CACHE_FILE"
    fi
else
    curl --silent "$URL" -o "$CACHE_FILE"
fi

selected=$(jq '.[] | .name + " - " + .summary' "$CACHE_FILE" | tr -d '"' | $ROFI_CMD -p "Flatpak")

if [ ${#selected} -gt 0 ]; then
    appname=$(echo "$selected" | awk '{print $1;}')
    appid=$(jq ".[] | select(.name==\"$appname\") | .flatpakAppId" "$CACHE_FILE" | tr -d '"')
    $TERMINAL -e "flatpak install $appid"
    exit 0;
fi

exit 1
