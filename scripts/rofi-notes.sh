#!/bin/bash
#
# https://github.com/christianholman/rofi_notes
#
# this script allows writing and reading simple notes that are stored locally
#
# dependencies: rofi

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
NOTES_AUTHOR="${NOTES_AUTOR:-$(whoami)}"
NOTES_FOLDER="${NOTES_FOLDER:-$SCRIPT_PATH/../data/notes}"
NOTES_EDITOR="${NOTES_EDITOR:-xdg-open}"

if [[ ! -d "${NOTES_FOLDER}" ]]; then
    mkdir -p "$NOTES_FOLDER"
fi

get_notes() {
    ls "${NOTES_FOLDER}"
}

edit_note() {
    note_location=$1
    $NOTES_EDITOR "$note_location"
}

delete_note() {
    local note=$1
    local action=$(echo -e "Yes\nNo" | rofi -dmenu -p "Are you sure you want to delete $note? ")

    case $action in
        "Yes")
            rm "$NOTES_FOLDER/$note"
            main
            ;;
        "No")
            main
    esac
}

note_context() {
    local note=$1
    local note_location="$NOTES_FOLDER/$note"
    local action=$(echo -e "Edit\nDelete" | rofi -dmenu -p "$note > ")
    case $action in
        "Edit")
            edit_note "$note_location"
            exit 0;;
        "Delete")
            delete_note "$note"
			exit 0;;
    esac

	exit 1
}

new_note() {
    local title=$(echo -e "Cancel" | rofi -dmenu -p "Input title: ")

    case "$title" in
        "Cancel")
            main
            ;;
        *)
            local file=$(echo "$title" | sed 's/ /_/g;s/\(.*\)/\L\1/g')
            local template=$(cat <<- END
---
title: $title
date: $(date --rfc-3339=seconds)
author: $NOTES_AUTHOR
---

# $title
END
            )

            note_location="$NOTES_FOLDER/$file.md"
            if [ "$title" != "" ]; then
                echo "$template" > "$note_location" | edit_note "$note_location"
                exit 0
            fi
            ;;
    esac
}

main()
{
    local all_notes="$(get_notes)"
    local first_menu="New Note"

    if [ "$all_notes" ];then
        first_menu="New Note\n${all_notes}"
    fi

    local note=$(echo -e "$first_menu"  | $ROFI_CMD -p "Note: ")

    case $note in
        "New Note")
            new_note
            ;;
        "")
            exit 1;;
        *)
            note_context "$note" && exit 0 # handle esc key in note_context
    esac
	
	exit 1
}


main
