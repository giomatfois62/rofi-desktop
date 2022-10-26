#!/usr/bin/env bash

# depends: xterm inxi htop

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
ROFI_CMD="rofi -dmenu -i -matching fuzzy"
TASK_MANAGER="xterm -e htop"
SYSTEM_INFO="inxi -c0 -v2 | $ROFI_CMD -p Info"
 
declare -A commands=(
    ["Appearance"]=appearance_menu
    ["Network"]=network
    ["Bluetooth"]=bluetooth
    ["Display"]=display
    ["Volume"]=volume
    ["Brightness"]=brightness
    ["Keyboard Layout"]=kb_layout
    ["Default Applications"]=default_apps
    ["Menu Configuration"]=menu_config
    ["Task Manager"]=task_mgr
    ["System Info"]=sys_info
    # Appearance Settings
    ["Qt5 Appearance"]=qt5_app
    ["GTK Appearance"]=gtk_app
    ["Rofi Style"]=rofi_app
    ["Set Wallpaper"]=wallpaper
    ["Rofi Shortcuts"]=shortcuts
)

settings_menu() {
    entries=("Appearance\nNetwork\nBluetooth\nDisplay\nVolume\nBrightness\nKeyboard Layout\nRofi Shortcuts\nDefault Applications\nMenu Configuration\nTask Manager\nSystem Info")

    # remember last entry chosen
    local choice_row=0
    local choice_text

    while choice=`echo -en $entries | $ROFI_CMD -selected-row ${choice_row} -format 'i s' -p Settings`; do
        if [ ${#choice} -gt 0 ]; then
            choice_row=$(echo $choice | awk '{print $1;}')
            choice_text=$(echo $choice | cut -d' ' -f2-)

            ${commands[$choice_text]};
        fi
    done

    exit 1
}

appearance_menu() {
    appearance_entries=("Qt5 Appearance\nGTK Appearance\nRofi Style\nSet Wallpaper")

    # remember last entry chosen
    local selected_row=0
    local selected_text

    while selected=`echo -en $appearance_entries | $ROFI_CMD -selected-row ${selected_row} -format 'i s' -p Appearance`; do
        if [ ${#selected} -gt 0 ]; then
            selected_row=$(echo $selected | awk '{print $1;}')
            selected_text=$(echo $selected | cut -d' ' -f2-)

            ${commands[$selected_text]};
        fi
    done
}

shortcuts() {
    rofi -show keys
}

network() {
    $SCRIPT_PATH/networkmanager_dmenu
}

bluetooth() {
    $SCRIPT_PATH/rofi-bluetooth.sh
}

display() {
    $SCRIPT_PATH/rofi-monitor-layout.sh
}

volume() {
    $SCRIPT_PATH/rofi-volume.sh
}

menu_config() {
    selected=`find $SCRIPT_PATH -iname '*.sh' -maxdepth 1 -type f | $ROFI_CMD -p Open`

    if [ ${#selected} -gt 0 ]; then
        xdg-open $selected && exit 0
    fi
}

task_mgr() {
    have_blocks=`rofi -dump-config | grep blocks`

    if [ ${#have_blocks} -gt 0 ]; then
        $SCRIPT_PATH/rofi-top.sh
    else
        eval "$TASK_MANAGER"
    fi
}

sys_info() {
    eval "$SYSTEM_INFO"
}

default_apps() {
    $SCRIPT_PATH/rofi-mime.sh
}

brightness() {
    rofi -e "Brightness Menu"
    # TODO: implement brightness controls
}

kb_layout() {
    kbd_file="/usr/share/X11/xkb/rules/evdev.lst"
    selected=$(cat $kbd_file | grep -Poz '(?<=layout\n)(.|\n)*(?=! variant)' | head -n -2 | rofi -dmenu -i -p Layout | awk '{print $1;}')

    if [ ${#selected} -gt 0 ]; then
        setxkbmap $selected
    fi
}

qt5_app() {
    qt5ct;
}

gtk_app() {
    lxappearance;
}

rofi_app() {
    rofi-theme-selector;
}

wallpaper() {
    $SCRIPT_PATH/rofi-wallpaper.sh;
}

settings_menu

