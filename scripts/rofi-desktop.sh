#!/usr/bin/env bash
#
# this script contains the main rofi-desktop menu, the system settings menu and the utilities menu
# add custom entries in the "commands" array and in the "utils", "main_entries" and "settings_entries" variables
#
# dependencies: rofi, inxi, qt5ct, lxappearance
# optional: rofi-calc, curl, greenclip, htop, at

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
SHOW_ICONS="${SHOW_ICONS:--show-icons}"
TASK_MANAGER="${TASK_MANAGER:-xterm -e htop}"
SYSTEM_INFO="${SYSTEM_INFO:-inxi -c0 -v2 | $ROFI_CMD -p Info}"
PROJECTS_DIRECTORY="${PROJECTS_DIRECTORY:-~/Programs}"
PROJECTS_EDITOR="${PROJECTS_EDITOR:-qtcreator}"
KEEPASSXC_DATABASE="${KEEPASSXC_DATABASE:-}"
TODO_FOLDER="${TODO_FOLDER:-$HOME/.todo}"
CUSTOM_FOLDER="${CUSTOM_FOLDER:-$SCRIPT_PATH/menus}"

declare -A commands=(
    ["Applications"]=run_app
    ["Run Command"]=run_cmd
    ["Browse Files"]=browse_files
    ["Search Computer"]=search
    ["Search Web"]=web_search
    ["Steam Games"]=steam_games
    ["Calculator"]=calculator
    ["Calendar"]=calendar
    ["World Clocks"]=world_clocks
    ["Watch TV"]=tv
    ["Sport Events"]=livetv
    ["Radio Stations"]=radio
    ["Podcasts"]=podcasts
    ["Reddit"]=browse_reddit
    ["Install Programs"]=browse_flathub
    ["Flathub"]=browse_flathub
    ["Torrents"]=search_torrent
    ["Google"]=search_google
    ["YouTube"]=search_youtube
    ["Wikipedia"]=search_wikipedia
    ["ArchWiki"]=search_archwiki
    ["Torrents"]=search_torrent
    ["Take Screenshot"]=screenshot
    ["Record Audio/Video"]=record
    ["Code Projects"]=code_projects
    ["TODOs"]=todo
    ["Color Picker"]=color_picker
    ["Notes"]=notes
    ["Latest News"]=news
    ["Weather Forecast"]=weather
    ["Exit"]=session_menu
    ["System Settings"]=settings_menu
    ["Utilities"]=utilities_menu
    ["Media Player"]=media_player
    ["Play Music"]=mpd_controls
    ["ChatGPT"]=chat_gpt
    ["Dictionary"]=dictionary
    ["Cheat Sheets"]=cheat_sh
    ["Set Timer"]=set_timer
    ["SSH Sessions"]=ssh_menu
    ["Tmux Sessions"]=tmux_menu
    ["Password Manager"]=passwd_mgr
    ["KeePassXC"]=keepassxc
    ["Clipboard"]=clipboard
    ["Translate Text"]=translate
    ["Task Manager"]=task_mgr
    ["Notifications"]=notifications
    ["Characters"]=char_picker
    ["Appearance"]=appearance_menu
    ["Network"]=network
    ["VPN"]=wireguard
    ["Bluetooth"]=bluetooth
    ["Display"]=display
    ["Volume"]=volume
    ["Brightness"]=brightness
    ["Keyboard Layout"]=kb_layout
    ["Timezone"]=world_clocks
    ["Default Applications"]=default_apps
    ["Autostart Applications"]=autostart_apps
    ["Menu Configuration"]=menu_config
    ["System Services"]=systemd_config
    ["System Info"]=sys_info
    ["Qt5 Appearance"]=qt5_app
    ["GTK Appearance"]=gtk_app
    ["Rofi Style"]=rofi_app
    ["Set Wallpaper"]=wallpaper
    ["Rofi Shortcuts"]=shortcuts
    ["Language"]=set_lang
    ["Updates"]=update_sys
)

main_entries="Applications\nRun Command\nBrowse Files\nSearch Computer\nSearch Web\nSteam Games\nLatest News\nWeather Forecast\nWatch TV\nRadio Stations\nSport Events\nPodcasts\nUtilities\nSystem Settings\nExit"

