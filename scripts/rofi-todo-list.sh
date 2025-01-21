#!/bin/bash
#
# this script manages a folder of todo lists using the modi in rofi-todo.sh
#
# dependencies: rofi

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_DATA_DIR="${ROFI_DATA_DIR:-$SCRIPT_PATH/data}"

todo_lists_help="Type something with a \"+\" prefix to create a new TODO list"
todo_help="Type something with a \"+\" prefix to create a new TODO item"
todo_dir="$ROFI_DATA_DIR/todo"

mkdir -p "$todo_dir"

while todo_file=$(cd "$todo_dir" && find * -type f -not -name "*_done" | xargs -I{} wc -l {} |\
        $ROFI -dmenu -i -p "ToDo List" -theme-str "entry{placeholder:\"$todo_lists_help\";"}); do

    if [[ "$todo_file" = "+"* ]]; then
        todo_file=$(echo "$todo_file" | sed s/^+//g | sed s/^\s+//g)
    else
        todo_file=$(echo "$todo_file" | cut -d' ' -f2-) # remove items count
    fi

    done_file="$todo_file""_done"

    TODO_FILE="$todo_dir/$todo_file" \
    DONE_FILE="$todo_dir/$done_file" \
    $ROFI -kb-screenshot Control+Shift+space -modi "ToDo $todo_file:$SCRIPT_PATH/rofi-todo.sh" -show "ToDo $todo_file" -theme-str "entry{placeholder:\"$todo_help\";}"
done
