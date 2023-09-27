#!/bin/bash
#
# rofi-desktop startup script
#

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

CONFIG_DIR="$SCRIPT_PATH/config"
STARTUP_FILE="$SCRIPT_PATH/autostart"

# export env vars
set -a
source "$CONFIG_DIR/environment"
set +a

run_program() {
    is_running=$(ps aux | grep -c "$1")

    if [ "${is_running}" -lt 2 ]; then
        echo "running" "$1"
        "$1" & disown
    else
        echo "$1" "already running"
    fi
}

wizard() {
    WELCOME_MSG=${WELCOME_MSG:-"Welcome to rofi-desktop! &#x0a;Press any key to continue with the setup."}

    rofi -markup -e "$WELCOME_MSG"

    # TODO: set menu language
    "$SCRIPT_PATH"/scripts/rofi-locale.sh
    "$SCRIPT_PATH"/scripts/rofi-keyboard-layout.sh
    "$SCRIPT_PATH"/scripts/rofi-clocks.sh
    "$SCRIPT_PATH"/scripts/rofi-mime.sh;

    # show monitor layout menu only if more than one screen is connected
    connected_screens=$(xrandr | awk '( $2 == "connected" ){ print $1 }' | wc -l)

    if [ "$connected_screens" -gt 1 ]; then
        "$SCRIPT_PATH"/scripts/rofi-monitor-layout.sh
    fi

    "$SCRIPT_PATH"/scripts/rofi-wallpaper.sh;

    # TODO: ask programs to run on startup
    run_program "$SCRIPT_PATH/scripts/appmenu-service.py"
    run_program "$SCRIPT_PATH/scripts/keypress.py"

    # TODO: run greenclip
    # TODO: run rofication-daemon
}
startup() {

    # set monitor layout
    MONITORS_CACHE=${MONITORS_CACHE:-"$CONFIG_DIR/monitor-layout"}

    if [ -f "$MONITORS_CACHE" ]; then
        connected_screens=$(xrandr | awk '( $2 == "connected" ){ print $1 }' | wc -l)

        if [ "$connected_screens" -gt 1 ]; then
            echo "Setting display layout"
            xrandr_cmd=$(cat "$MONITORS_CACHE")
            eval "$xrandr_cmd"
        fi
    fi

    # set wallpaper
    WALLPAPER_CACHE=${WALLPAPER_CACHE:-"$CONFIG_DIR/wallpaper"}

    if [ -f "$WALLPAPER_CACHE" ]; then
        echo "Setting wallpaper"
        "$SCRIPT_PATH/scripts/set-wallpaper.sh" "$WALLPAPER_CACHE"
    fi

    # set keyboard layout
    KEYMAP_CACHE=${KEYMAP_CACHE:-"$CONFIG_DIR/keyboard-layout"}

    if [ -f "$KEYMAP_CACHE" ]; then
        echo "Setting keyboard layout" "$(cat "$KEYMAP_CACHE")"
        setxkbmap "$(cat "$KEYMAP_CACHE")"
    fi

    run_program "$SCRIPT_PATH/scripts/appmenu-service.py"
    run_program "$SCRIPT_PATH/scripts/keypress.py"

    # TODO: run greenclip
    # TODO: run rofication-daemon
}

# TODO: launch wizard and create first run file
startup
