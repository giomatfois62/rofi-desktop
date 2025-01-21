#!/usr/bin/env bash
#
# this script shows the rofi window modi to switch active window using an optional thumbnails grid
#
# dependencies: rofi

ROFI="${ROFI:-rofi}"
SHOW_ICONS="${SHOW_ICONS:--show-icons}"
SHOW_WINDOW_THUMBNAILS="${SHOW_WINDOW_THUMBNAILS:--window-thumbnail}"
SHOW_THUMBNAILS_GRID="${SHOW_THUMBNAILS_GRID:-yes}"
THUMB_GRID_ROWS=${THUMB_GRID_ROWS:-2}
THUMB_GRID_COLS=${THUMB_GRID_COLS:-3}
THUMB_ICON_SIZE=${THUMB_ICON_SIZE:-10}

build_theme() {
    rows=$1
    cols=$2
    icon_size=$3

    echo "element{orientation:vertical;}element-text{horizontal-align:0.5;}element-icon{size:$icon_size.0000em;}listview{lines:$rows;columns:$cols;}"
}

if [ "$SHOW_THUMBNAILS_GRID" = "yes" ]; then
    $ROFI $SHOW_ICONS $SHOW_WINDOW_THUMBNAILS -show window -theme-str $(build_theme $THUMB_GRID_ROWS $THUMB_GRID_COLS $THUMB_ICON_SIZE)
else
    $ROFI $SHOW_ICONS $SHOW_WINDOW_THUMBNAILS -show window
fi
