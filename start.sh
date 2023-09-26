#!/bin/bash
#
# rofi-desktop startup script
#

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

# export env vars
source "$SCRIPT_PATH/config/config.env"

wizard() {
    connected_screens=$(xrandr | awk '( $2 == "connected" ){ print $1 }' | wc -l)

    if [ "$connected_screens" -gt 1 ]; then
        "$SCRIPT_PATH"/rofi-monitor-layout.sh
    fi

    "$SCRIPT_PATH"/rofi-keyboard-layout.sh
    "$SCRIPT_PATH"/rofi-locale.sh
    "$SCRIPT_PATH"/rofi-clocks.sh
    "$SCRIPT_PATH"/rofi-wallpaper.sh;
}

# set monitor layout
startup() {
    MONITORS_CACHE=${MONITORS_CACHE:-"$HOME/.cache/monitor-layout"}

    if [ -f "$MONITORS_CACHE" ]; then
        connected_screens=$(xrandr | awk '( $2 == "connected" ){ print $1 }' | wc -l)

        if [ "$connected_screens" -gt 1 ]; then
            echo "Setting display layout"
            $(cat "$MONITORS_CACHE")
        fi
    fi

    # set wallpaper
    WALLPAPER_CACHE=${WALLPAPER_CACHE:-"$HOME/.cache/wallpaper"}

    if [ -f "$WALLPAPER_CACHE" ]; then
        echo "Setting wallpaper"
        "$SCRIPT_PATH/scripts/set-wallpaper.sh" "$WALLPAPER_CACHE"
    fi

    # set keyboard layout
    KEYMAP_CACHE=${KEYMAP_CACHE:-"$HOME/.cache/keyboard-layout"}

    if [ -f "$KEYMAP_CACHE" ]; then
        echo "Setting keyboard layout" "$(cat "$KEYMAP_CACHE")"
        setxkbmap "$(cat "$KEYMAP_CACHE")"
    fi

    run_program() {
        is_running=$(ps aux | grep "$1" | wc -l)

        if [ ${is_running} -lt 2 ]; then
            echo "running" "$1"
            "$1" & disown
        else
            echo "$1" "already running"
        fi
    }

    run_program "$SCRIPT_PATH/scripts/appmenu-service.py"
    run_program "$SCRIPT_PATH/scripts/keypress.py"

    # TODO: run greenclip
    # TODO: run rofication-daemon
}

startup
