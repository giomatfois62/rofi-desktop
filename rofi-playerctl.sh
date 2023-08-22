#!/usr/bin/env bash
#
# https://github.com/mrHeavenli/rofi-playerctl
#
# this script controls the current media playing using playerctl
#
# dependencies: rofi, playerctl

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"

status_function () {
	if playerctl status > /dev/null; then
			echo "$(playerctl status -f "{{playerName}}"): $(playerctl metadata -f "{{trunc(default(title, \"[Unknown]\"), 25)}} by {{trunc(default(artist, \"[Unknown]\"), 25)}}") ($(playerctl status))"
	else
		echo "Nothing is playing"
	fi
}
status=$(status_function)

# Options
toggle="⏯️ Play/Pause"
next="⏭️ Next"
prev="⏮ Previous"
seekminus="⏪ Go back 15 seconds"
seekplus="⏩ Go ahead 15 seconds"
switch="🔄 Change selected player"

# Variable passed to rofi
options="$toggle\n$next\n$prev\n$seekplus\n$seekminus\n$switch"

# remember last entry chosen
selected_row=0

# TODO: fix player change
while chosen="$(echo -e "$options" | $ROFI_CMD -show -p "${status^}" -selected-row ${selected_row} -format 'i s')"; do
    selected_row=$(echo "$chosen" | awk '{print $1;}')
    selected_text=$(echo "$chosen" | cut -d' ' -f2-)

    case $selected_text in
        $toggle)
            playerctl play-pause
            ;;
        $next)
            playerctl next
            ;;
        $prev)
            playerctl previous
            ;;
        $seekminus)
            playerctl position 15-
            ;;
        $seekplus)
            playerctl position 15+
            ;;
        $switch)
            playerctld shift
            ;;
    esac
done

exit 1
