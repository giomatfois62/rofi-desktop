#!/usr/bin/env bash
#
# this script allows taking screenshots of the desktop
#
# dependencies: rofi
# optional: scrot, flameshot, spectacle, xfce4-screenshooter

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
SCREENSHOT_NAME="${SCREENSHOT_NAME:-Screenshot_%Y-%m-%d-%S-%H%M%S.png}"

# check for available programs
declare -a programs=("flameshot" "spectacle" "xfce4-screenshooter")

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

# fallback on scrot
if ! command -v scrot &> /dev/null
then
    rofi -e "Install a screenshot program."
    exit 1
fi

options="Screen\nDArea\nWindow"

chosen="$(echo -e $options | $ROFI_CMD -p 'Screenshot')"

case $chosen in
    "Screen")
        sleep 1; scrot $SCREENSHOT_NAME -e 'mv $f $$(xdg-user-dir PICTURES) ; xdg-open $$(xdg-user-dir PICTURES)/$f'
        exit 0;;
    "Area")
        scrot -s $SCREENSHOT_NAME -e 'mv $f $$(xdg-user-dir PICTURES) ; xdg-open $$(xdg-user-dir PICTURES)/$f'
        exit 0;;
    "Window")
        scrot -s $SCREENSHOT_NAME -e 'mv $f $$(xdg-user-dir PICTURES) ; xdg-open $$(xdg-user-dir PICTURES)/$f'
        exit 0;;
esac

exit 1
