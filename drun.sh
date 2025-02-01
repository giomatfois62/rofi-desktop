#!/bin/bash
#
# rofi-desktop drun script

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

set -a
source "$SCRIPT_PATH/scripts/config/environment"
set +a

export ROFI="${ROFI:-rofi}"
export PATH="$SCRIPT_PATH/scripts/:$PATH"
export XDG_DATA_DIRS="$SCRIPT_PATH:/usr/local/share:/usr/share:$XDG_DATA_DIRS"

DRUN_CATEGORIES=${DRUN_CATEGORIES:-}

if [ -n "$DRUN_CATEGORIES" ]; then
    categories="-drun-categories $DRUN_CATEGORIES"
fi

((ROFI_ICONS)) && rofi_flags="-show-icons"

$ROFI -show drun $rofi_flags $categories -sidebar-mode
