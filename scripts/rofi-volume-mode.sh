#!/usr/bin/env bash
#
# this rofi script manages audio volume using pulseaudio interface (pactl)
# usage: rofi -modi "volume:/path/to/rofi-volume-mode.sh" -show volume -show-icons
#
# dependencies: pactl

VOLUME_SETTINGS=${VOLUME_SETTINGS:-"kcmshell6 kcm_pulseaudio"}

volume_level()    { pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}'; }
volume_up()       { pactl set-sink-volume @DEFAULT_SINK@ +10%; }
volume_down()     { pactl set-sink-volume @DEFAULT_SINK@ -10%; }
volume_toggle()   { pactl set-sink-mute @DEFAULT_SINK@ toggle; }
volume_muted()    { pactl get-sink-mute @DEFAULT_SINK@; }
volume_settings() { coproc ($VOLUME_SETTINGS > /dev/null  2>&1) }

if [ "$@" ]; then
    case "$@" in
        Up) volume_up ;;
        Down) volume_down ;;
        Mute|Unmute) volume_toggle ;;
        Settings) volume_settings ;&
        *) exit 0 ;;
    esac
fi

echo -e "\0prompt\x1fVolume $(volume_level)"
echo -e "\0keep-selection\x1ftrue"

echo -e "Up\x00icon\x1faudio-volume-high"
echo -e "Down\x00icon\x1faudio-volume-low"

[[ $(volume_muted) = *yes ]] &&
    echo -e "Unmute\x00icon\x1faudio-volume-muted" ||
    echo -e "Mute\x00icon\x1faudio-volume-muted"

echo -e "Settings\x00icon\x1fapplications-system"
