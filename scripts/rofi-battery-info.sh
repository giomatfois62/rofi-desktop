#!/bin/bash
#
# script to pipe battery info into a rofi menu
#

ROFI="${ROFI:-rofi}"

info=$(upower -i /org/freedesktop/UPower/devices/DisplayDevice)

$ROFI -e "$info"
