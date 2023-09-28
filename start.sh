#!/bin/bash
#
# rofi-desktop startup script

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

CONFIG_DIR="$SCRIPT_PATH/config"
STARTUP_FILE="$CONFIG_DIR/autostart"
FIRST_RUN_FILE="$CONFIG_DIR/first-run"

MONITORS_CACHE=${MONITORS_CACHE:-"$CONFIG_DIR/monitor-layout"}
WALLPAPER_CACHE=${WALLPAPER_CACHE:-"$CONFIG_DIR/wallpaper"}
KEYMAP_CACHE=${KEYMAP_CACHE:-"$CONFIG_DIR/keyboard-layout"}

WELCOME_MSG=${WELCOME_MSG:-"Welcome to rofi-desktop! &#x0a;Press any key to continue with the setup."}
RUN_APPMENU_PROMPT=${RUN_APPMENU_PROMPT:-"Run appmenu-service.py on startup?"}
RUN_KEYPRESS_PROMPT=${RUN_APPMENU_PROMPT:-"Run keypress.py on startup?"}

run_program() {
    is_running=$(ps aux | grep -c "$1")

    if [ "${is_running}" -lt 2 ]; then
        echo "running" "$1"
        "$1" & disown
    else
        echo "$1" "already running"
    fi
}

ask_user() {
    prompt="$1"

    choice=$(echo -e "Yes\nNo" | $ROFI_CMD -p "$prompt")

    if [ "$choice" = "Yes" ]; then
        echo "$choice"
    fi
}

wizard() {
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

    # ask programs to run on startup and add entries to autostart file
    truncate -s 0 "$STARTUP_FILE"

    if [ -n "$(ask_user "$RUN_APPMENU_PROMPT")" ] ; then
        echo "appmenu-service" >> "$STARTUP_FILE"
        run_program "$SCRIPT_PATH/scripts/appmenu-service.py"
    fi

    if [ -n "$(ask_user "$RUN_KEYPRESS_PROMPT")" ]; then
        echo "keypress" >> "$STARTUP_FILE"
        run_program "$SCRIPT_PATH/scripts/keypress.py"
    fi

    # TODO: run greenclip
    # TODO: run rofication-daemon
}

startup() {
    # set monitor layout
    if [ -f "$MONITORS_CACHE" ]; then
        connected_screens=$(xrandr | awk '( $2 == "connected" ){ print $1 }' | wc -l)

        if [ "$connected_screens" -gt 1 ]; then
            echo "Setting display layout"
            xrandr_cmd=$(cat "$MONITORS_CACHE")
            eval "$xrandr_cmd"
        fi
    fi

    # set wallpaper
    if [ -f "$WALLPAPER_CACHE" ]; then
        echo "Setting wallpaper"
        "$SCRIPT_PATH/scripts/set-wallpaper.sh" "$WALLPAPER_CACHE"
    fi

    # set keyboard layout
    if [ -f "$KEYMAP_CACHE" ]; then
        echo "Setting keyboard layout" "$(cat "$KEYMAP_CACHE")"
        setxkbmap "$(cat "$KEYMAP_CACHE")"
    fi

    # check entries in autostart file
    if [ -n "$(grep appmenu-service "$STARTUP_FILE")" ]; then
        run_program "$SCRIPT_PATH/scripts/appmenu-service.py"
    fi

    if [ -n "$(grep keypress "$STARTUP_FILE")" ]; then
        run_program "$SCRIPT_PATH/scripts/keypress.py"
    fi

    # TODO: run greenclip
    # TODO: run rofication-daemon
}

# export env vars
set -a
source "$SCRIPT_PATH/config/environment"
set +a

# show wizard if first run
if [ -f "$FIRST_RUN_FILE" ]; then
    startup
else
    wizard
    touch "$FIRST_RUN_FILE"
fi
