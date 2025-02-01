#!/bin/bash
#
# this script manages the desktop wallpaper, allowing to choose from a thumbnail's
# grid of images found in the wallpapers directory (default to "$HOME/Pictures")
#
# dependencies: rofi
# optional: feh

# TODO: implement list+preview view

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_CONFIG_DIR="${ROFI_CONFIG_DIR:-$SCRIPT_PATH/config}"
ROFI_GRID_ROWS=${ROFI_GRID_ROWS:-3}
ROFI_GRID_COLS=${ROFI_GRID_COLS:-5}
ROFI_GRID_ICON_SIZE=${ROFI_GRID_ICON_SIZE:-7}
WALLPAPERS_GRID=${WALLPAPERS_GRID:-}
WALLPAPERS_DIR="${WALLPAPERS_DIR:-$HOME/Pictures}"

wallpaper="$1"
wallpaper_cache="$ROFI_CONFIG_DIR/wallpaper"
rofi_theme_grid="element{orientation:vertical;}element-text{horizontal-align:0.5;}element-icon{size:$ROFI_GRID_ICON_SIZE.0em;}listview{lines:$ROFI_GRID_ROWS;columns:$ROFI_GRID_COLS;}"

rofi_flags="-show-icons"

((WALLPAPERS_GRID)) && rofi_flags="$rofi_flags -theme-str $rofi_theme_grid"

set_wallpaper() {
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
            $ROFI -e "Install 'feh'"
            exit 1
        fi

        feh --bg-scale "$wallpaper"

        exit 0
    fi
}

if [ -z "$wallpaper" ]; then
    # find image size to display (very slow)
    #echo $(identify -format '%[fx:w]x%[fx:h]\' ~/Pictures/$A 2>/dev/null)

    # sort by time
    images=$(find "$WALLPAPERS_DIR" -type f -maxdepth 1 \
        -printf "%T@ %f\x00icon\x1f$WALLPAPERS_DIR/%f\n" |\
        sort -rn | cut -d' ' -f2-)

    choice=$(echo -en "Random Choice\x00icon\x1funknown\n$images" | \
        $ROFI -dmenu -i $rofi_flags -p "Wallpaper")

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
    
    # store wallpaper in cache
    cp "$wallpaper" "$wallpaper_cache"
    
    set_wallpaper
elif [ -f "$wallpaper" ]; then
    set_wallpaper
fi
