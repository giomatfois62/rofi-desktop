#!/bin/bash
#
# this script manages the desktop wallpaper, allowing to choose from a thumbnail's
# grid of images found in the wallpapers directory (default to "$HOME/Pictures")
#
# dependencies: rofi
# optional: feh

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
WALLPAPERS_DIR="${WALLPAPERS_DIR:-$HOME/Pictures}"
WALLPAPER_CACHE="${WALLPAPER_CACHE:-$HOME/.cache/wallpaper}"
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

images=$(find "$WALLPAPERS_DIR" -type f -maxdepth 1 -printf "%f\x00icon\x1f$WALLPAPERS_DIR/%f\n")

#ls $sort_by_time --escape "$WALLPAPERS_DIR"

choice=$(\
    echo -en "Random Choice\n""$images" | \
        $ROFI_CMD -show-icons -theme-str $(build_theme $GRID_ROWS $GRID_COLS $ICON_SIZE) -p "Wallpaper" \
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

if [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
    qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "var allDesktops = desktops();print (allDesktops);for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.wallpaperPlugin = \"org.kde.image\";d.currentConfigGroup = Array(\"Wallpaper\", \"org.kde.image\", \"General\");d.writeConfig(\"Image\", \"file:$wallpaper\")}"

    qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "var allDesktops = desktops();print (allDesktops);for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.wallpaperPlugin = \"org.kde.image\";d.currentConfigGroup = Array(\"Wallpaper\", \"org.kde.image\", \"General\");d.writeConfig(\"Image\", \"file:$wallpaper\")}"

    exit 0
elif [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
    gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$wallpaper"

    exit 0
elif [ "$XDG_CURRENT_DESKTOP" = "sway" ]; then
    swaymsg output "*" bg "$wallpaper" "stretch"

    exit 0
else
    # fallback on feh
    if ! command -v feh &> /dev/null; then
        rofi -e "Install 'feh'"
        exit 1
    fi

    feh --bg-scale "$wallpaper"

    exit 0
fi

exit 1
