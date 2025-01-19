#!/bin/bash
#
# rofi-desktop drun script

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

DRUN_CATEGORIES=${DRUN_CATEGORIES:-}

if [ -n "$DRUN_CATEGORIES" ]; then
    categories="-drun-categories $DRUN_CATEGORIES"
fi

export BOOK_ICONS=1
export SEARCH_ICONS=1
export ROFI="rofi" # -kb-screenshot Control+Shift+space
export PATH="$SCRIPT_PATH/scripts/:$PATH"
export XDG_DATA_DIRS="$SCRIPT_PATH:/usr/local/share:/usr/share:$XDG_DATA_DIRS"

rofi -show drun -show-icons $categories -sidebar-mode
