#!/bin/bash

if [ -z "$1" ]; then
    exit 1
fi

if [ -f "$2" ]; then
    exit 1
fi

nice -n 19 /usr/bin/wget -t 3 --timeout=3 -q -O "$2" "$1"
