#!/usr/bin/env bash

# optional: rofi-calc

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"
ROFI_CMD="rofi -dmenu -i -matching fuzzy"
SHOW_ICONS="-show-icons"
TASK_MANAGER="xterm -e htop"

declare -A commands=(
    ["Applications"]=run_app
    ["Run Command"]=run_cmd
    ["Browse Files"]=browse
    ["Search Computer"]=search
    ["Search Web"]=web_search
    ["Steam Games"]=steam_games
    ["Calculator"]=calculator
    ["Calendar"]=calendar
    ["Watch TV"]=tv
    ["Radio Stations"]=radio
    ["Take Screenshot"]=screenshot
    ["Record Audio/Video"]=record
    ["To-Do List"]=todo
    ["Notepad"]=notes
    ["Latest News"]=news
    ["Weather Forecast"]=weather
    ["System Settings"]=settings
    ["Utilities"]=utilities
    ["Set Timer"]=set_timer
    ["SSH Sessions"]=ssh_menu
    ["Tmux Sessions"]=tmux_menu
    ["Password Manager"]=passwd_mgr
    ["Clipboard"]=clipboard
    ["Translate Text"]=translate
    ["Task Manager"]=task_mgr
    ["Notifications"]=notifications
    ["Characters"]=char_picker
    ["Exit"]=session_menu
)

utilities() {
    utils="Calculator\nCalendar\nTranslate Text\nNotepad\nTo-Do List\nSet Timer\nCharacters\nTake Screenshot\nRecord Audio/Video\nSSH Sessions\nTmux Sessions\nPassword Manager\nClipboard\nTask Manager"

    # remember last entry chosen
    local selected_row=0
    local selected_text

    while selected=$(echo -en "$utils" | $ROFI_CMD -selected-row ${selected_row} -format 'i s' -p "Utilities"); do
        selected_row=$(echo "$selected" | awk '{print $1;}')
        selected_text=$(echo "$selected" | cut -d' ' -f2-)

        ${commands[$selected_text]};
    done
}

main_menu() {
    entries="Applications\nRun Command\nBrowse Files\nSearch Computer\nSearch Web\nSteam Games\nLatest News\nWeather Forecast\nWatch TV\nRadio Stations\nUtilities\nNotifications\nSystem Settings\nExit"

    # remember last entry chosen
    local choice_row=0
    local choice_text

    while choice=$(echo -en "$entries" | $ROFI_CMD -selected-row ${choice_row} -format 'i s' -p "Menu"); do
        choice_row=$(echo "$choice" | awk '{print $1;}')
        choice_text=$(echo "$choice" | cut -d' ' -f2-)

        ${commands[$choice_text]};
    done
}

run_app() {
    logfile="$HOME/.cache/rofi-drun.log"
    G_MESSAGES_DEBUG=Modes.DRun rofi -show drun $SHOW_ICONS -log "$logfile";

    # very hacky!!! intercept exit code grepping log file
    entry_chosen=$(grep "Parsed command:" "$logfile")
    rm "$logfile"

    if [  ${#entry_chosen} -gt 0 ]; then
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

    if [  ${#entry_chosen} -gt 0 ]; then
        echo "Entry chosen"
        exit 0;
    fi
}

browse() {
    # TODO: intercept entry chosen to exit
    rofi $SHOW_ICONS -show filebrowser && exit
}

ssh_menu() {
    # TODO: intercept entry chosen to exit
    rofi -show ssh
}

steam_games() {
    "$SCRIPT_PATH"/rofi-steam.sh && exit
}

search() {
    "$SCRIPT_PATH"/rofi-search.sh && exit
}

web_search() {
    apis="google\nwikipedia\nyoutube\nreddit\narchwiki\nflathub"

    # remember last entry chosen
    local api_row=0
    local api_text

    while api=$(echo -e $apis | $ROFI_CMD -selected-row ${api_row} -format 'i s' -p "Website"); do
        api_row=$(echo "$api" | awk '{print $1;}')
        api_text=$(echo "$api" | cut -d' ' -f2-)

        if [ "$api_text" = "reddit" ]; then
            "$SCRIPT_PATH"/rofi-reddit.sh && exit
        elif [ "$api_text" = "flathub" ]; then
            "$SCRIPT_PATH"/rofi-flathub.sh && exit
        else
            "$SCRIPT_PATH"/rofi-web-search.sh "$api_text" && exit
        fi
    done
}

set_timer() {
    rofi -show Timer -modi Timer:"$SCRIPT_PATH"/rofi-timer.sh \
        -theme-str 'entry{placeholder:"Type <hours>h <minutes>m <seconds>s to set a custom timer";'}
}

settings() {
    "$SCRIPT_PATH"/rofi-settings.sh && exit
}

calculator() {
    have_calc=$(rofi -dump-config | grep calc)

    if [ ${#have_calc} -gt 0 ]; then
        rofi -show calc
    else
        rofi -modi calc:"$SCRIPT_PATH"/rofi-calc.sh -show calc
    fi
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

todo() {
    rofi -modi TODO:"$SCRIPT_PATH"/rofi-todo.sh -show TODO
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

weather() {
    curl wttr.in/?ATFn | rofi -dmenu -p "Weather"
}

calendar() {
    "$SCRIPT_PATH"/rofi-calendar.sh
}

translate() {
    "$SCRIPT_PATH"/rofi-translate.sh
}

char_picker() {
    "$SCRIPT_PATH"/rofi-characters.sh
}

notifications() {
    daemon_running=$(ps aux | grep 'rofication-daemon' | wc -l)

    if [ ${daemon_running} -gt 1 ]; then
        "$SCRIPT_PATH"/rofication-gui.py
    else
        rofi -e "Run \"$SCRIPT_PATH/rofication-daemon.py &\" to enable notifications menu"
    fi
}

task_mgr() {
    have_blocks=$(rofi -dump-config | grep blocks)

    if [ ${#have_blocks} -gt 0 ]; then
        "$SCRIPT_PATH"/rofi-top.sh
    else
        eval "$TASK_MANAGER"
    fi
}

clipboard() {
    if command -v greenclip &> /dev/null; then
        rofi -modi "clipboard:greenclip print" -show clipboard -run-command '{cmd}'
    elif [ -f "$SCRIPT_PATH/greenclip" ]; then
        daemon_running=$(ps aux | grep 'greenclip' | wc -l)

        if [ ${daemon_running} -gt 1 ]; then
            rofi -modi "clipboard:$SCRIPT_PATH/greenclip print" -show clipboard -run-command '{cmd}'
        else
                rofi -e "Run \"$SCRIPT_PATH/greenclip daemon &\" to enable the clipboard menu"
        fi
    else
        rofi -e "Download greenclip, place it inside $SCRIPT_PATH and run \"$SCRIPT_PATH/greenclip daemon &\" to enable the clipboard menu"
    fi
}

# run
main_menu

