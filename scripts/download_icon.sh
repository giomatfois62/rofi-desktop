#!/bin/bash

if [ -z "$1" ]; then
    exit 1
fi

if [ -f "$2" ]; then
    exit 1
fi

nice -n 19 /usr/bin/curl --silent --max-time 5 -o "$2" "$1"
