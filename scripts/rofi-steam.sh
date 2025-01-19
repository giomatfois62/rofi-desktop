#!/usr/bin/env bash
#
# https://github.com/ntcarlson/dotfiles/tree/delta/config/rofi
#
# Generates .desktop entries for all installed Steam games with box art for
# the icons to be used with a specifically configured Rofi launcher
#
# dependencies: rofi, steam

SCRIPT_DIR=$(dirname $(realpath $0))

ROFI="${ROFI:-rofi}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"
STEAM_ROOT="${STEAM_ROOT:-$HOME/.local/share/Steam}"
GAME_LAUNCHER_CACHE="$ROFI_CACHE_DIR/rofi-game-launcher"
GAME_APP_PATH="$GAME_LAUNCHER_CACHE/applications"

# Fetch all Steam library folders.
steam-libraries() {
    echo "$STEAM_ROOT"

    # Additional library folders are recorded in libraryfolders.vdf
    libraryfolders=$STEAM_ROOT/steamapps/libraryfolders.vdf
    # Match directories listed in libraryfolders.vdf (or at least all strings
    # that look like directories)
    grep -oP "(?<=\")/.*(?=\")" $libraryfolders
}

# Generate the contents of a .desktop file for a Steam game.
# Expects appid, title, and box art file to be given as arguments
desktop-entry() {
cat <<EOF
[Desktop Entry]
Name=$2
Exec=$SCRIPT_DIR/rofi-steam.sh $1
Icon=$3
Terminal=false
Type=Application
Categories=SteamLibrary;
EOF
}

update-game-entries() {
    local OPTIND=1
    local quiet update

    while getopts 'qf' arg
    do
        case ${arg} in
            f) update=1;;
            q) quiet=1;;
            *)
                echo "Usage: $0 [-f] [-q]"
                echo "  -f: Full refresh; update existing entries"
                echo "  -q: Quiet; Turn off diagnostic output"
                exit
        esac
    done

    mkdir -p "$GAME_APP_PATH"

    for library in $(steam-libraries); do
        # All installed Steam games correspond with an appmanifest_<appid>.acf file
        if [ -z "$(shopt -s nullglob; echo "$library"/steamapps/appmanifest_*.acf)" ]; then
            # Skip empty library folders
            continue
        fi

        for manifest in "$library"/steamapps/appmanifest_*.acf; do
            appid=$(basename "$manifest" | tr -dc "[0-9]")
            entry=$GAME_APP_PATH/${appid}.desktop

            # Don't update existing entries unless doing a full refresh
            if [ -z $update ] && [ -f "$entry" ]; then
                [ -z $quiet ] && echo "Not updating $entry"
                continue
            fi

            title=$(awk -F\" '/"name"/ {print $4}' "$manifest" | tr -d "™®")
            boxart=$STEAM_ROOT/appcache/librarycache/${appid}_library_600x900.jpg

            # Filter out non-game entries (e.g. Proton versions or soundtracks) by
            # checking for boxart and other criteria
            if [ ! -f "$boxart" ]; then
                [ -z $quiet ] && echo "Skipping $title"
                continue
            fi
            if echo "$title" | grep -qe "Soundtrack"; then
                [ -z $quiet ] && echo "Skipping $title"
                continue
            fi
            [ -z $quiet ] && echo -e "Generating $entry\t($title)"
            desktop-entry "$appid" "$title" "$boxart" > "$entry"
        done
    done
}

build_theme() {
    rows=$1
    cols=$2
    icon_size=$3

    echo "element{orientation:vertical;}element-text{horizontal-align:0.5;}element-icon{size:$icon_size.0000em;}listview{lines:$rows;columns:$cols;}"
}

select_game() {
    update-game-entries -q &

    (
        # Temporarily overwrite XDG_DATA_HOME so that Rofi looks for
        # .desktop files in $GAME_LAUNCHER/applications instead of
        # ~/.local/share/applications
        export XDG_DATA_HOME=$GAME_LAUNCHER_CACHE

        logfile="$HOME/.cache/rofi-drun.log"

        G_MESSAGES_DEBUG=Modes.DRun $ROFI -show drun -show-icons -p "Games" \
            -drun-categories SteamLibrary \
            -log "$logfile"\
            -cache-dir $GAME_LAUNCHER_CACHE \
            -theme-str "$(build_theme 3 4 7)"

        # very hacky!!! intercept exit code grepping log file
        entry_chosen=$(grep "Parsed command:" "$logfile")
        rm "$logfile"

        if [ ${#entry_chosen} -eq 0 ]; then
            exit 1
        fi
    )
}

game_menu() {
    PLAY=""
    OPTIONS=""
    LIBRARY=""
    ACHIEVEMENTS=""
    NEWS=""
    BACK=""

    APPID=$1

    list-icons() {
        echo $PLAY Play
        echo $LIBRARY Open in library
        echo $ACHIEVEMENTS Achievements
        echo $NEWS News
        echo $BACK Back
    }

    # See https://developer.valvesoftware.com/wiki/Steam_browser_protocol
    # for a list of all commands that can be sent to Steam

    handle-option() {
        case $1 in
            "$PLAY")          steam steam://rungameid/$APPID;;
            "$LIBRARY")       steam steam://nav/games/details/$APPID;;
            "$ACHIEVEMENTS")  steam steam://url/SteamIDAchievementsPage/$APPID;;
            "$NEWS")          steam steam://appnews/$APPID;;
            "$BACK")          select_game
        esac
    }

    SELECTION=$(list-icons | $ROFI -dmenu -i -p "Action")

    if [ ${#SELECTION} -gt 0 ]; then
        handle-option $SELECTION &
    else
        select_game
    fi
}

if [ "$@" ]; then
    game_menu $1
else
    select_game
fi
