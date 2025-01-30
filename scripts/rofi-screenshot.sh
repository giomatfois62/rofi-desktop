#!/usr/bin/env bash
#
# this script allows taking screenshots of the desktop
#
# dependencies: rofi, scrot/grim, slurp/flameshot/spectacle/xfce4-screenshooter

ROFI="${ROFI:-rofi}"
SCREENSHOT_NAME="${SCREENSHOT_NAME:-Screenshot_%Y-%m-%d-%S-%H%M%S.png}"

# check for available programs working in both wayland and x11
declare -a programs=("flameshot" "spectacle")

# launch program if found on system
for cmd in "${programs[@]}"; do
    if command -v "$cmd" &> /dev/null; then
        if [ "$cmd" = "flameshot" ]; then
            flameshot launcher
        else
            $cmd
        fi

        exit 0
    fi
done

if [ -n "$WAYLAND_DISPLAY" ]; then
    # fallback on grim
    if ! command -v grim &> /dev/null; then
        $ROFI -e "Install grim or a screenshot program for wayland."
        exit 1
    fi

    screen_cmd() {
        sleep 1 ; grim "$(xdg-user-dir PICTURES)/$SCREENSHOT_NAME" ; xdg-open "$(xdg-user-dir PICTURES)/$SCREENSHOT_NAME"
    }

    area_cmd() {
        grim -g "$(slurp)" "$(xdg-user-dir PICTURES)/$SCREENSHOT_NAME" ; xdg-open "$(xdg-user-dir PICTURES)/$SCREENSHOT_NAME"
    }

    window_cmd() {
        grim -g "$(slurp)" "$(xdg-user-dir PICTURES)/$SCREENSHOT_NAME" ; xdg-open "$(xdg-user-dir PICTURES)/$SCREENSHOT_NAME"
    }
elif [ -n "$DISPLAY" ]; then
    # try xfce4-screenshoter
    if command -v "xfce4-screenshooter" &> /dev/null; then
        xfce4-screenshooter
        exit 0
    fi

    # fallback on scrot
    if ! command -v scrot &> /dev/null; then
        $ROFI -e "Install scrot or a screenshot program for X11."
        exit 1
    fi

    screen_cmd() {
        sleep 1 ; scrot "$SCREENSHOT_NAME" -e 'mv $f $$(xdg-user-dir PICTURES) ; xdg-open $$(xdg-user-dir PICTURES)/$f'
    }

    area_cmd() {
        scrot -s "$SCREENSHOT_NAME" -e 'mv $f $$(xdg-user-dir PICTURES) ; xdg-open $$(xdg-user-dir PICTURES)/$f'
    }

    window_cmd() {
        scrot -s "$SCREENSHOT_NAME" -e 'mv $f $$(xdg-user-dir PICTURES) ; xdg-open $$(xdg-user-dir PICTURES)/$f'
    }
else
    echo "Error: No Wayland or X11 display detected" >&2
    exit 1
fi

options="Screen\nArea\nWindow"

chosen="$(echo -e $options | $ROFI -dmenu -i -p 'Screenshot')"

case $chosen in
    "Screen")
        screen_cmd
        exit 0;;
    "Area")
        area_cmd
        exit 0;;
    "Window")
        window_cmd
        exit 0;;
esac

exit 1
