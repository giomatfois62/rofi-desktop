#!/bin/bash
#
# this script manages a folder of todo lists using the modi in rofi-todo.sh
#
# dependencies: rofi

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_DATA_DIR="${ROFI_DATA_DIR:-$SCRIPT_PATH/data}"

todo_dir="$ROFI_DATA_DIR/todo"

mkdir -p "$todo_dir"

get_todo_lists() {
    cd "$todo_dir" && find * -type f -not -name "*_done" | xargs -I{} wc -l {}
}

while todo_file=$(echo -en "New ToDo List\n$(get_todo_lists)" |\
    $ROFI -dmenu -i -p "ToDo List"); do

    if [[ "$todo_file" = "New ToDo List"* ]]; then
        todo_file=$((echo) | $ROFI -dmenu -p "List Name")
    else
        todo_file=$(echo "$todo_file" | cut -d' ' -f2-) # remove items count
    fi

    [ -z "$todo_file" ] && exit 1

    TODO_FILE="$todo_dir/$todo_file" \
    $ROFI -modi "ToDo $todo_file:$SCRIPT_PATH/rofi-todo.sh" -show "ToDo $todo_file"
done