settings_entries="Appearance\nNetwork\nVPN\nBluetooth\nDisplay\nVolume\nBrightness\nKeyboard Layout\nRofi Shortcuts\nDefault Applications\nAutostart Applications\nMenu Configuration\nLanguage\nTimezone\nInstall Programs\nSystem Services\nUpdates\nSystem Info"

utilities_entries="Calculator\nCalendar\nWorld Clocks\nColor Picker\nDictionary\nTranslate Text\nCharacters\nMedia Player\nPlay Music\nNotes\nTODOs\nSet Timer\nTake Screenshot\nRecord Audio/Video\nCode Projects\nCheat Sheets\nSSH Sessions\nTmux Sessions\nPassword Manager\nKeePassXC\nClipboard\nNotifications\nTask Manager"

appearance_entries="Qt5 Appearance\nGTK Appearance\nRofi Style\nSet Wallpaper"

web_entries="Google\nWikipedia\nYouTube\nArchWiki\nReddit\nTorrents\nFlathub"

custom_entries=$(cd "$CUSTOM_FOLDER" && find * -type f -name "*.json" | sed -e 's/\.json$//')

all_entries="$main_entries\n$custom_entries\n$web_entries\n$utilities_entries\n$settings_entries\n$appearance_entries"

show_menu() {
    local menu_entries="$1"
    local menu_prompt="$2"

    # remember last entry chosen
    local selected_row=0
    local selected_text

    while selected=$(echo -en "$menu_entries" | $ROFI_CMD -selected-row ${selected_row} -format 'i s' -p "$menu_prompt" -kb-screenshot "Alt+s"); do
        selected_row=$(echo "$selected" | awk '{print $1;}')
        selected_text=$(echo "$selected" | cut -d' ' -f2-)

        if [ "${commands[$selected_text]+abc}" ]; then
            ${commands[$selected_text]};
        else
            custom_menu_file="$CUSTOM_FOLDER/$selected_text.json"

            if [ -f "$custom_menu_file" ]; then
                rofi -modi "$selected_text":"$SCRIPT_PATH/rofi-json.sh  \"$custom_menu_file\"" -show "$selected_text"
		if [ -n "$(cat $HOME/.cache/rofi-json)" ]; then
                    exit
                fi
            fi
        fi
    done
}

utilities_menu() {
    show_menu "$utilities_entries" "Utilities"
}

main_menu() {
    show_menu "$main_entries" "Main Menu"
}

settings_menu() {
    show_menu "$settings_entries" "Settings"
}

appearance_menu() {
    show_menu "$appearance_entries" "Appearance"
}

combi_menu() {
    show_menu "$all_entries" "All"
}

web_search() {
    show_menu "$web_entries" "Website"
}

custom_menu() {
    show_menu "$custom_entries" "Menu"
}

run_app() {
    logfile="$HOME/.cache/rofi-drun.log"
    G_MESSAGES_DEBUG=Modes.DRun rofi -show drun $SHOW_ICONS -log "$logfile";

    # very hacky!!! intercept exit code grepping log file
    entry_chosen=$(grep "Parsed command:" "$logfile")
    rm "$logfile"

    if [ -n "$entry_chosen" ]; then
        echo "Entry chosen"
        exit 0;
    fi
}

run_cmd() {
    logfile="$HOME/.cache/rofi-run.log"
    G_MESSAGES_DEBUG=Modes.Run rofi -show run $SHOW_ICONS -log "$logfile";

    # very hacky!!! intercept exit code grepping log file
    entry_chosen=$(grep "Parsed command:" "$logfile")
    rm "$logfile"

    if [ -n "$entry_chosen" ]; then
        echo "Entry chosen"
        exit 0;
    fi
}

browse_files() {
    # TODO: intercept entry chosen to exit (fixed in git)
    rofi $SHOW_ICONS -show filebrowser && exit
}

ssh_menu() {
    # TODO: intercept entry chosen to exit
    rofi -show ssh && exit
}

cheat_sh() {
    "$SCRIPT_PATH"/rofi-cheat.sh && exit
}

steam_games() {
    "$SCRIPT_PATH"/rofi-steam.sh && exit
}

search() {
    "$SCRIPT_PATH"/rofi-search.sh && exit
}

podcasts() {
    "$SCRIPT_PATH"/rofi-podcast.sh && exit
}

code_projects() {
    "$SCRIPT_PATH"/rofi-projects.sh && exit
}

