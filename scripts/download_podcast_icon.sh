#!/bin/bash

LINK="https://img.rss.com/$1"
LINK=$(echo "$LINK" | sed -e "s/<SIZE>/$3/g")

if [ -z "$LINK" ]; then
    exit 1
fi

nice -n 19 /usr/bin/wget -q -O "$2" "$LINK"
