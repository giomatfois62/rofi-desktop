#!/bin/bash

if [ -z "$1" ]; then
    exit 1
fi

if [ -f "$2" ]; then
    exit 1
fi

flathub_url="https://flathub.org/api/v2/appstream"
appstream=$(curl "$flathub_url/$1")
icon_url=$(echo "$appstream" | jq -r '"\(.icon)"')

nice -n 19 /usr/bin/wget -t 5 --timeout=5 -q -O "$2" "$icon_url"
