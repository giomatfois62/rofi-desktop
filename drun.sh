#!/bin/bash
#
# rofi-desktop drun script

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"


PATH="$SCRIPT_PATH/scripts/:$PATH" XDG_DATA_DIRS="$SCRIPT_PATH:/usr/local/share:/usr/share:$XDG_DATA_DIRS" rofi -show drun -show-icons True
