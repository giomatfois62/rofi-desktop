#!/usr/bin/env bash

# optional: rofi-calc

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
ROFI_CMD="rofi -dmenu -i -matching fuzzy"
SHOW_ICONS="-show-icons"
 
entries=("Applications\nRun Command\nBrowse Files\nSearch Computer\nSearch Web\nLatest News\nWeather Forecast\nWatch TV\nWeb Radio\nUtilities\nSystem Settings\nExit")

declare -A commands=(
    ["Applications"]=run_app
    ["Run Command"]=run_cmd
    ["Browse Files"]=browse
    ["Search Computer"]=search
    ["Search Web"]=web_search
    ["Calculator"]=calculator
    ["Calendar"]=calendar
    ["Watch TV"]=tv
    ["Web Radio"]=radio
    ["Take Screenshot"]=screenshot
    ["Record Audio/Video"]=record
    ["To-Do List"]=todo
    ["Notepad"]=notes
    ["Latest News"]=news
    ["Weather Forecast"]=weather
    ["System Settings"]=settings
    ["Utilities"]=utilities
    ["Exit"]=session_menu
)

mkdir -p "$SCRIPT_PATH/data/"

run_app() {
    logfile="$SCRIPT_PATH/data/rofi-drun.log"
    G_MESSAGES_DEBUG=Modes.DRun rofi -show drun $SHOW_ICONS -log $logfile;

    # very hacky!!! intercept exit code grepping log file
    entry_chosen=$(grep "Parsed command:" $logfile)
    rm $logfile

    if [  ${#entry_chosen} -gt 0 ]; then
	echo "Entry chosen"
	exit 0;
    fi
}

run_cmd() {
    logfile="$SCRIPT_PATH/data/rofi-run.log"
    G_MESSAGES_DEBUG=Modes.Run rofi -show run $SHOW_ICONS -log $logfile;

    # very hacky!!! intercept exit code grepping log file
    entry_chosen=$(grep "Parsed command:" $logfile)
    rm $logfile

    if [  ${#entry_chosen} -gt 0 ]; then
	echo "Entry chosen"
	exit 0;
    fi
}

browse() {
    # TODO: intercept entry chosen to exit
    rofi $SHOW_ICONS -show filebrowser && exit
}

search() {
    $SCRIPT_PATH/rofi-search.sh && exit
}

web_search() {
    apis="google\nwikipedia\nyoutube\narchwiki"

    while api=$(echo -e $apis | $ROFI_CMD -p Website); do
	if [ ${#api} -gt 0 ]; then
	    $SCRIPT_PATH/rofi-web-search.sh $api && exit
	fi
    done
}

settings() {
    $SCRIPT_PATH/rofi-settings.sh && exit
}

calculator() {
    have_calc=`rofi -dump-config | grep calc`

    if [ ${#have_calc} -gt 0 ]; then
	rofi -show calc
    else
	rofi -modi "calc:$SCRIPT_PATH/rofi-calc.sh" -show calc
    fi
}

tv() {
    $SCRIPT_PATH/rofi-tv.sh && exit
}

radio() {
    $SCRIPT_PATH/rofi-radio.sh && exit
}

screenshot() {
    $SCRIPT_PATH/rofi-screenshot.sh && exit
}

record() {
    $SCRIPT_PATH/rofi-ffmpeg.sh && exit
}

session_menu() {
    $SCRIPT_PATH/rofi-session.sh && exit
}

todo() {
    rofi -modi TODO:$SCRIPT_PATH/rofi-todo.sh -show TODO
}

notes() {
    $SCRIPT_PATH/rofi-notes.sh && exit
}

news() {
    $SCRIPT_PATH/rofi-news.sh && exit
}

weather() {
    curl wttr.in/?ATFn | rofi -dmenu -p Weather
}

calendar() {
    #cal -3 -m | rofi -dmenu -p "$(date)"
    $SCRIPT_PATH/rofi-calendar.sh
}

utilities() {
    utils=("Calculator\nCalendar\nNotepad\nTo-Do List\nTake Screenshot\nRecord Audio/Video")

    while selected=`echo -en $utils | $ROFI_CMD -p Utilities`; do
	if [ ${#selected} -gt 0 ]; then
	    ${commands[$selected]};
	fi
    done
}

while choice=`echo -en $entries | $ROFI_CMD -p Menu`; do
    if [ ${#choice} -gt 0 ]; then
        ${commands[$choice]};
    fi
done

