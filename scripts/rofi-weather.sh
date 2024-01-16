#!/bin/bash
#
# this script display the weather forecast for a city using wttr.in curl interface
#
# dependencies: curl

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
WEATHER_PLACEHOLDER="${WEATHER_PLACEHOLDER:-Type the name of a city and press \"Enter\" to show its weather forecast}"

while city=$(curl -s wttr.in/"$city"?ATFn | $ROFI_CMD -p "Weather" -theme-str "entry{placeholder:\"$WEATHER_PLACEHOLDER\";"}); do
        echo "Showing weather for" "$city"
done
