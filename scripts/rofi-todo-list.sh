#!/bin/bash
#
# this script manages a folder of todo lists using the modi in rofi-todo.sh
#
# dependencies: rofi

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
ROFI_DATA_DIR="${ROFI_DATA_DIR:-$SCRIPT_PATH/data}"
TODO_LISTS_PLACEHOLDER="Type something with a \"+\" prefix to create a new TODO list"
TODO_PLACEHOLDER="Type something with a \"+\" prefix to create a new TODO item"
TODO_FOLDER="$ROFI_DATA_DIR/todo"

mkdir -p "$TODO_FOLDER"

while todo_file=$(cd "$TODO_FOLDER" && find * -type f -not -name "*_done" | xargs -I{} wc -l {} |\
        $ROFI_CMD -p "ToDo List" -theme-str "entry{placeholder:\"$TODO_LISTS_PLACEHOLDER\";"}); do

    if [[ "$todo_file" = "+"* ]]; then
        todo_file=$(echo "$todo_file" | sed s/^+//g | sed s/^\s+//g)
    else
        todo_file=$(echo "$todo_file" | cut -d' ' -f2-) # remove items count
    fi

    done_file="$todo_file""_done"

    TODO_FILE="$TODO_FOLDER/$todo_file" \
    DONE_FILE="$TODO_FOLDER/$done_file" \
    rofi -kb-screenshot Control+Shift+space -modi "ToDo $todo_file:$SCRIPT_PATH/rofi-todo.sh" -show "ToDo $todo_file" -theme-str "entry{placeholder:\"$TODO_PLACEHOLDER\";}"
done
