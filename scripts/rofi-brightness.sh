#!/usr/bin/env bash

# Original Author : Aditya Shakya (adi1090x)
#
# this script manages backlight brightness control for connected displays using xrandr (X11)
#
# dependencies: rofi, xrandr

ROFI="${ROFI:-rofi}"

current_bright() {
	xrandr --verbose | grep Brightness | cut -d':' -f2 | sed 's/ //'
}

current_bright_perc() {
	current_bright | awk '{print $1 * 100}'
}

increase_bright() {
	echo "$1" | awk '{print $1 + 0.1}'
}

decrease_bright() {
	echo "$1" | awk '{print $1 - 0.1}'
}

set_bright() {
	xrandr | awk '( $2 == "connected" ){ print $1 }' | xargs -I{} xrandr --output {} --brightness $1
}

options="Increase\nDecrease\nOptimal"

## Main
row=0

while chosen="$(echo -e "$options" | $ROFI -dmenu -i -p "Brightness $(current_bright_perc)%" -selected-row $row)"; do
	case $chosen in
		"Increase")
			set_bright $(increase_bright $(current_bright))
			row=0
		    ;;
		"Decrease")
		    set_bright $(decrease_bright $(current_bright))
			row=1
		    ;;
		"Optimal")
		    set_bright 0.75
			row=2
		    ;;
	esac
done

exit 1
