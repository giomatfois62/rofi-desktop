#!/usr/bin/env bash
#
# this script shows code project in a directory and opens them with the editor of choice
#
# dependencies: rofi

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
PROJECTS_EDITOR="${PROJECTS_EDITOR:-"$HOME"/Programs/qtcreator/bin/qtcreator}"
PROJECTS_DIRECTORY="${PROJECTS_DIRECTORY:-"$HOME"/Projects}"

if ! command -v $PROJECTS_EDITOR &> /dev/null; then
    rofi -e "Projects Editor $PROJECTS_EDITOR not found"
    exit 1
fi

choice=$(ls "$PROJECTS_DIRECTORY" | $ROFI_CMD -p "Project")

if [ -n "$choice" ]; then
    $PROJECTS_EDITOR "$PROJECTS_DIRECTORY/$choice" & disown
    exit 0
fi

exit 1
