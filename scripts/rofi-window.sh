#!/usr/bin/env bash
#
# this script shows the rofi window modi to switch active window using an optional thumbnails grid
#
# dependencies: rofi

ROFI="${ROFI:-rofi}"
ROFI_ICONS="${ROFI_ICONS:-}"
WINDOWS_THUMBNAILS="${WINDOWS_THUMBNAILS:-}"
WINDOWS_GRID="${WINDOWS_GRID:-}"
WINDOWS_GRID_ROWS=${WINDOWS_GRID_ROWS:-${ROFI_GRID_ROWS:-2}}
WINDOWS_GRID_COLS=${WINDOWS_GRID_COLS:-${ROFI_GRID_COLS:-4}}
WINDOWS_GRID_ICON_SIZE=${WINDOWS_GRID_ICON_SIZE:-${ROFI_GRID_ICON_SIZE:-10}}

rofi_theme_grid="element{orientation:vertical;}element-text{horizontal-align:0.5;}element-icon{size:$WINDOWS_GRID_ICON_SIZE.0em;}listview{lines:$WINDOWS_GRID_ROWS;columns:$WINDOWS_GRID_COLS;}"
rofi_flags=""

[ -n "$ROFI_ICONS" ] && rofi_flags="$rofi_flags -show-icons"
[ -n "$ROFI_ICONS" ] && [ -n "$WINDOWS_THUMBNAILS" ] && rofi_flags="$rofi_flags -window-thumbnail"
[ -n "$ROFI_ICONS" ] && [ -n "$WINDOWS_GRID" ] && rofi_flags="$rofi_flags -theme-str $rofi_theme_grid"

$ROFI -show window $rofi_flags -display-window "Window"