color_picker() {
    "$SCRIPT_PATH"/rofi-color-picker.sh && exit
}

livetv() {
    "$SCRIPT_PATH"/rofi-livetv.sh && exit
}

mpd_controls() {
    "$SCRIPT_PATH"/rofi-mpd.sh -a && exit
}

browse_flathub() {
    "$SCRIPT_PATH"/rofi-flathub.sh && exit
}

browse_reddit() {
    "$SCRIPT_PATH"/rofi-reddit.sh && exit
}

search_torrent() {
    "$SCRIPT_PATH"/rofi-torrent.sh && exit
}

search_google() {
    "$SCRIPT_PATH"/rofi-web-search.sh "google" && exit
}

search_youtube() {
    "$SCRIPT_PATH"/rofi-web-search.sh "youtube" && exit
}

search_wikipedia() {
    "$SCRIPT_PATH"/rofi-web-search.sh "wikipedia" && exit
}

search_archwiki() {
    "$SCRIPT_PATH"/rofi-web-search.sh "archwiki" && exit
}

set_timer() {
    local placeholder="Type <hours>h <minutes>m <seconds>s to set a custom timer"

    rofi -show Timer -modi Timer:"$SCRIPT_PATH"/rofi-timer.sh \
        -theme-str "entry{placeholder:\"$placeholder\";"}
}

weather() {
    local placeholder="Type the name of a city and press \"Enter\" to show weather from another location"

    while city=$(curl wttr.in/"$city"?ATFn | rofi -dmenu -p "Weather" -theme-str "entry{placeholder:\"$placeholder\";"}); do
        echo "Showing weather for" "$city"
    done
}

todo() {
    mkdir -p $TODO_FOLDER

    local list_placeholder="Type something with a \"+\" prefix to create a new TODO list"
    local todo_placeholder="Type something with a \"+\" prefix to add a new TODO item"

    while todo_file=$(cd "$TODO_FOLDER" && find * -type f | $ROFI_CMD -p "TODOs" -theme-str "entry{placeholder:\"$list_placeholder\";"}); do
        if [[ $todo_file == +* ]];then
            todo_file=$(echo "$todo_file" | sed s/^+//g |sed s/^\s+//g)
        fi

        TODO_FILE="$TODO_FOLDER/$todo_file" rofi -modi "TODOs $todo_file":"$SCRIPT_PATH"/rofi-todo.sh -show "TODO $todo_file" -theme-str "entry{placeholder:\"$todo_placeholder\";"}
    done
}

dictionary() {
    "$SCRIPT_PATH"/rofi-dict.sh && exit
}

settings() {
    "$SCRIPT_PATH"/rofi-settings.sh && exit
}

tv() {
    "$SCRIPT_PATH"/rofi-tv.sh && exit
}

radio() {
    "$SCRIPT_PATH"/rofi-radio.sh && exit
}

screenshot() {
    "$SCRIPT_PATH"/rofi-screenshot.sh && exit
}

record() {
    "$SCRIPT_PATH"/rofi-ffmpeg.sh && exit
}

session_menu() {
    "$SCRIPT_PATH"/rofi-session.sh && exit
}

media_player() {
    "$SCRIPT_PATH"/rofi-playerctl.sh && exit
}

systemd_config() {
    "$SCRIPT_PATH"/rofi-systemd.sh && exit
}

chat_gpt() {
    "$SCRIPT_PATH"/rofi-gpt.sh && exit
}

notes() {
    "$SCRIPT_PATH"/rofi-notes.sh && exit
}

news() {
    "$SCRIPT_PATH"/rofi-news.sh && exit
}

tmux_menu() {
    "$SCRIPT_PATH"/rofi-tmux.sh && exit
}

passwd_mgr() {
    "$SCRIPT_PATH"/rofi-passmenu.sh && exit
}

calendar() {
    "$SCRIPT_PATH"/rofi-calendar.sh
}

world_clocks() {
    "$SCRIPT_PATH"/rofi-clocks.sh && exit
}

translate() {
    "$SCRIPT_PATH"/rofi-translate.sh
}

char_picker() {
    "$SCRIPT_PATH"/rofi-characters.sh && exit
}

keepassxc() {
    "$SCRIPT_PATH"/rofi-keepassxc.sh -d "$KEEPASSXC_DATABASE" && exit
}

