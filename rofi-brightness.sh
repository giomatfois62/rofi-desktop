#!/usr/bin/env bash

# Original Author : Aditya Shakya (adi1090x)

ROFI_CMD="rofi -dmenu -i"

## Get Brightness
CURRENT="$(xbacklight -get)"
BLIGHT="$(printf "%.0f\n" "$CURRENT")"

options="Increase\nDecrease\nOptimal"

## Main
selected_row=0

while chosen="$(echo -e "$options" | $ROFI_CMD -p "Brightness $BLIGHT%" -selected-row $selected_row)"; do
	case $chosen in
		"Increase")
		    xbacklight -inc 10
			selected_row=0
		    ;;
		"Decrease")
		    xbacklight -dec 10
			selected_row=1
		    ;;
		"Optimal")
		    xbacklight -set 35
			selected_row=2
		    ;;
	esac
done

exit 1
