#!/usr/bin/env bash
#
# this script contains the main rofi-desktop menu, the system settings menu and the utilities menu
# add custom entries in the "commands" array and in the "utils", "main_entries" and "settings_entries" variables
#
# dependencies: rofi
# optional: inxi, rofi-calc, rofi-blocks, curl, greenclip, htop, at, qt5ct, lxappearance

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"
SHOW_ICONS="${SHOW_ICONS:--show-icons}"
TASK_MANAGER="${TASK_MANAGER:-xterm -e htop}"
KEEPASSXC_DATABASE="${KEEPASSXC_DATABASE:-}"
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
    ["Contacts"]=contacts
    ["World Clocks"]=world_clocks
    ["Watch TV"]=tv
    ["Watch Movies/Series"]=streaming
    ["Anime"]=anime
    ["Sport Events"]=livetv
    ["Radio Stations"]=radio
    ["Trivia"]=trivia
    ["Podcasts"]=podcasts
    ["Hangman"]=hangman
    ["All Files"]=search_all
    ["Recently Used"]=search_recent
    ["File Contents"]=search_contents
    ["Bookmarks"]=search_bookmarks
    ["Books"]=search_books
    ["Documents"]=search_documents
    ["Desktop"]=search_desktop
    ["Downloads"]=search_downloads
    ["Music"]=search_music
    ["Pictures"]=search_pics
    ["TNT Village"]=search_tnt
    ["Videos"]=search_videos
    ["Reddit"]=browse_reddit
    ["Install Programs"]=browse_flathub
    ["Flathub"]=browse_flathub
    ["eBooks"]=search_ebooks
    ["Torrents (1337x)"]=search_torrent
    ["Torrents (bitsearch)"]=search_bitsearch
    ["Google"]=search_google
    ["YouTube"]=search_youtube
    ["Wikipedia"]=search_wikipedia
    ["ArchWiki"]=search_archwiki
    ["GitHub"]=search_github
    ["XKCD"]=xkcd
    ["Take Screenshot"]=screenshot
    ["Record Audio/Video"]=record
    ["Code Projects"]=code_projects
    ["YouTube Feeds"]=youtube_feeds
    ["ToDo Lists"]=todo
    ["Color Picker"]=color_picker
    ["Fortune"]=get_fortune
    ["Notes"]=notes
    ["Latest News"]=news
    ["Weather Forecast"]=weather
    ["Exit"]=session_menu
    ["System Settings"]=settings_menu
    ["Utilities"]=utilities_menu
    ["Media Controls"]=media_player
    ["Music Player"]=mpd_controls
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
    ["Switch Window"]=window_menu
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
    ["System Info"]=system_info
    ["Qt5 Appearance"]=qt5_app
    ["GTK Appearance"]=gtk_app
    ["Rofi Style"]=rofi_app
    ["Set Wallpaper"]=wallpaper
    ["Rofi Shortcuts"]=shortcuts
    ["Language"]=set_lang
    ["Updates"]=update_sys
)

main_entries="Applications\nRun Command\nBrowse Files\nSearch Computer\nSearch Web\nLatest News\nWeather Forecast\nWatch TV\nWatch Movies/Series\nRadio Stations\nSport Events\nPodcasts\nUtilities\nSystem Settings\nExit"

settings_entries="Appearance\nNetwork\nVPN\nBluetooth\nDisplay\nVolume\nBrightness\nKeyboard Layout\nRofi Shortcuts\nDefault Applications\nAutostart Applications\nMenu Configuration\nLanguage\nTimezone\nInstall Programs\nSystem Services\nUpdates\nSystem Info"

utilities_entries="Calculator\nCalendar\nContacts\nWorld Clocks\nColor Picker\nDictionary\nSteam Games\nTranslate Text\nCharacters\nMedia Controls\nMusic Player\nNotes\nToDo Lists\nSet Timer\nTake Screenshot\nRecord Audio/Video\nCode Projects\nFortune\nHangman\nTrivia\nCheat Sheets\nSSH Sessions\nTmux Sessions\nPassword Manager\nKeePassXC\nClipboard\nNotifications\nSwitch Window\nTask Manager"

appearance_entries="Qt5 Appearance\nGTK Appearance\nRofi Style\nSet Wallpaper"

search_entries="All Files\nRecently Used\nFile Contents\nBookmarks\nBooks\nDesktop\nDocuments\nDownloads\nMusic\nPictures\nVideos\nTNT Village"

web_entries="Google\nWikipedia\nYouTube\nYouTube Feeds\nArchWiki\nReddit\nGitHub\nXKCD\nTorrents (1337x)\nTorrents (bitsearch)\neBooks\nFlathub\nAnime"

custom_entries=$(cd "$CUSTOM_FOLDER" && find * -type f -name "*.json" | sed -e 's/\.json$//')

all_entries="$main_entries\n$custom_entries\n$search_entries\n$web_entries\n$utilities_entries\n$settings_entries\n$appearance_entries"

