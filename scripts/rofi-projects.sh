#!/usr/bin/env bash
#
# this script shows code projects in a directory and opens them with the editor of choice
#
# dependencies: rofi

ROFI="${ROFI:-rofi}"
PROJECTS_EDITOR="${PROJECTS_EDITOR:-qtcreator}"
PROJECTS_DIR="${PROJECTS_DIR:-"$HOME"/Projects}"

if ! command -v $PROJECTS_EDITOR &> /dev/null; then
    $ROFI -e "Projects Editor $PROJECTS_EDITOR not found"
    exit 1
fi

project=$(ls "$PROJECTS_DIR" | $ROFI -dmenu -i -p "Project")

if [ -n "$project" ]; then
    $PROJECTS_EDITOR "$PROJECTS_DIR/$project" & disown
    exit 0
fi

exit 1