wireguard() {
    rofi -modi VPN:"$SCRIPT_PATH"/wireguard-rofi.sh -show VPN
}

calculator() {
    have_calc=$(rofi -dump-config | grep calc)

    if [ -n "$have_calc" ]; then
        rofi -show calc
    else
        rofi -modi calc:"$SCRIPT_PATH"/rofi-calc.sh -show calc
    fi
}

task_mgr() {
    have_blocks=$(rofi -dump-config | grep blocks)

    if [ -n "$have_blocks" ]; then
        "$SCRIPT_PATH"/rofi-top.sh
    else
        eval "$TASK_MANAGER"
    fi
}

notifications() {
    daemon_running=$(ps aux | grep -c "rofication-daemon")

    if [ "${daemon_running}" -gt 1 ]; then
        "$SCRIPT_PATH"/rofication-gui.py
    else
        rofi -e "Run \"$SCRIPT_PATH/rofication-daemon.py &\" to enable the notifications menu"
    fi
}

clipboard() {
    if command -v greenclip &> /dev/null; then
        rofi -modi "clipboard:greenclip print" -show clipboard -run-command '{cmd}'
    elif [ -f "$SCRIPT_PATH/greenclip" ]; then
        daemon_running=$(ps aux | grep -c "greenclip")

        if [ "${daemon_running}" -gt 1 ]; then
            rofi -modi "clipboard:$SCRIPT_PATH/greenclip print" -show clipboard -run-command '{cmd}'
        else
            rofi -e "Run \"$SCRIPT_PATH/greenclip daemon &\" to enable the clipboard menu"
        fi
    else
        rofi -e "Download greenclip and place it inside \"$SCRIPT_PATH\" to enable the clipboard menu"
    fi
}

menu_config() {
    menu_file=$(find "$SCRIPT_PATH" -type f | sort | $ROFI_CMD -p "Open File")

    if [ -n "$menu_file" ]; then
        xdg-open "$menu_file" && exit 0
    fi
}

shortcuts() {
    rofi -show keys
}

network() {
    "$SCRIPT_PATH"/networkmanager_dmenu
}

bluetooth() {
    "$SCRIPT_PATH"/rofi-bluetooth.sh
}

display() {
    "$SCRIPT_PATH"/rofi-monitor-layout.sh
}

volume() {
    "$SCRIPT_PATH"/rofi-volume.sh
}

set_lang() {
    "$SCRIPT_PATH"/rofi-locale.sh
}

sys_info() {
    eval "$SYSTEM_INFO"
}

default_apps() {
    "$SCRIPT_PATH"/rofi-mime.sh
}

autostart_apps() {
	"$SCRIPT_PATH"/rofi-autostart.sh && exit
}

brightness() {
    "$SCRIPT_PATH"/rofi-brightness.sh
}

kb_layout() {
    "$SCRIPT_PATH"/rofi-keyboard-layout.sh
}

check_program() {
    if ! command -v $1 &> /dev/null; then
        rofi -e "Install $1"
    else
        $1
    fi
}

qt5_app() {
    check_program qt5ct;
}

gtk_app() {
    check_program lxappearance;
}

rofi_app() {
    check_program rofi-theme-selector;
}

wallpaper() {
    "$SCRIPT_PATH"/rofi-wallpaper.sh;
}

update_sys() {
    "$SCRIPT_PATH"/update-system.sh;
}

print_help() {
    echo "Available options: [-d|h|s|u]"
    echo
    echo "c     Show custom menus"
    echo "d     Show the main desktop menu."
    echo "f     Show the file search menu"
    echo "h     Print this Help."
    echo "s     Show the system settings menu."
    echo "u     Show the utilities menu."
    echo "w     Show the web search menu"
    echo "a     Show all menu entries"
    echo
}

# run
while getopts ":hcdfsuwa" option; do
    case $option in
        h) # display help
            print_help;;
        c) # display custom menus
            custom_menu;;
        d) # display main menu
            main_menu;;
        f) # display file search menu
            search;;
        s) # display settings menu
            settings_menu;;
        u) # display utilities menu
            utilities_menu;;
        w) # display web search menu
            web_search;;
        a) # display all menus
            combi_menu;;
        \?) # display main menu
            echo "Invalid option:" "$1"
            print_help;;
    esac
    exit
done

# show main menu if no args provided
main_menu