show_menu() {
    local menu_entries="$1"
    local menu_prompt="$2"

    # remember last entry chosen
    local selected_row=0
    local selected_text

    while selected=$(echo -en "$menu_entries" |\
            $ROFI_CMD -selected-row ${selected_row} -format 'i s' -p "$menu_prompt"); do
        selected_row=$(echo "$selected" | awk '{print $1;}')
        selected_text=$(echo "$selected" | cut -d' ' -f2-)

        if [ "${commands[$selected_text]+abc}" ]; then
            ${commands[$selected_text]};
        else
            custom_menu_file="$CUSTOM_FOLDER/$selected_text.json"

            if [ -f "$custom_menu_file" ]; then
                rofi "$SHOW_ICONS" -modi "$selected_text:$SCRIPT_PATH/rofi-json.sh  \"$custom_menu_file\"" -show "$selected_text"

                if [ -n "$(cat $ROFI_CACHE_DIR/rofi-json)" ]; then
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

ssh_menu() {
    # TODO: intercept entry chosen to exit
    rofi -show ssh && exit
}

browse_files() {
    # TODO: intercept entry chosen to exit (fixed in git)
    rofi $SHOW_ICONS -show filebrowser && exit
}

window_menu() {
    # TODO: intercept entry chosen to exit
    "$SCRIPT_PATH"/rofi-window.sh && exit
}

shortcuts() {
    rofi -show keys
}

search_all() {
    "$SCRIPT_PATH"/rofi-search.sh "All Files" && exit
}

search_recent() {
    "$SCRIPT_PATH"/rofi-search.sh "Recently Used" && exit
}

search_contents() {
    "$SCRIPT_PATH"/rofi-search.sh "File Contents" && exit
}

search_bookmarks() {
    "$SCRIPT_PATH"/rofi-search.sh "Bookmarks" && exit
}

search_books() {
    "$SCRIPT_PATH"/rofi-search.sh "Books" && exit
}

search_documents() {
    "$SCRIPT_PATH"/rofi-search.sh "Documents" && exit
}

search_downloads() {
    "$SCRIPT_PATH"/rofi-search.sh "Downloads" && exit
}

search_desktop() {
    "$SCRIPT_PATH"/rofi-search.sh "Desktop" && exit
}

search_music() {
    "$SCRIPT_PATH"/rofi-search.sh "Music" && exit
}

search_pics() {
    "$SCRIPT_PATH"/rofi-search.sh "Pictures" && exit
}

search_tnt() {
    "$SCRIPT_PATH"/rofi-search.sh "TNT Village" && exit
}

search_videos() {
    "$SCRIPT_PATH"/rofi-search.sh "Videos" && exit
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

xkcd() {
    "$SCRIPT_PATH"/rofi-xkcd.sh && exit
}

search_github() {
    "$SCRIPT_PATH"/rofi-github.sh && exit
}

livetv() {
    "$SCRIPT_PATH"/rofi-livetv.sh && exit
}

streaming() {
    "$SCRIPT_PATH"/rofi-streaming.sh --rofi && exit
}

anime() {
    "$SCRIPT_PATH"/rofi-anime.sh --rofi && exit
}

search_ebooks() {
    "$SCRIPT_PATH"/rofi-books.sh && exit
}

get_fortune() {
    "$SCRIPT_PATH"/rofi-fortune.sh
}

hangman() {
    "$SCRIPT_PATH"/rofi-hangman.sh
}

trivia() {
    "$SCRIPT_PATH"/rofi-quiz.py
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

search_bitsearch() {
    "$SCRIPT_PATH"/rofi-bitsearch.sh && exit
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
    rofi -kb-screenshot Control+Shift+space -show Timer -modi "Timer:$SCRIPT_PATH/rofi-timer.sh"
}

weather() {
    "$SCRIPT_PATH"/rofi-weather.sh
}

todo() {
    "$SCRIPT_PATH"/rofi-todo-list.sh
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

contacts() {
    "$SCRIPT_PATH"/rofi-contacts.sh
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

youtube_feeds() {
    rofi -kb-screenshot Control+Shift+space -show "Youtube Feeds" -modi "Youtube Feeds:$SCRIPT_PATH/rofi-youtube-feeds.sh" && exit
}

keepassxc() {
    "$SCRIPT_PATH"/rofi-keepassxc.sh -d "$KEEPASSXC_DATABASE" && exit
}

wireguard() {
    rofi -modi VPN:"$SCRIPT_PATH"/wireguard-rofi.sh -show VPN
}

calculator() {
    if [ -n "$(rofi -dump-config | grep calc)" ]; then
        rofi -show calc
    else
        rofi -modi calc:"$SCRIPT_PATH"/rofi-calc.sh -show calc
    fi
}

task_mgr() {
    if [ -n "$(rofi -dump-config | grep blocks)" ]; then
        "$SCRIPT_PATH"/rofi-top.sh
    else
        eval "$TASK_MANAGER"
    fi
}

notifications() {
    if [ "$(ps aux | grep -c rofication-daemon)" -gt 1 ]; then
        "$SCRIPT_PATH"/rofication-gui.py
    else
        rofi -e "Run \"$SCRIPT_PATH/rofication-daemon.py &\" to enable the notifications menu"
    fi
}

clipboard() {
    "$SCRIPT_PATH"/rofi-clip.sh
}

menu_config() {
    menu_file=$(find "$SCRIPT_PATH" -type f | sort | $ROFI_CMD -p "Open File")

    if [ -n "$menu_file" ]; then
        xdg-open "$menu_file" && exit 0
    fi
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

wallpaper() {
    "$SCRIPT_PATH"/rofi-wallpaper.sh;
}

update_sys() {
    "$SCRIPT_PATH"/update-system.sh;
}

system_info() {
    "$SCRIPT_PATH"/rofi-system-info.sh;
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
