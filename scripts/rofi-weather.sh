#!/bin/bash
#
# this script shows the weather forecast for a city using wttr.in curl interface
#
# dependencies: curl

ROFI="${ROFI:-rofi}"
FORECAST_DAYS="${FORECAST_DAYS:-2}" # 0 current weather, 1 today, 2 today & tomorrow, empty 3days

weather_help="Type the name of a place and press <b>Enter</b> to show its weather forecast"

weather=$(curl -s wttr.in/"$city"?ATFn$FORECAST_DAYS)

while city=$($ROFI -dmenu -i -mesg "$weather_help&#x0a;$weather" -p "Place" -theme-str "listview{enabled:false;}"); do
        city=$(echo $city | tr " " "+")
        weather=$(curl -s wttr.in/"$city"?ATFn$FORECAST_DAYS)
done
