#!/usr/bin/env bash
#
# this script manages audio volume using pulseaudio interface (pactl)
#
# dependencies: rofi, pactl
# optional: pavucontrol

ROFI="${ROFI:-rofi}"
ROFI_ICONS="${ROFI_ICONS:-}"

rofi_flags=""

((ROFI_ICONS)) && rofi_flags="$rofi_flags -show-icons"

gen_menu() {
    is_muted=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{ print $NF }')

    echo -ne "Up\x00icon\x1faudio-volume-high\nDown\x00icon\x1faudio-volume-low"

    if [ "$is_muted" == "yes" ]; then
        echo -ne "\nUnmute\x00icon\x1faudio-volume-muted"
    else
        echo -ne "\nMute\x00icon\x1faudio-volume-muted"
    fi

    echo -ne "\nVolume Configuration\x00icon\x1fapplications-system"
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
        $ROFI -e "Install 'pavucontrol'"
    else
        pavucontrol
    fi
}

# remember last entry chosen
row=0

while action=$(gen_menu | $ROFI -dmenu -i $rofi_flags -format 'i s' -selected-row ${row} -p "Volume $(get_volume)"); do
    row=$(echo "$action" | awk '{print $1;}')
    action_text=$(echo "$action" | cut -d' ' -f2-)

    if [ -n "$action_text" ]; then
        ${commands[$action_text]};
    fi
done
