#!/usr/bin/env bash
#
# this script shows code project in a directory and opens them with the editor of choice
#
# dependencies: rofi

ROFI="${ROFI:-rofi}"
PROJECTS_EDITOR="${PROJECTS_EDITOR:-"$HOME"/Programs/qtcreator/bin/qtcreator}"
PROJECTS_DIR="${PROJECTS_DIR:-"$HOME"/Projects}"

if ! command -v $PROJECTS_EDITOR &> /dev/null; then
    $ROFI -e "Projects Editor $PROJECTS_EDITOR not found"
    exit 1
fi

choice=$(ls "$PROJECTS_DIR" | $ROFI -dmenu -i -p "Project")

if [ -n "$choice" ]; then
    $PROJECTS_EDITOR "$PROJECTS_DIR/$choice" & disown
    exit 0
fi

exit 1
