#!/bin/bash
#
# this script shows the weather forecast for a city using wttr.in curl interface
#
# dependencies: curl

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
FORECAST_DAYS="${FORECAST_DAYS:-2}" # 0 current weather, 1 today, 2 today & tomorrow, empty 3days
WEATHER_PLACEHOLDER="Type the name of a place and press \"Enter\" to show its weather forecast"

weather=$(curl -s wttr.in/"$city"?ATFn$FORECAST_DAYS)

while city=$($ROFI_CMD -mesg "$weather" -p "Place" -theme-str "entry{placeholder:\"$WEATHER_PLACEHOLDER\";} listview{enabled:false;}"); do
        weather=$(curl -s wttr.in/"$city"?ATFn$FORECAST_DAYS)
done
