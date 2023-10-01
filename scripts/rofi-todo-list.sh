#!/bin/bash
#
# this script manages a folder of todo lists using the modi in rofi-todo.sh
#
# dependencies: rofi

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
TODO_FOLDER="${TODO_FOLDER:-$SCRIPT_PATH/../data/todo}"

TODO_LISTS_PLACEHOLDER="${TODO_LISTS_PLACEHOLDER:-Type something with a \"+\" prefix to create a new TODO list}"
TODO_PLACEHOLDER="${TODO_PLACEHOLDER:-Type something with a \"+\" prefix to create a new TODO item}"

mkdir -p "$TODO_FOLDER"

while todo_file=$(cd "$TODO_FOLDER" && find * -type f | xargs -I{} wc -l {} |\
        $ROFI_CMD -p "ToDo List" -theme-str "entry{placeholder:\"$TODO_LISTS_PLACEHOLDER\";"}); do
    if [[ "$todo_file" = "+"* ]]; then
        todo_file=$(echo "$todo_file" | sed s/^+//g | sed s/^\s+//g)
    else
        todo_file=$(echo "$todo_file" | cut -d' ' -f2-) # remove items count
    fi

    echo "$todo_file"

    TODO_FILE="$TODO_FOLDER/$todo_file" rofi -modi "ToDo $todo_file:$SCRIPT_PATH/rofi-todo.sh" -show "ToDo $todo_file" -theme-str "entry{placeholder:\"$TODO_PLACEHOLDER\";"}
done
