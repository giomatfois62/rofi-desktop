#!/usr/bin/env bash
#
# this script manages audio volume using pulseaudio interface (pactl)
#
# dependencies: rofi, pactl
# optional: pavucontrol

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"

gen_menu() {
    is_muted=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{ print $NF }')

    echo -ne "Up\nDown"

    if [ "$is_muted" == "yes" ]; then
        echo -ne "\nUnmute"
    else
        echo -ne "\nMute"
    fi

    echo -ne "\nVolume Configuration"
}

declare -A commands=(
    ["Up"]=vol_up
    ["Down"]=vol_down
    ["Mute"]=vol_mute
    ["Unmute"]=vol_mute
    ["Volume Configuration"]=vol_config
)

get_volume() { pactl get-sink-volume @DEFAULT_SINK@ | awk '{ print $5 }'; }
vol_up() { pactl set-sink-volume @DEFAULT_SINK@ +10%; }
vol_down() { pactl set-sink-volume @DEFAULT_SINK@ -10%; }
vol_mute() { pactl set-sink-mute @DEFAULT_SINK@ toggle; }

vol_config() {
    if ! command -v pavucontrol &> /dev/null; then
        rofi -e "Install 'pavucontrol'"
    else
        pavucontrol
    fi
}

while choice=$(gen_menu | $ROFI_CMD -p "Volume $(get_volume)"); do
    if [ ${#choice} -gt 0 ]; then
        ${commands[$choice]};
    fi
done
