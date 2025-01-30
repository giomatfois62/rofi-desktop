#!/usr/bin/env bash
#
# https://github.com/mrHeavenli/rofi-playerctl
#
# this script controls the current media playing using playerctl
#
# dependencies: rofi, playerctl

# TODO: fix player change

ROFI="${ROFI:-rofi}"
ROFI_ICONS="${ROFI_ICONS:-}"

rofi_flags=""

[ -n "$ROFI_ICONS" ] && rofi_flags="-show-icons"

if ! command -v playerctl &> /dev/null; then
	$ROFI -e "Install playerctl to enable the media player controls menu"
	exit 1
fi

status_function () {
	if playerctl status > /dev/null; then
        player_name=$(playerctl status -f "{{playerName}}")
        player_metadata=$(playerctl metadata -f "{{trunc(default(title, \"[Unknown]\"), 25)}} by {{trunc(default(artist, \"[Unknown]\"), 25)}}")
        player_status=$(playerctl status)

        echo "$player_name: $player_metadata ($player_status)"
    else
        echo "Nothing is playing"
    fi
}


# Options
toggle="Play/Pause" # media-playback-start
next="Next" # media-skip-forward
prev="Previous" # media-skip-backward
seekminus="Go back 15 seconds" # media-seek-backward
seekplus="Go ahead 15 seconds" # media-seek-forward
switch="Change selected player" # multimedia-player

# Variable passed to rofi
print_options() {
    echo -e "$toggle\x00icon\x1fmedia-playback-start"
    echo -e "$next\x00icon\x1fmedia-skip-forward"
    echo -e "$prev\x00icon\x1fmedia-skip-backward"
    echo -e "$seekplus\x00icon\x1fmedia-seek-forward"
    echo -e "$seekminus\x00icon\x1fmedia-seek-backward"
    echo -e "$switch\x00icon\x1fmultimedia-player"
}

row=0
status=$(status_function)

while chosen="$(print_options | $ROFI -dmenu -i -p "Media Player" $rofi_flags -markup-rows -mesg "${status^}" -selected-row ${row} -format 'i s')"; do
    row=$(echo "$chosen" | awk '{print $1;}')
    selected_text=$(echo "$chosen" | cut -d' ' -f2-)

    case "$selected_text" in
        "$toggle")
            playerctl play-pause
            ;;
        "$next")
            playerctl next
            ;;
        "$prev")
            playerctl previous
            ;;
        "$seekminus")
            playerctl position 15-
            ;;
        "$seekplus")
            playerctl position 15+
            ;;
        "$switch")
            playerctld shift
            ;;
    esac

    status=$(status_function)
done

exit 1
