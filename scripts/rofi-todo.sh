#!/bin/bash
#
# https://github.com/claudiodangelis/rofi-todo
#
# this script manages a simple to-do list stored locally
# it allows adding and removing to-do entries
#
# dependencies: rofi

TODO_FILE="${TODO_FILE:-$HOME/.todos}"
DONE_FILE="${DONE_FILE:-$HOME/.todos_done}"

todo_help="Type something with a \"+\" prefix and press <b>Enter</b> to add a new item"

if [[ ! -a "${TODO_FILE}" ]]; then
    touch "${TODO_FILE}"
fi

function add_todo() {
    echo -e "`date +"%d %B %Y %H:%M"` $*" >> "${TODO_FILE}"
}

function remove_todo() {
    if [[ ! -z "$DONE_FILE" ]]; then
        echo "<s>${*}</s>" >> "${DONE_FILE}"
    fi
#     
    sed -i "s|^${*}$||g" "${TODO_FILE}"
    sed -i '/^$/d' "${TODO_FILE}"
    
    # doesn't work
    #awk -i inplace '/^${*}$/ { $0 = "<s>" $0 "</s>" }; 1' "${TODO_FILE}"
}

function get_todos() {
    echo -en "\0markup-rows\x1ftrue\n"
    echo -en "\0message\x1f$todo_help\n"
    echo "$(cat "${TODO_FILE}")"
    echo "$(cat "${DONE_FILE}")"
}

if [ -z "$@" ]; then
    get_todos
else
    LINE=$(echo "${@}" | sed "s/\([^a-zA-Z0-9]\)/\\\\\\1/g")
    LINE_UNESCAPED=${@}
    if [[ $LINE_UNESCAPED == +* ]]; then
        LINE_UNESCAPED=$(echo $LINE_UNESCAPED | sed s/^+//g |sed s/^\s+//g )
        add_todo ${LINE_UNESCAPED}
    elif [[ $LINE_UNESCAPED != "<s>"* ]]; then
        MATCHING=$(grep "^${LINE_UNESCAPED}$" "${TODO_FILE}")
        if [[ -n "${MATCHING}" ]]; then
            remove_todo ${LINE_UNESCAPED}
        fi
    fi
    get_todos
fi
