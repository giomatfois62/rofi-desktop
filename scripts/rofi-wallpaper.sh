#!/bin/bash
#
# this script manages the desktop wallpaper, allowing to choose from a thumbnail's
# grid of images found in the wallpapers directory (default to "$HOME/Pictures")
#
# dependencies: rofi
# optional: feh

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_CONFIG_DIR="${ROFI_CONFIG_DIR:-$SCRIPT_PATH/config}"
WALLPAPERS_DIR="${WALLPAPERS_DIR:-$HOME/Pictures}"
WALLPAPER_CACHE="$ROFI_CONFIG_DIR/wallpaper"
GRID_ROWS=${GRID_ROWS:-3}
GRID_COLS=${GRID_COLS:-5}
ICON_SIZE=${ICON_SIZE:-6}

build_theme() {
    rows=$1
    cols=$2
    icon_size=$3

    echo "element{orientation:vertical;}element-text{horizontal-align:0.5;}element-icon{size:$icon_size.0000em;}listview{lines:$rows;columns:$cols;}"
}

# find image size to display (very slow)
#echo $(identify -format '%[fx:w]x%[fx:h]\' ~/Pictures/$A 2>/dev/null)

#images=$(find "$WALLPAPERS_DIR" -type f -maxdepth 1 -printf "%f\x00icon\x1f$WALLPAPERS_DIR/%f\n")
images=$(find "$WALLPAPERS_DIR" -type f -maxdepth 1 \
    -printf "%T@ %f\x00icon\x1f$WALLPAPERS_DIR/%f\n" |\
    sort -rn | cut -d' ' -f2-)

choice=$(\
    echo -en "Random Choice\n$images" | \
        $ROFI -dmenu -i -show-icons -theme-str $(build_theme $GRID_ROWS $GRID_COLS $ICON_SIZE) -p "Wallpaper" \
)

if [ -z "$choice" ]; then
    exit 1;
fi

if [ "$choice" = "Random Choice" ]; then
    choice=$(find "$WALLPAPERS_DIR" -type f -maxdepth 1 -printf "%f\n" | shuf -n1)

    if [ -z "$choice" ]; then
        exit 1;
    fi
fi

wallpaper="$WALLPAPERS_DIR/$choice"

echo "Setting wallpaper " "$wallpaper"
cp "$wallpaper" "$WALLPAPER_CACHE"

"$SCRIPT_PATH/set-wallpaper.sh" "$wallpaper"
